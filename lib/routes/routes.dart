import 'package:flutter/material.dart';
import '../TRTCChatSalonDemo/ui/list/VoiceRoomList.dart';
import '../TRTCChatSalonDemo/ui/list/VoiceRoomCreate.dart';
import '../TRTCChatSalonDemo/ui/room/VoiceRoomPage.dart';
import '../index.dart';
import '../login/LoginPage.dart';
import '../TRTCChatSalonDemo/ui/base/UserEnum.dart';
import '../TRTCCallingDemo/ui/TRTCCallingContact.dart';
import '../TRTCCallingDemo/ui/AudioCall/TRTCCallingAudio.dart';
import '../TRTCCallingDemo/ui/VideoCall/TRTCCallingVideo.dart';

final String initialRoute = "/forTest";
final Map<String, WidgetBuilder> routes = {
  "/": (context) => IndexPage(),
  "/index": (context) => IndexPage(),
  "/login": (context) => LoginPage(),
  "/chatSalon/list": (context) => VoiceRoomListPage(),
  "/chatSalon/roomCreate": (context) => VoiceRoomCreatePage(),
  "/chatSalon/roomAnchor": (context) => VoiceRoomPage(UserType.Anchor),
  "/chatSalon/roomAudience": (context) => VoiceRoomPage(UserType.Audience),
  "/calling/videoContact": (context) =>
      TRTCCallingContact(CallingScenes.VideoOneVOne),
  "/calling/audioContact": (context) =>
      TRTCCallingContact(CallingScenes.AudioOneVOne),
  "/calling/audioCall": (context) => TRTCCallingAudio(),
  "/calling/videoCall": (context) => TRTCCallingVideo(),
};
