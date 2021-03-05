import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './TRTCVoiceRoomDemo/ui/list/VoiceRoomList.dart';
import './TRTCVoiceRoomDemo/ui/list/VoiceRoomCreate.dart';
import 'TRTCVoiceRoomDemo/ui/room/VoiceRoomPage.dart';
import './index.dart';
import './login/LoginPage.dart';
import './TRTCVoiceRoomDemo/ui/base/UserEnum.dart';
import 'package:flutter_bugly/flutter_bugly.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    FlutterBugly.postCatchedException(() {
      runApp(MyApp());
    });
    FlutterBugly.init(androidAppId: "d43b0e0efa", iOSAppId: "cf07d686e1");
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/forTest",
      routes: {
        //按R，测试替换
        "/forTest": (context) => IndexPage(),
        "/": (context) => IndexPage(), //VoiceRoomListPage()
        "/index": (context) => IndexPage(), //VoiceRoomListPage()
        "/login": (context) => LoginPage(),
        "/voiceRoom/list": (context) => VoiceRoomListPage(),
        "/voiceRoom/roomCreate": (context) => VoiceRoomCreatePage(),
        "/voiceRoom/roomAnchor": (context) => VoiceRoomPage(UserType.Anchor),
        "/voiceRoom/roomAudience": (context) =>
            VoiceRoomPage(UserType.Audience),
      },
    );
  }
}
