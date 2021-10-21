import 'package:flutter/material.dart';
import 'package:teachers/components/custom_dark_button.dart';
import 'package:teachers/components/custom_light_button.dart';
import 'package:teachers/components/custom_text_box.dart';

class ConfirmOTPForm extends StatelessWidget {
  final String caption, sendButtonCaption, resendButtonCaption;
  final TextEditingController otpController;
  final FocusNode otpFocusNode;

  final TextInputAction otpInputAction;

  final Function onSendButtonPressed, onResendButtonPressed;

  const ConfirmOTPForm({
    this.caption,
    this.sendButtonCaption,
    this.resendButtonCaption,
    this.otpController,
    this.otpFocusNode,
    this.otpInputAction,
    this.onSendButtonPressed,
    this.onResendButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CustomTextBox(
            inputAction: otpInputAction,
            focusNode: otpFocusNode,
            labelText: caption,
            controller: otpController,
            icon: Icons.rotate_left,
            keyboardType: TextInputType.number,
            colour: Theme.of(context).primaryColor,
            maxLength: 6,
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: CustomDarkButton(
                  caption: sendButtonCaption,
                  onPressed: onSendButtonPressed,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: CustomLightButton(
                  caption: resendButtonCaption,
                  onPressed: onResendButtonPressed,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            'Enter OTP sent to given Mobile Number.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14.0,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
