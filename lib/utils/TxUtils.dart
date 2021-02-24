import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

showToast(text, context) {
  Toast.show(
    text,
    context,
    duration: Toast.LENGTH_SHORT,
    gravity: Toast.CENTER,
  );
}

setStorageByKey(key, value) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.setString(key, value);
}

getStorageByKey(key) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString(key);
}
