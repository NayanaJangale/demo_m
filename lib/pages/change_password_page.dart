import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/forms/change_password_form.dart';
import 'package:teachers/handlers/database_handler.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/home_page.dart';
import 'package:teachers/pages/management/bottom_nevigation_page.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool isLoading = false;
  String loadingText;
  DBHandler _dbHandler;

  final GlobalKey<ScaffoldState> _changePasswordPageGlobalKey =
      new GlobalKey<ScaffoldState>();

  TextEditingController oldPasswordController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();

  FocusNode oldPasswordFocusNode = FocusNode();
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
    try {
      return CustomProgressHandler(
        isLoading: this.isLoading,
        loadingText: this.loadingText,
        child: Scaffold(
          appBar: AppBar(
            title: CustomAppBar(
              title: AppTranslations.of(context).text("key_hi") +
                  StringHandlers.capitalizeWords(
                      AppData.getCurrentInstance().user.emp_name),
              subtitle: AppTranslations.of(context).text("key_change_password"),
            ),
          ),
          key: _changePasswordPageGlobalKey,
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      left: 30,
                      right: 30,
                      bottom: 30,
                      top: 20,
                    ),
                    child: ChangePasswordForm(
                        oldPasswordCaption: AppTranslations.of(context).text("key_current_password"),
                        passwordCaption:  AppTranslations.of(context).text("key_new_password"),
                        confirmPasswordCaption: AppTranslations.of(context).text("key_Confirm_password"),
                        changeButtonCaption: AppTranslations.of(context).text("key_Change"),
                        cancelButtonCaption: AppTranslations.of(context).text("key_Concel"),
                        oldPasswordInputAction: TextInputAction.next,
                        passwordInputAction: TextInputAction.next,
                        confirmPasswordInputAction: TextInputAction.done,
                        oldPasswordFocusNode: oldPasswordFocusNode,
                        passwordFocusNode: passwordFocusNode,
                        confirmPasswordFocusNode: confirmPasswordFocusNode,
                        oldPasswordController: oldPasswordController,
                        passwordController: passwordController,
                        confirmPasswordController: confirmPasswordController,
                        onChangeButtonPressed: _isPasswordMatched,
                        onPasswordSubmitted: (value) {
                          this.passwordFocusNode.unfocus();
                          FocusScope.of(context)
                              .requestFocus(this.confirmPasswordFocusNode);
                        },
                        onOldPasswordSubmitted: (value) {
                          this.oldPasswordFocusNode.unfocus();
                          FocusScope.of(context)
                              .requestFocus(this.passwordFocusNode);
                        },
                        onCancelButtonPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  void _isPasswordMatched() {
    Pattern pattern = r'^(?=.{6,}$)(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])(?=.*?\W).*$';
    RegExp regex = new RegExp(pattern);
    if (oldPasswordController.text.length == 0) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_Current_pass_mandatory"),
        MessageTypes.ERROR,
      );
    } else if (passwordController.text != confirmPasswordController.text) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_old_confirm_pass_diff"),
        MessageTypes.WARNING,
      );
    }else if (!regex.hasMatch(passwordController.text))
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_password_strength"),
        MessageTypes.WARNING,
      );
    else if(this.oldPasswordController.text == this.passwordController.text){
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text(AppTranslations.of(context).text("key_old_new_pass_diff")),
        MessageTypes.WARNING,
      );
    } else {
      _changePassword();
    }
  }

  Future<void> _changePassword() async {
    try {
      setState(() {
        isLoading = true;
        loadingText = AppTranslations.of(context).text("key_processing_text");
      });
      //TODO: Call change password Api here


      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri postChangePasswordUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              UserUrls.POST_CHANGE_TEACHER_PASSWORD,
          {
            'old_pwd': oldPasswordController.text,
            'new_pwd': confirmPasswordController.text,
          },
        );
        http.Response response = await http.post(postChangePasswordUri);
        setState(() {
          isLoading = false;
          loadingText = '';
        });

        if (response.statusCode == HttpStatusCodes.ACCEPTED) {
          //TODO: Call login
          _login();
        } else {
          _changePasswordPageGlobalKey.currentState.showSnackBar(
            SnackBar(
              content: Text(
                response.body,
              ),
            ),
          );
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.ERROR,
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
      AppData appData = AppData.getCurrentInstance();
      Uri getEmployeeDetailsUri = Uri.parse(
        connectionServerMsg +
            ProjectSettings.rootUrl +
            UserUrls.GET_EMPLOYEE_DETAILS,
      ).replace(
        queryParameters: {
          'userID': appData.user.user_id,
          'userPassword': confirmPasswordController.text,
          'clientCode': appData.user.client_code,
        },
      );

      http.Response response = await http.get(getEmployeeDetailsUri);
      if (response.statusCode != HttpStatusCodes.OK) {
        FlushbarMessage.show(
          context,
          null,
          response.body,
          MessageTypes.ERROR,
        );
      } else {
        var data = json.decode(response.body);
        User user = User.fromJson(data);
        if (user == null) {
          FlushbarMessage.show(
            context,
            null,
            AppTranslations.of(context).text("key_unable_to_login_with_new_password"),
            MessageTypes.ERROR,
          );
        } else {
          user.client_code = appData.user.client_code;
          user.clientName = appData.user.clientName;
          user.is_logged_in = 1;
          user.remember_me = 1;

          user = await _dbHandler.updateUser(user);
          if (user != null) {
            AppData.getCurrentInstance().user = user;
            FlushbarMessage.show(
                context,
                null,
                AppTranslations.of(context).text("key_dear") +
                    user.emp_name +
                    AppTranslations.of(context).text("key_successfully_change_password"),
                MessageTypes.INFORMATION);

            Future.delayed(Duration(seconds: 3)).then((val) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => BottomNevigationPage(),
                ),
                    (Route<dynamic> route) => false,
              );
            });

          } else {
            FlushbarMessage.show(
              context,
              null,
              AppTranslations.of(context).text("key_unable_to_perform_local_login"),
              MessageTypes.ERROR,
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
