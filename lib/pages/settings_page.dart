import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_alert_dialog.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_cupertino_action_message.dart';
import 'package:teachers/components/custom_cupertino_icon_action.dart';
import 'package:teachers/constants/project_locales.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/database_handler.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/localization/application.dart';
import 'package:teachers/pages/change_password_page.dart';
import 'package:teachers/pages/login_page.dart';
import 'package:teachers/themes/app_settings_change_notifier.dart';
import 'package:teachers/themes/menu_type.dart';
import 'package:teachers/themes/theme_constants.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  GlobalKey<ScaffoldState> _settingsPageGK;
  String selectedThemeName, selectedMenuType, selectedLocale = 'en';
  AppSettingsChangeNotifier _appSettingsChangeNotifier;
  Uri uri;

  @override
  void initState() {
    if (AppData.getCurrentInstance().preferences != null) {
      selectedThemeName =
          AppData.getCurrentInstance().preferences.getString('theme') ??
              ThemeNames.Purple;

      AppData.getCurrentInstance().preferences.getString('menuType') == MenuTitles.List
          ? selectedMenuType = MenuTitles.List
          : selectedMenuType = MenuTitles.Grid;

      selectedLocale =
          AppData.getCurrentInstance().preferences.getString('locale') ?? 'en';
    } else {
      selectedThemeName = ThemeNames.Purple;
      selectedMenuType = MenuTitles.Grid;
      selectedLocale = 'en';
    }

    application.onLocaleChanged = onLocaleChange;
    super.initState();
    _settingsPageGK = GlobalKey<ScaffoldState>();
    NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
      if (connectionServerMsg != "key_check_internet") {
        setState(() {
          uri = Uri.parse(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                'Users/GetClientPhoto',
          ).replace(queryParameters: {
            "clientCode": AppData.getCurrentInstance().user.client_code,
            "brcode": AppData.getCurrentInstance().user.brcode,
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _appSettingsChangeNotifier =
        Provider.of<AppSettingsChangeNotifier>(context);

    AppData.getCurrentInstance().preferences.getString('menuType') == MenuTitles.List
        ? selectedMenuType = AppTranslations.of(context).text("key_list")
        : selectedMenuType = AppTranslations.of(context).text("key_grid");

    return Scaffold(
      key: _settingsPageGK,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Row(
          children: <Widget>[
            SizedBox(
              width: 5,
            ),
            Container(
              width: 50,
              height: 40,
              child: Image.network(
                uri == null ? "" : uri.toString(),
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
        title: CustomAppBar(
          title: AppTranslations.of(context).text("key_hi") +
              ' ' +
              StringHandlers.capitalizeWords(
                  AppData.getCurrentInstance().user.emp_name),
          subtitle: AppTranslations.of(context).text("key_app_settings"),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.grey.withOpacity(0.2),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  AppTranslations.of(context).text("key_appearance"),
                  style: Theme.of(context).textTheme.subhead.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  AppTranslations.of(context).text("key_theme"),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10.0, right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  themeColors.length,
                  (index) => getThemeColor(
                    themeColors[index],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 5.0,
              ),
              child: Divider(
                height: 0.0,
                color: Colors.black12,
              ),
            ),
            GestureDetector(
              onTap: () {
                showLocaleList();
              },
              child: Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, bottom: 10.0, top: 10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          AppTranslations.of(context).text("key_language"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          selectedLocale == 'en' ? 'English' : 'मराठी',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black45,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 5.0,
              ),
              child: Divider(
                height: 0.0,
                color: Colors.black12,
              ),
            ),
            GestureDetector(
              onTap: () {
                showMenuTypeList();
              },
              child: Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, bottom: 10.0, top: 10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          AppTranslations.of(context).text("key_menu_type"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          selectedMenuType,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black45,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 3.0,
            ),
            Container(
              color: Colors.grey.withOpacity(0.2),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  AppTranslations.of(context).text("key_account"),
                  style: Theme.of(context).textTheme.subhead.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
           /* GestureDetector(
              onTap: () {
               Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SwitchAcountPage(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, bottom: 10.0, top: 10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          AppTranslations.of(context)
                              .text("key_switch_account"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.navigate_next,
                        color: Colors.black45,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),*/
            Padding(
              padding: const EdgeInsets.only(
                top: 5.0,
              ),
              child: Divider(
                height: 0.0,
                color: Colors.black12,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordPage(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, bottom: 10.0, top: 10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          AppTranslations.of(context)
                              .text("key_change_password"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.navigate_next,
                        color: Colors.black45,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 5.0,
              ),
              child: Divider(
                height: 0.0,
                color: Colors.black12,
              ),
            ),
            GestureDetector(
              onTap: () {
                _logout();
              },
              child: Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, bottom: 10.0, top: 10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          AppTranslations.of(context).text("key_logout"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(
                        Icons.navigate_next,
                        color: Colors.black45,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 5.0,
              ),
              child: Divider(
                height: 0.0,
                color: Colors.black12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getThemeColor(ThemeColor themeColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedThemeName = themeColor.caption;

          ThemeData themeData;
          switch (selectedThemeName) {
            case ThemeNames.Purple:
              themeData = ThemeConfig.purpleThemeData(context);
              break;
            case ThemeNames.Blue:
              themeData = ThemeConfig.blueThemeData(context);
              break;
            case ThemeNames.Teal:
              themeData = ThemeConfig.tealThemeData(context);
              break;
            case ThemeNames.Amber:
              themeData = ThemeConfig.amberThemeData(context);
              break;
          }
          _appSettingsChangeNotifier.setTheme(selectedThemeName, themeData);

          AppData.getCurrentInstance()
              .preferences
              .setString('theme', selectedThemeName);
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: themeColor.color,
              radius: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                themeColor.caption == selectedThemeName
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: themeColor.caption == selectedThemeName
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).secondaryHeaderColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showMenuTypeList() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_select_menu_type"),
        ),
        actions: List<Widget>.generate(
          menuTypes.length,
          (index) => CustomCupertinoIconAction(
            isImage: false,
            iconData: menuTypes[index].icon,
            actionText: AppTranslations.of(context)
                .text("key_${menuTypes[index].typeTitle}"),
            actionIndex: index,
            onActionPressed: () {
              setState(() {
                selectedMenuType = menuTypes[index].typeTitle;
                AppData.getCurrentInstance()
                    .preferences
                    .setString('menuType', selectedMenuType);

                selectedMenuType = AppTranslations.of(context)
                    .text("key_${menuTypes[index].typeTitle}");
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void showLocaleList() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_select_app_language"),
        ),
        actions: List<Widget>.generate(
          projectLocales.length,
          (index) => CustomCupertinoIconAction(
            isImage: true,
            imagePath: projectLocales[index].image,
            actionText: projectLocales[index].title,
            actionIndex: index,
            onActionPressed: () {
              setState(() {
                _appSettingsChangeNotifier.setLocale(
                  Locale(projectLocales[index].lanaguageCode),
                );
                selectedLocale = projectLocales[index].lanaguageCode;

                AppData.getCurrentInstance()
                    .preferences
                    .setString('locale', selectedLocale);
              });

              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Future<void> onLocaleChange(Locale locale) async {
    setState(() {
      AppTranslations.load(locale);
    });
  }

  List<Widget> getThemeMenuTypeList(BuildContext context) {
    List<Widget> menuItems = [];

    for (int i = 0; i < menuTypes.length; i++) {
      menuItems.add(
        GestureDetector(
          onTap: () {
            showMenuTypeList();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(menuTypes[i].typeTitle),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    menuTypes[i].icon,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return menuItems;
  }

  void _logout() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CustomActionDialog(
        actionName: AppTranslations.of(context).text("key_yes"),
        onActionTapped: () {
          DBHandler().logout(AppData.getCurrentInstance().user);
          AppData.getCurrentInstance().user = null;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (Route<dynamic> route) => false,
          );
        },
        actionColor: Colors.red,
        message: AppTranslations.of(context).text("key_logout_confirmation"),
        onCancelTapped: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
