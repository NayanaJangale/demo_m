import 'package:flutter/material.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/forms/login_form.dart';
import 'package:teachers/handlers/database_handler.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/management/bottom_nevigation_page.dart';
import 'package:teachers/pages/select_school_page.dart';

import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<ScaffoldState> _loginPageGlobalKey;

  TextEditingController userIDController = new TextEditingController();
  TextEditingController userPasswordController = new TextEditingController();
  FocusNode userIDFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  bool isLoading = false;
  String loadingText;
  DBHandler _dbHandler;
  bool isSelected = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _loginPageGlobalKey = new GlobalKey<ScaffoldState>();
    loadingText = 'Validating Credentials . . .';
    _dbHandler = DBHandler();
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _loginPageGlobalKey,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            //  mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                child: Image.asset(
                  'assets/images/banner.jpg',
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 30, right: 30, bottom: 30),
                child: LoginForm(
                  userIDCaption: AppTranslations.of(context).text("key_user_id"),
                  userIDController: this.userIDController,
                  passwordCaption: AppTranslations.of(context).text("key_password"),
                  userPassController: this.userPasswordController,
                  loginButtonCaption: AppTranslations.of(context).text("key_login"),
                  forgotPasswordCaption: AppTranslations.of(context).text("key_forgot_password"),
                  createAccountCaption: AppTranslations.of(context).text("key_create_account"),
                  onLoginButtonPressed: _login,
                  onForgotPassword: () {
                    FlushbarMessage.show(
                      context,
                      null,
                      'Coming soon...',
                      MessageTypes.INFORMATION,
                    );
                  },
                  onCreateAccountPressed: () {
                    FlushbarMessage.show(
                      context,
                      null,
                      'Coming soon...',
                      MessageTypes.INFORMATION,
                    );
                  },
                  userIDFocusNode: this.userIDFocusNode,
                  passwordFocusNode: this.passwordFocusNode,
                  userIDInputAction: TextInputAction.next,
                  passwordInputAction: TextInputAction.done,
                  onUserIDSubmitted: (value) {
                    this.userIDFocusNode.unfocus();
                    FocusScope.of(context)
                        .requestFocus(this.passwordFocusNode);
                  },
                  onValueChange: (val){
                    setState(() {
                      isSelected = val;
                    });
                  },
                  itemTitle: AppTranslations.of(context).text("key_Remember_me"),
                  isSelected: isSelected,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Designed & Developed by',
                        style: Theme.of(context).textTheme.caption.copyWith(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/board.jpg',
                      height: 75,
                      width: 150,
                    ),
                  ],
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }

  Future<User> getLocalUser(String userID, String userPassword) async {
    try {
      User user;

      await _dbHandler.getUser(userID, userPassword).then(
        (result) {
          user = result;
        },
      );

      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      loadingText = 'Validating . . .';
    });

    try {
      String retMsg = await _validateLoginForm(
        userIDController.text,
        userPasswordController.text,
      );

      if (retMsg == '') {
        User user = await getLocalUser(
          userIDController.text,
          userPasswordController.text,
        );

        setState(() {
          isLoading = false;
        });

        if (user != null) {
          int rememberMe = isSelected ? 1 : 0;
          user.remember_me = rememberMe;
          AppData.getCurrentInstance().user = await _dbHandler.login(user);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BottomNevigationPage(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SelectSchoolPage(
                userId: userIDController.text,
                password: userPasswordController.text,
                select_school_for: 'Login',
                isSelected : isSelected,
              ),
            ),
          );
        }
      } else {
        _loginPageGlobalKey.currentState.showSnackBar(
          SnackBar(
            content: Text(retMsg),
          ),
        );
      }
    } catch (e) {
      _loginPageGlobalKey.currentState.showSnackBar(
        SnackBar(
          content: Text(
            AppTranslations.of(context).text("key_login_instuction")),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<String> _validateLoginForm(String userID, String userPassword) async {
    if (userID.length == 0) {
      return  AppTranslations.of(context).text("key_enter_user_id");
    }

    if (userPassword.length == 0) {
      return  AppTranslations.of(context).text("key_enter_user_password");
    }

    return "";
  }
}
