import 'package:flutter/material.dart';
import 'package:teachers/components/custom_dark_button.dart';
import 'package:teachers/components/custom_password_box.dart';
import 'package:teachers/components/custom_text_box.dart';

class LoginForm extends StatelessWidget {
  final String userIDCaption,
      passwordCaption,
      loginButtonCaption,
      forgotPasswordCaption,
      createAccountCaption,
      itemTitle;
  bool isSelected;

  final FocusNode userIDFocusNode, passwordFocusNode;
  final TextInputAction userIDInputAction, passwordInputAction;

  final TextEditingController userIDController, userPassController;
  final Function onLoginButtonPressed,
      onForgotPassword,
      onCreateAccountPressed,
      onUserIDSubmitted,
      onPasswordSubmitted,
      onRemembermeTap,
      onValueChange;

  LoginForm({
    this.userIDCaption,
    this.passwordCaption,
    this.loginButtonCaption,
    this.forgotPasswordCaption,
    this.createAccountCaption,
    this.userIDController,
    this.userPassController,
    this.onLoginButtonPressed,
    this.onForgotPassword,
    this.onCreateAccountPressed,
    this.userIDFocusNode,
    this.passwordFocusNode,
    this.onUserIDSubmitted,
    this.onPasswordSubmitted,
    this.userIDInputAction,
    this.passwordInputAction,
    this.onRemembermeTap,
    this.isSelected,
    this.itemTitle,
    this.onValueChange
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: <Widget>[
          CustomTextBox(
            inputAction: userIDInputAction,
            focusNode: userIDFocusNode,
            onFieldSubmitted: onUserIDSubmitted,
            labelText: userIDCaption,
            controller: userIDController,
            icon: Icons.person,
            keyboardType: TextInputType.text,
            colour: Theme.of(context).primaryColor,
          ),
          SizedBox(
            height: 10.0,
          ),
          CustomPasswordBox(
            inputAction: passwordInputAction,
            focusNode: passwordFocusNode,
            onFieldSubmitted: onPasswordSubmitted,
            labelText: passwordCaption,
            controller: userPassController,
            icon: Icons.lock,
            colour: Theme.of(context).primaryColor,
            keyboardType: TextInputType.text,
          ),
          SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
            ),
            child: Align(
              alignment: Alignment.center,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onRemembermeTap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        itemTitle,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.0,

                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 3.0,
                        bottom: 3.0,
                      ),
                      child:Switch(
                        value: isSelected,
                        onChanged: onValueChange,
                        activeTrackColor: Theme.of(context).primaryColorLight,
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          CustomDarkButton(
            caption: loginButtonCaption,
            onPressed: onLoginButtonPressed,
          ),

        ],
      ),
    );
  }
}
