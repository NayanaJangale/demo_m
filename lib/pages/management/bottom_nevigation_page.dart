import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teachers/components/bottom_navigation_bar.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/constants/menu_constants.dart';
import 'package:teachers/pages/home_page.dart';
import 'package:teachers/pages/management/mng_brancwise_newsfeed.dart';
import 'package:teachers/pages/management/newsletter_page.dart';
import 'package:teachers/pages/settings_page.dart';


class BottomNevigationPage extends StatefulWidget {
  @override
  _BottomNevigationPageState createState() => _BottomNevigationPageState();
}

class _BottomNevigationPageState extends State<BottomNevigationPage> {
  bool _isLoading;
  String _loadingText;
  int index = 0;
  @override
  void initState() {
    // TODO: implement initState

    this._isLoading = false;
    this._loadingText = 'Loading . . .';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this._isLoading,
      loadingText: this._loadingText,
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: <Widget>[
             Expanded(child: getview()),
             CustomBottomNavigationBar(
                onIconPresedCallback: onBottomIconPressed,
              )
            ],
          )),
    );
  }

  void onBottomIconPressed(int index) {
    setState(() {
      this.index = index;
    });
  }

  Widget getview() {
    switch (index) {
      case 0:
        return MngBrancwiseNewsfeed(menuName: MenuNameConst.Newsfeed,);
        break;
      case 1:
        return HomePage();
        break;
      case 2:
        return SettingsPage();
        break;
      default:
        return NewsletterPage();
    }
  }
}
