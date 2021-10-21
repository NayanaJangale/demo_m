import 'package:flutter/material.dart';
import 'package:teachers/forms/create_account_form.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final GlobalKey<ScaffoldState> _createAccountPageGlobalKey =
      new GlobalKey<ScaffoldState>();

  TextEditingController displayNameController = new TextEditingController();
  TextEditingController mobileNoController = new TextEditingController();
  FocusNode displayNameFocusNode = FocusNode();
  FocusNode mobileNoFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _createAccountPageGlobalKey,
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
                child: CreateAccountForm(
                  displayNameCaption: 'Your Name',
                  mobileNoCaption: 'Mobile No',
                  continueButtonCaption: 'CONTINUE',
                  backButtonCaption: 'BACK',
                  displayNameFocusNode: this.displayNameFocusNode,
                  mobileNoFocusNode: this.mobileNoFocusNode,
                  displayNameInputAction: TextInputAction.next,
                  mobileNoInputAction: TextInputAction.done,
                  displayNameController: this.displayNameController,
                  mobileNoController: this.mobileNoController,
                  onContinueButtonPressed: () {},
                  onBackButtonPressed: () {},
                  onDisplayNameSubmitted: (value) {
                    this.displayNameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(this.mobileNoFocusNode);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
