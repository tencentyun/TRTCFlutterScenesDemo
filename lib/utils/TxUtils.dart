import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './constants.dart' as constants;

class TxUtils {
  static String _loginUserId = '';
  static() {
    if (_loginUserId == '') {
      getStorageByKey(constants.USERID_KEY).then((value) {
        _loginUserId = value;
      });
    }
  }

  static showErrorToast(text, context) {
    Toast.show(
      text,
      context,
      backgroundColor: Colors.red[400],
      // Color.fromRGBO(156, 31, 59, 1), //Color.fromRGBO(251, 224, 224, 1),
      //textColor: Color.fromRGBO(156, 31, 59, 1),
      duration: Toast.LENGTH_SHORT,
      gravity: Toast.CENTER,
    );
  }

  static showToast(text, context) {
    Toast.show(
      text,
      context,
      backgroundColor: Colors.green[400],
      duration: Toast.LENGTH_SHORT,
      gravity: Toast.BOTTOM,
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
    // if (_loginUserId == '') {
    //   _loginUserId = getStorageByKey(constants.USERID_KEY);
    // }
    return _loginUserId;
  }
}
