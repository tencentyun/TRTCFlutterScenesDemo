// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en_US locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en_US';

  static m0(userName) => "${userName}的主题";

  static m1(memberCount) => "${memberCount}人在线";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "cancelText" : MessageLookupByLibrary.simpleMessage("取消"),
    "createSalonTooltip" : MessageLookupByLibrary.simpleMessage("创建语音沙龙"),
    "defaultChatTitle" : m0,
    "errorMeetTitle" : MessageLookupByLibrary.simpleMessage("请输入房间主题"),
    "errorMeetTitleLength" : MessageLookupByLibrary.simpleMessage("房间主题过长，请输入合法的房间主题"),
    "errorMicrophonePermission" : MessageLookupByLibrary.simpleMessage("需要获取音视频权限才能进入"),
    "errorOpenUrl" : MessageLookupByLibrary.simpleMessage("打开地址失败"),
    "errorSecretKey" : MessageLookupByLibrary.simpleMessage("请填写密钥"),
    "errorUserIDInput" : MessageLookupByLibrary.simpleMessage("请输入用户ID"),
    "errorUserIDNumber" : MessageLookupByLibrary.simpleMessage("用户ID必须为数字"),
    "errorUserName" : MessageLookupByLibrary.simpleMessage("请输入用户名"),
    "errorUserNameLength" : MessageLookupByLibrary.simpleMessage("用户名过长，请输入合法的用户名"),
    "errorsdkAppId" : MessageLookupByLibrary.simpleMessage("请填写SDKAPPID"),
    "helpTooltip" : MessageLookupByLibrary.simpleMessage("查看说明文档"),
    "login" : MessageLookupByLibrary.simpleMessage("登录"),
    "logout" : MessageLookupByLibrary.simpleMessage("退出"),
    "logoutContent" : MessageLookupByLibrary.simpleMessage("确定退出登录吗?"),
    "meetTitleHintText" : MessageLookupByLibrary.simpleMessage("请输入房间名称"),
    "meetTitleLabel" : MessageLookupByLibrary.simpleMessage("主题"),
    "noHadSalon" : MessageLookupByLibrary.simpleMessage("暂无语音沙龙"),
    "okText" : MessageLookupByLibrary.simpleMessage("确定"),
    "onLineCount" : m1,
    "refreshReadyText" : MessageLookupByLibrary.simpleMessage("准备刷新数据"),
    "refreshText" : MessageLookupByLibrary.simpleMessage("下拉刷新"),
    "refreshedText" : MessageLookupByLibrary.simpleMessage("刷新完成"),
    "refreshingText" : MessageLookupByLibrary.simpleMessage("正在刷新中..."),
    "salonTitle" : MessageLookupByLibrary.simpleMessage("语音沙龙"),
    "startSalon" : MessageLookupByLibrary.simpleMessage("开始交谈"),
    "successLogin" : MessageLookupByLibrary.simpleMessage("登录成功"),
    "tencentTRTC" : MessageLookupByLibrary.simpleMessage("腾讯云TRTC"),
    "tipsText" : MessageLookupByLibrary.simpleMessage("提示"),
    "titleTRTC" : MessageLookupByLibrary.simpleMessage("TRTC"),
    "trtc" : MessageLookupByLibrary.simpleMessage("TRTC"),
    "userIDHintText" : MessageLookupByLibrary.simpleMessage("请输入登录的UserID"),
    "userIDLabel" : MessageLookupByLibrary.simpleMessage("用户ID"),
    "userNameHintText" : MessageLookupByLibrary.simpleMessage("请输入用户名"),
    "userNameLabel" : MessageLookupByLibrary.simpleMessage("用户名")
  };
}
