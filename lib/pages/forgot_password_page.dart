import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/forms/forgot_password_form.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/user.dart';

import 'confirm_otp_page.dart';

class ForgotPassword extends StatefulWidget {
  String clientCode;

  ForgotPassword({this.clientCode});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool isLoading = false;
  String loadingText;

  final GlobalKey<ScaffoldState> _forgetPasswordPageGlobalKey =
      new GlobalKey<ScaffoldState>();

  TextEditingController mobNoController = new TextEditingController();
  TextEditingController userIdController = new TextEditingController();

  FocusNode mobNoFocusNode = FocusNode();
  FocusNode userIdFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _forgetPasswordPageGlobalKey,
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
                  child: ForgotPasswordForm(
                    userIdCaption: 'User Id',
                    userIdController: userIdController,
                    userIdFocusNode: userIdFocusNode,
                    userIdInputAction: TextInputAction.next,
                    mobNoFOcusNode: mobNoFocusNode,
                    mobNoInputAction: TextInputAction.done,
                    backButtonCaption: 'Back',
                    continueButtonCaption: 'Continue',
                    mobNoCaption: 'Mobile No',
                    mobNoController: mobNoController,
                    onBackButtonPressed: () {
                      Navigator.pop(context);
                    },
                    onContinueButtonPressed: _sendOtpForForgetPassword,
                    onUserIdSubmitted: (value) {
                      this.userIdFocusNode.unfocus();
                      FocusScope.of(context).requestFocus(this.mobNoFocusNode);
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

  Future<void> _sendOtpForForgetPassword() async {
    String validationMsg = _isValidateForm();
    if (validationMsg == "success") {
      try {
        setState(() {
          isLoading = true;
          loadingText = 'Sending OTP . . .';
        });

        /* String connectionStatus =
            await NetworkHandler.checkInternetConnection();
        if (connectionStatus == InternetConnection.CONNECTED) {*/

        String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
        if (connectionServerMsg != "key_check_internet") {
          Uri postSendOtpUri = Uri.parse(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                UserUrls.POST_GENERATE_OTP,
          ).replace(
            queryParameters: {
              'clientCode': widget.clientCode,
              'TransactionType': 'Forgot Password',
              'RecipientMobileNo': mobNoController.text,
              'RecipientType': 'Teacher',
              'RegenerateSMS': 'false',
              'UserNo': '1',
              'UserType': 'Teacher',
              'MacAddress': 'xxxxxx',
              'ApplicationType': 'Teacher',
              'AppVersion': '1.0',
            },
          );

          http.Response response = await http.post(postSendOtpUri);
          setState(() {
            isLoading = false;
            loadingText = '';
          });

          if (response.statusCode == HttpStatusCodes.CREATED) {
            var sAuto = json.decode(response.body);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmOTPPage(
                  userId: userIdController.text,
                  mobNo: mobNoController.text,
                  sMSAutoID: sAuto,
                  clientCode: widget.clientCode,
                ),
              ),
            );
          } else {
            _forgetPasswordPageGlobalKey.currentState.showSnackBar(
              SnackBar(
                content: Text(
                  response.body,
                ),
              ),
            );
          }
        }
      } catch (e) {
        setState(() {
          isLoading = false;
          loadingText = '';
        });
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.INFORMATION,
        );
      }
    } else {
      setState(() {
        isLoading = false;
        loadingText = '';
      });
      _forgetPasswordPageGlobalKey.currentState.showSnackBar(
        SnackBar(
          content: Text(validationMsg),
        ),
      );
    }
  }

  String _isValidateForm() {
    if (userIdController.text.length == 0) {
      return 'Kindly enter User Id';
    } else if (mobNoController.text.length != 10) {
      return 'Kindly enter valid Mobile Number';
    } else {
      return "success";
    }
  }
}
