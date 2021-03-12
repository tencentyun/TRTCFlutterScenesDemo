// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a messages locale. All the
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
  String get localeName => 'messages';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "cancelText" : MessageLookupByLibrary.simpleMessage("取消"),
    "errorUserIDInput" : MessageLookupByLibrary.simpleMessage("请输入用户ID"),
    "errorUserIDNumber" : MessageLookupByLibrary.simpleMessage("用户ID必须为数字"),
    "login" : MessageLookupByLibrary.simpleMessage("登录"),
    "logout" : MessageLookupByLibrary.simpleMessage("退出"),
    "logoutContent" : MessageLookupByLibrary.simpleMessage("确定退出登录吗?"),
    "okText" : MessageLookupByLibrary.simpleMessage("确定"),
    "salonTitle" : MessageLookupByLibrary.simpleMessage("语音沙龙"),
    "successLogin" : MessageLookupByLibrary.simpleMessage("登录成功"),
    "tencentTRTC" : MessageLookupByLibrary.simpleMessage("腾讯云TRTC"),
    "tipsText" : MessageLookupByLibrary.simpleMessage("提示"),
    "titleTRTC" : MessageLookupByLibrary.simpleMessage("TRTC"),
    "trtc" : MessageLookupByLibrary.simpleMessage("TRTC"),
    "userIDHintText" : MessageLookupByLibrary.simpleMessage("请输入登录的UserID"),
    "userIDLabel" : MessageLookupByLibrary.simpleMessage("用户ID")
  };
}
