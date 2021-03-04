import 'dart:io';

import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './constants.dart' as constants;
import 'dart:math';

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
      duration: Toast.LENGTH_SHORT,
      gravity: Toast.CENTER,
    );
    print(text);
  }

  static getRandomNumber() {
    Random rng = new Random();
    //2147483647
    String numStr = '';
    for (var i = 0; i < 9; i++) {
      numStr += rng.nextInt(9).toString();
    }
    return int.tryParse(numStr);
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

  static Future<String> getLoginUserId() {
    if (_loginUserId == '') {
      return getStorageByKey(constants.USERID_KEY);
    }
    return Future.value(_loginUserId);
  }
}
