import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './constants.dart' as constants;

class TxUtils {
  static String _loginUserId = '';
  static showToast(text, context) {
    Toast.show(
      text,
      context,
      duration: Toast.LENGTH_SHORT,
      gravity: Toast.CENTER,
    );
  }

  static setStorageByKey(key, value) async {
    if (key == constants.USERID_KEY) {
      _loginUserId = value;
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(key, value);
  }

  static Future<String> getStorageByKey(key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(key);
  }

  static String getLoginUserId() {
    return _loginUserId;
  }
}
