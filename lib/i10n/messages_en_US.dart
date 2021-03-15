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

  static m0(userName) => "the topic of ${userName}s";

  static m1(memberCount) => "${memberCount} watching";

  static m2(userName) => "${userName} applies to become a speaker";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "adminLeaveRoomTips" : MessageLookupByLibrary.simpleMessage("you want to end the room?"),
    "anchor" : MessageLookupByLibrary.simpleMessage("Speakers"),
    "audience" : MessageLookupByLibrary.simpleMessage("Audiences"),
    "cancelText" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "createSalonTooltip" : MessageLookupByLibrary.simpleMessage("Create a chat salon room"),
    "defaultChatTitle" : m0,
    "errorMeetTitle" : MessageLookupByLibrary.simpleMessage("Topic is empty"),
    "errorMeetTitleLength" : MessageLookupByLibrary.simpleMessage("Topic is too long"),
    "errorMicrophonePermission" : MessageLookupByLibrary.simpleMessage("Need to obtain audio permissions to enter"),
    "errorOpenUrl" : MessageLookupByLibrary.simpleMessage("Failed to open address"),
    "errorSecretKey" : MessageLookupByLibrary.simpleMessage("Invalid secretKey "),
    "errorUserIDInput" : MessageLookupByLibrary.simpleMessage("User ID is empty"),
    "errorUserIDNumber" : MessageLookupByLibrary.simpleMessage("User ID must be number"),
    "errorUserName" : MessageLookupByLibrary.simpleMessage("Nickname or user name is empty"),
    "errorUserNameLength" : MessageLookupByLibrary.simpleMessage("Nickname or user name is too long"),
    "errorsdkAppId" : MessageLookupByLibrary.simpleMessage("Invalid appid"),
    "failEnterRoom" : MessageLookupByLibrary.simpleMessage("Enter room failed"),
    "failKickedOffline" : MessageLookupByLibrary.simpleMessage("Already logged in elsewhere, please log in again"),
    "failRefuseToSpeak" : MessageLookupByLibrary.simpleMessage("Sorry, the administrator did not agree"),
    "failRoomDestroy" : MessageLookupByLibrary.simpleMessage("The host has closed the room"),
    "hadKickMic" : MessageLookupByLibrary.simpleMessage("You have been kicked off by the administrator"),
    "helpTooltip" : MessageLookupByLibrary.simpleMessage("View documentation"),
    "iSure" : MessageLookupByLibrary.simpleMessage("Confirm"),
    "ignore" : MessageLookupByLibrary.simpleMessage("Dismiss"),
    "kickMic" : MessageLookupByLibrary.simpleMessage("Move to the audience"),
    "leaveRoomTips" : MessageLookupByLibrary.simpleMessage("You want to leave the room?"),
    "leaveTips" : MessageLookupByLibrary.simpleMessage("Leave quietly "),
    "login" : MessageLookupByLibrary.simpleMessage("Login"),
    "logout" : MessageLookupByLibrary.simpleMessage("Logout"),
    "logoutContent" : MessageLookupByLibrary.simpleMessage("Are you sure to log out?"),
    "meetTitleHintText" : MessageLookupByLibrary.simpleMessage("Please input topic"),
    "meetTitleLabel" : MessageLookupByLibrary.simpleMessage("Topic"),
    "noHadSalon" : MessageLookupByLibrary.simpleMessage("No content yet~"),
    "okText" : MessageLookupByLibrary.simpleMessage("Confirm"),
    "onLineCount" : m1,
    "raiseUpList" : MessageLookupByLibrary.simpleMessage("Raised hands"),
    "refreshReadyText" : MessageLookupByLibrary.simpleMessage("Start refresh"),
    "refreshText" : MessageLookupByLibrary.simpleMessage("Pull down to refresh"),
    "refreshedText" : MessageLookupByLibrary.simpleMessage("Refresh complete"),
    "refreshingText" : MessageLookupByLibrary.simpleMessage("loading…"),
    "salonTitle" : MessageLookupByLibrary.simpleMessage("Chat Salon"),
    "startSalon" : MessageLookupByLibrary.simpleMessage("Let’s go"),
    "successAdminEnterRoom" : MessageLookupByLibrary.simpleMessage("Host succeeded in occupying the seat"),
    "successCreateRoom" : MessageLookupByLibrary.simpleMessage("Create room success"),
    "successEnterRoom" : MessageLookupByLibrary.simpleMessage("Enter room success"),
    "successLogin" : MessageLookupByLibrary.simpleMessage("Login success"),
    "successRaiseHand" : MessageLookupByLibrary.simpleMessage("You raised your hand! We\'ll let the speakers know you want to talk~"),
    "tencentTRTC" : MessageLookupByLibrary.simpleMessage("Tencent TRTC"),
    "tipsText" : MessageLookupByLibrary.simpleMessage("Tips"),
    "titleTRTC" : MessageLookupByLibrary.simpleMessage("TRTC"),
    "trtc" : MessageLookupByLibrary.simpleMessage("TRTC"),
    "userIDHintText" : MessageLookupByLibrary.simpleMessage("Please input user ID"),
    "userIDLabel" : MessageLookupByLibrary.simpleMessage("User ID"),
    "userNameHintText" : MessageLookupByLibrary.simpleMessage("Please input user ID"),
    "userNameLabel" : MessageLookupByLibrary.simpleMessage("User ID"),
    "userRaiseHand" : m2,
    "waitTips" : MessageLookupByLibrary.simpleMessage("Wait a bit"),
    "welcome" : MessageLookupByLibrary.simpleMessage("Welcome")
  };
}
