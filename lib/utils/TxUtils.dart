import 'package:flutter_bugly/flutter_bugly.dart';
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
      duration: Toast.LENGTH_LONG,
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

  static List<String> _defaltUrlList = [
    'https://imgcache.qq.com/operation/dianshi/other/7.157d962fa53be4107d6258af6e6d83f33d45fba4.png',
    'https://imgcache.qq.com/operation/dianshi/other/5.ca48acfebc4dfb68c6c463c9f33e60cb8d7c9565.png',
    'https://imgcache.qq.com/operation/dianshi/other/1.724142271f4e811457eee00763e63f454af52d13.png',
    'https://imgcache.qq.com/operation/dianshi/other/4.67f22bd6d283d942d06e69c6b8a2c819c0e11af5.png',
    'https://imgcache.qq.com/operation/dianshi/other/6.1b984e741cc2275cda3451fa44515e018cc49cb5.png',
    'https://imgcache.qq.com/operation/dianshi/other/2.4c958e11852b2caa75da6c2726f9248108d6ec8a.png',
  ];
  static getRandoAvatarUrl() {
    Random rng = new Random();
    return _defaltUrlList[rng.nextInt(_defaltUrlList.length)];
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

  static Future<Null> uploadException(
      String title, //标题
      String detail, //内容
      {Map data} //data为文本附件, Android 错误分析=>跟踪数据=>extraMessage.txt
      //iOS 错误分析=>跟踪数据=>crash_attach.log
      ) {
    return FlutterBugly.uploadException(
        message: title, detail: detail, data: data);
  }
}
