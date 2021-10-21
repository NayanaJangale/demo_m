import 'package:shared_preferences/shared_preferences.dart';

import 'models/user.dart';

class AppData {
  static AppData _current;
  static AppData getCurrentInstance() {
    if (_current == null) {
      _current = AppData();
    }

    return _current;
  }

  User user;
  SharedPreferences preferences;
}
