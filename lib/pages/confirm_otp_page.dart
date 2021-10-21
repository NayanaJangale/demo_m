import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/forms/confirm_otp_form.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/reset_password_page.dart';

class ConfirmOTPPage extends StatefulWidget {
  String userId, sMSAutoID, clientCode, mobNo;

  ConfirmOTPPage({this.userId, this.sMSAutoID, this.clientCode, this.mobNo});

  @override
  _ConfirmOTPPageState createState() => _ConfirmOTPPageState();
}

class _ConfirmOTPPageState extends State<ConfirmOTPPage> {
  bool isLoading = false;
  String loadingText;
  String smsAId = "0";

  final GlobalKey<ScaffoldState> _confirmOTPPageGlobalKey =
      new GlobalKey<ScaffoldState>();

  TextEditingController otpController = new TextEditingController();

  FocusNode otpFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _confirmOTPPageGlobalKey,
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
                  child: ConfirmOTPForm(
                    caption: 'OTP',
                    sendButtonCaption: 'Continue',
                    resendButtonCaption: 'Resend',
                    otpController: otpController,
                    otpFocusNode: otpFocusNode,
                    otpInputAction: TextInputAction.done,
                    onResendButtonPressed: _resendOtp,
                    onSendButtonPressed: () {
                      if (smsAId == "0") {
                        setState(() {
                          smsAId = widget.sMSAutoID;
                        });
                      }
                      _validateOtp();
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

  Future<void> _validateOtp() async {
    try {
      if (otpController.text.length == 6) {
        setState(() {
          isLoading = true;
          loadingText = 'Checking OTP . . .';
        });
        /*String connectionStatus =
            await NetworkHandler.checkInternetConnection();
        if (connectionStatus == InternetConnection.CONNECTED) {*/

        String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
        if (connectionServerMsg != "key_check_internet") {
          Uri postValidateOtpUri = Uri.parse(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                UserUrls.POST_VALIDATE_OTP,
          ).replace(
            queryParameters: {
              'clientCode': widget.clientCode,
              'SMSAutoID': smsAId,
              'OTP': otpController.text,
              'UserNo': '1',
              'UserType': 'Teacher',
              'MacAddress': 'xxxxxx',
              'ApplicationType': 'Teacher',
              'AppVersion': '1.0',
            },
          );

          http.Response response = await http.post(postValidateOtpUri);
          setState(() {
            isLoading = false;
            loadingText = '';
          });

          if (response.statusCode != HttpStatusCodes.CREATED) {
            _confirmOTPPageGlobalKey.currentState.showSnackBar(
              SnackBar(
                content: Text(
                  response.body,
                ),
              ),
            );
          } else {
            setState(() {
              isLoading = false;
              loadingText = '';
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordPage(
                  userId: widget.userId,
                  clientCode: widget.clientCode,
                  smsAutoId: smsAId,
                ),
              ),
            );
          }
        }
      } else {
        _confirmOTPPageGlobalKey.currentState.showSnackBar(
          SnackBar(
            content: Text(
              'Please enter received OTP',
            ),
          ),
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

  Future<void> _resendOtp() async {
    setState(() {
      isLoading = true;
      loadingText = 'Resending OTP . . .';
      smsAId = widget.sMSAutoID;
    });

    try {
      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri postGenerateOtpUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              UserUrls.POST_GENERATE_OTP,
        ).replace(
          queryParameters: {
            'TransactionType': 'Forget Password',
            'RecipientMobileNo': widget.mobNo,
            'RecipientType': 'Teacher',
            'RegenerateSMS': 'true',
            'OldSMSAutoID': smsAId,
            'UserNo': '1',
            'UserType': 'Teacher',
            'MacAddress': 'xxxxxx',
            'ApplicationType': 'Teacher',
            'AppVersion': '1.0',
          },
        );

        http.Response response = await http.post(postGenerateOtpUri);
        setState(() {
          isLoading = false;
          loadingText = '';
        });

        if (response.statusCode != HttpStatusCodes.CREATED) {
          _confirmOTPPageGlobalKey.currentState.showSnackBar(
            SnackBar(
              content: Text(
                response.body,
              ),
            ),
          );
        } else {
          setState(() {
            isLoading = false;
            loadingText = '';
            smsAId = json.decode(response.body);
          });
          _confirmOTPPageGlobalKey.currentState.showSnackBar(
            SnackBar(
              content: Text('OTP sent..'),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        loadingText = '';
      });
      print(e);
    }
  }
}
