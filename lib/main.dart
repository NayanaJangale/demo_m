import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teachers/localization/app_translations_delegate.dart';
import 'package:teachers/localization/application.dart';
import 'package:teachers/pages/welcome_page.dart';
import 'package:teachers/themes/app_settings_change_notifier.dart';
import 'package:teachers/themes/theme_constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((preferences) {
    runApp(SoftCampusTeacher(preferences: preferences));
  });
}

class SoftCampusTeacher extends StatefulWidget {
  final SharedPreferences preferences;
  SoftCampusTeacher({
    this.preferences,
  });

  @override
  _SoftCampusTeacherState createState() => _SoftCampusTeacherState();
}

class _SoftCampusTeacherState extends State<SoftCampusTeacher> {
  @override
  Widget build(BuildContext context) {
    String themeName =
        (widget.preferences.getString('theme') ?? ThemeNames.Purple);

    Locale locale = Locale(
      (widget.preferences.getString('locale') ?? 'en'),
    );

    return ChangeNotifierProvider<AppSettingsChangeNotifier>(
      create: (_) => AppSettingsChangeNotifier(
          _handleThemeConfiguration(), themeName, locale),
      child: AppWithCustomTheme(
        preferences: widget.preferences,
      ),
    );
  }

  ThemeData _handleThemeConfiguration() {
    String themeName =
        (widget.preferences.getString('theme') ?? ThemeNames.Purple);

    switch (themeName) {
      case ThemeNames.Purple:
        return ThemeConfig.purpleThemeData(context);
      case ThemeNames.Blue:
        return ThemeConfig.blueThemeData(context);
      case ThemeNames.Teal:
        return ThemeConfig.tealThemeData(context);
      case ThemeNames.Amber:
        return ThemeConfig.amberThemeData(context);
    }
  }
}

class AppWithCustomTheme extends StatefulWidget {
  final SharedPreferences preferences;
  AppWithCustomTheme({@required this.preferences});

  @override
  _AppWithCustomThemeState createState() => _AppWithCustomThemeState();
}

class _AppWithCustomThemeState extends State<AppWithCustomTheme> {
  AppTranslationsDelegate _newLocaleDelegate;

  @override
  void initState() {
    _newLocaleDelegate = AppTranslationsDelegate(newLocale: null);
    application.onLocaleChanged = onLocaleChange;

    super.initState();
  }

  void onLocaleChange(Locale locale) {
    _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsChangeNotifier>(context);
    onLocaleChange(
      settings.getLocale(),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: settings.getTheme(),
      home: WelcomePage(
        preferences: widget.preferences,
      ),
      localizationsDelegates: [
        _newLocaleDelegate,
        //provides localised strings
        GlobalMaterialLocalizations.delegate,
        //provides RTL support
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("en", ""),
        const Locale("mr", ""),
      ],
    );
  }
}
