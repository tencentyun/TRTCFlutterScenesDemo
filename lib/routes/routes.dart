import 'package:flutter/material.dart';
import '../TRTCChatSalonDemo/ui/list/VoiceRoomList.dart';
import '../TRTCChatSalonDemo/ui/list/VoiceRoomCreate.dart';
import '../TRTCChatSalonDemo/ui/room/VoiceRoomPage.dart';
import '../index.dart';
import '../login/LoginPage.dart';
import '../TRTCChatSalonDemo/ui/base/UserEnum.dart';

final String initialRoute = "/forTest";
final Map<String, WidgetBuilder> routes = {
  //按R，测试替换
  "/forTest": (context) => IndexPage(),
  "/": (context) => IndexPage(), //VoiceRoomListPage()
  "/index": (context) => IndexPage(), //VoiceRoomListPage()
  "/login": (context) => LoginPage(),
  "/chatSalon/list": (context) => VoiceRoomListPage(),
  "/chatSalon/roomCreate": (context) => VoiceRoomCreatePage(),
  "/chatSalon/roomAnchor": (context) => VoiceRoomPage(UserType.Anchor),
  "/chatSalon/roomAudience": (context) => VoiceRoomPage(UserType.Audience),
};
