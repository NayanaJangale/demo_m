import 'package:flutter/material.dart';
import 'package:teachers/components/custom_dark_button.dart';
import 'package:teachers/components/custom_light_button.dart';
import 'package:teachers/components/custom_text_box.dart';

class ForgotPasswordForm extends StatelessWidget {
  final String mobNoCaption,
      userIdCaption,
      continueButtonCaption,
      backButtonCaption;
  final TextEditingController mobNoController, userIdController;
  final FocusNode mobNoFOcusNode, userIdFocusNode;

  final TextInputAction mobNoInputAction, userIdInputAction;

  final Function onContinueButtonPressed,
      onBackButtonPressed,
      onUserIdSubmitted;

  const ForgotPasswordForm({
    this.mobNoCaption,
    this.continueButtonCaption,
    this.backButtonCaption,
    this.mobNoController,
    this.onContinueButtonPressed,
    this.onBackButtonPressed,
    this.mobNoFOcusNode,
    this.mobNoInputAction,
    this.userIdCaption,
    this.userIdController,
    this.userIdFocusNode,
    this.userIdInputAction,
    this.onUserIdSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CustomTextBox(
            inputAction: userIdInputAction,
            focusNode: userIdFocusNode,
            labelText: userIdCaption,
            controller: userIdController,
            icon: Icons.person,
            keyboardType: TextInputType.text,
            colour: Theme.of(context).primaryColor,
            onFieldSubmitted: onUserIdSubmitted,
          ),
          SizedBox(
            height: 10.0,
          ),
          CustomTextBox(
            inputAction: mobNoInputAction,
            focusNode: mobNoFOcusNode,
            labelText: mobNoCaption,
            controller: mobNoController,
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            colour: Theme.of(context).primaryColor,
            maxLength: 10,
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: CustomDarkButton(
                  caption: continueButtonCaption,
                  onPressed: onContinueButtonPressed,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: CustomLightButton(
                  caption: backButtonCaption,
                  onPressed: onBackButtonPressed,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            'Enter your User ID and registered Mobile No.',
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
