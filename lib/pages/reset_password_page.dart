import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/forms/reset_password_form.dart';
import 'package:teachers/handlers/database_handler.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/home_page.dart';

class ResetPasswordPage extends StatefulWidget {
  String userId, clientCode, smsAutoId;

  ResetPasswordPage({this.userId, this.clientCode, this.smsAutoId});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool isLoading = false;
  String loadingText;
  DBHandler _dbHandler;

  final GlobalKey<ScaffoldState> _resetPasswordPageGlobalKey =
      new GlobalKey<ScaffoldState>();

  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dbHandler = DBHandler();
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _resetPasswordPageGlobalKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  child: Image.asset(
                    'assets/images/banner.png',
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30, right: 30, bottom: 30),
                  child: ResetPasswordForm(
                    passwordCaption: 'Password',
                    confirmPasswordCaption: 'Confirm Password',
                    confirmButtonCaption: 'CONFIRM',
                    backButtonCaption: 'BACK',
                    passwordInputAction: TextInputAction.next,
                    confirmPasswordInputAction: TextInputAction.done,
                    passwordFocusNode: passwordFocusNode,
                    confirmPasswordFocusNode: confirmPasswordFocusNode,
                    passwordController: passwordController,
                    confirmPasswordController: confirmPasswordController,
                    onConfirmButtonPressed: _isPasswordMatched,
                    onBackButtonPressed: () {
                      Navigator.pop(context);
                    },
                    onPasswordSubmitted: (value) {
                      this.passwordFocusNode.unfocus();
                      FocusScope.of(context)
                          .requestFocus(this.confirmPasswordFocusNode);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _isPasswordMatched() {
    if (passwordController.text == confirmPasswordController.text) {
      _resetPassword();
    } else {
      FlushbarMessage.show(
        context,
        null,
        'Kindly enter same password..!',
        MessageTypes.INFORMATION,
      );
    }
  }

  Future<void> _resetPassword() async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Processing . . .';
      });
      //TODO: Call registration Api here

      /* String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri postResetPasswordUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              UserUrls.POST_RESET_TEACHER_PASSWORD,
        ).replace(
          queryParameters: {
            'clientCode': widget.clientCode,
            'LoginID': widget.userId,
            'NewPassword': confirmPasswordController.text,
            'SMSAutoID': widget.smsAutoId,
            'UserType': 'Teacher',
            'MacAddress': 'xxxxxx',
            'ApplicationType': 'Teacher',
            'AppVersion': '1.0',
          },
        );

        http.Response response = await http.post(postResetPasswordUri);
        setState(() {
          isLoading = false;
          loadingText = '';
        });

        if (response.statusCode == HttpStatusCodes.OK) {
          //TODO: Call login
          _login();
        } else {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.ERROR,
          );
        }
      } else {
        FlushbarMessage.show(
          context,
          'No Internet',
          'Please check your Internet Connection',
          MessageTypes.INFORMATION,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        loadingText = '';
      });
      print(e);
    }
  }

  Future<void> _login() async {
    String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
    if (connectionServerMsg != "key_check_internet") {
      Uri getEmployeeDetailsUri = Uri.parse(
        connectionServerMsg +
            ProjectSettings.rootUrl +
            UserUrls.GET_EMPLOYEE_DETAILS,
      ).replace(
        queryParameters: {
          'userID': widget.userId,
          'userPassword': confirmPasswordController.text,
          'clientCode': widget.clientCode,
        },
      );

      http.Response response = await http.get(getEmployeeDetailsUri);
      if (response.statusCode != HttpStatusCodes.OK) {
        _resetPasswordPageGlobalKey.currentState.showSnackBar(
          SnackBar(
            content: Text(
              response.body,
            ),
          ),
        );
      } else {
        var data = json.decode(response.body);
        User user = User.fromJson(data);
        if (user == null) {
          _resetPasswordPageGlobalKey.currentState.showSnackBar(
            SnackBar(
              content: Text(
                'Unable to login with new password..!',
              ),
            ),
          );
        } else {
          user = await _dbHandler.saveUser(user);
          if (user != null) {
            AppData.getCurrentInstance().user = await _dbHandler.login(user);

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(),
              ),
              (Route<dynamic> route) => false,
            );
          } else {
            _resetPasswordPageGlobalKey.currentState.showSnackBar(
              SnackBar(
                content: Text(
                  'Not able to perform local login!',
                ),
              ),
            );
          }
        }
      }
    } else {
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_no_internet"),
        AppTranslations.of(context).text("key_check_internet"),
        MessageTypes.WARNING,
      );
    }
  }
}
