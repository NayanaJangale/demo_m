import 'package:flutter/material.dart';
import 'package:teachers/components/custom_dark_button.dart';
import 'package:teachers/components/custom_light_button.dart';
import 'package:teachers/components/custom_text_box.dart';

class CreateAccountForm extends StatelessWidget {
  final String displayNameCaption,
      mobileNoCaption,
      continueButtonCaption,
      backButtonCaption;
  final FocusNode displayNameFocusNode, mobileNoFocusNode;
  final TextInputAction displayNameInputAction, mobileNoInputAction;

  final TextEditingController displayNameController, mobileNoController;
  final Function onContinueButtonPressed,
      onDisplayNameSubmitted,
      onMobileNoSubmitted,
      onBackButtonPressed;

  CreateAccountForm({
    this.displayNameCaption,
    this.mobileNoCaption,
    this.continueButtonCaption,
    this.displayNameFocusNode,
    this.mobileNoFocusNode,
    this.displayNameInputAction,
    this.mobileNoInputAction,
    this.displayNameController,
    this.mobileNoController,
    this.onContinueButtonPressed,
    this.onDisplayNameSubmitted,
    this.onMobileNoSubmitted,
    this.backButtonCaption,
    this.onBackButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CustomTextBox(
            inputAction: displayNameInputAction,
            focusNode: displayNameFocusNode,
            onFieldSubmitted: onDisplayNameSubmitted,
            labelText: displayNameCaption,
            controller: displayNameController,
            icon: Icons.person,
            keyboardType: TextInputType.text,
            colour: Theme.of(context).primaryColor,
          ),
          SizedBox(
            height: 10.0,
          ),
          CustomTextBox(
            inputAction: mobileNoInputAction,
            focusNode: mobileNoFocusNode,
            onFieldSubmitted: onMobileNoSubmitted,
            labelText: mobileNoCaption,
            controller: mobileNoController,
            maxLength: 10,
            icon: Icons.phone_iphone,
            keyboardType: TextInputType.number,
            colour: Theme.of(context).primaryColor,
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
            'Enter your name and mobile no to create an account.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
