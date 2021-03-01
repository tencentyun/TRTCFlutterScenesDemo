import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TxUtils {
  static showToast(text, context) {
    Toast.show(
      text,
      context,
      duration: Toast.LENGTH_SHORT,
      gravity: Toast.CENTER,
    );
  }

  static setStorageByKey(key, value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(key, value);
  }

  static Future<String> getStorageByKey(key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(key);
  }
}
