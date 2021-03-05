import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './TRTCVoiceRoomDemo/ui/list/VoiceRoomList.dart';
import './TRTCVoiceRoomDemo/ui/list/VoiceRoomCreate.dart';
import 'TRTCVoiceRoomDemo/ui/room/VoiceRoomPage.dart';
import './index.dart';
import './login/LoginPage.dart';
import './TRTCVoiceRoomDemo/ui/base/UserEnum.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import './i10n/localization_intl.dart';

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
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizationsDelegate.delegate
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English
        const Locale('zh', 'CN'), // 中文简体
      ],
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
