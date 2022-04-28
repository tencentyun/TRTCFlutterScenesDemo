import 'package:flutter/material.dart';
import 'package:trtc_scenes_demo/TRTCCallingDemo/ui/base/CallingScenes.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/ui/list/LiveRoomList.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/ui/room/LiveRoomPage.dart';
import '../TRTCChatSalonDemo/ui/list/VoiceRoomList.dart';
import '../TRTCChatSalonDemo/ui/list/VoiceRoomCreate.dart';
import '../TRTCChatSalonDemo/ui/room/VoiceRoomPage.dart';
import '../index.dart';
import '../login/LoginPage.dart';
import '../TRTCChatSalonDemo/ui/base/UserEnum.dart';
import '../TRTCCallingDemo/ui/TRTCCallingContact.dart';
import '../TRTCCallingDemo/ui/VideoCall/TRTCCallingVideo.dart';
import '../TRTCMeetingDemo/ui/TRTCMeetingIndex.dart';
import '../TRTCMeetingDemo/ui/TRTCMeetingRoom.dart';

final String initialRoute = "/";
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
  "/calling/callingView": (context) => TRTCCallingVideo(),
  "/liveRoom/roomAudience": (context) => LiveRoomPage(isAdmin: false),
  "/liveRoom/roomAnchor": (context) => LiveRoomPage(isAdmin: true),
  "/liveRoom/list": (context) => LiveRoomListPage(),
  "/meeting/meetingIndex": (context) => TRTCMeetingIndex(),
  "/meeting/meetingRoom": (context) => TRTCMeetingRoom(),
};
