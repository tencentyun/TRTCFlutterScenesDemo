import 'package:flutter/material.dart';
import 'package:trtc_scenes_demo/TRTCCallingDemo/model/TRTCCalling.dart';
import 'package:trtc_scenes_demo/TRTCCallingDemo/model/TRTCCallingDelegate.dart';
import 'package:trtc_scenes_demo/TRTCCallingDemo/ui/base/CallTypes.dart';
import 'package:trtc_scenes_demo/TRTCCallingDemo/ui/base/CallingScenes.dart';
import 'package:trtc_scenes_demo/debug/GenerateTestUserSig.dart';
import 'package:trtc_scenes_demo/login/ProfileManager_Mock.dart';
import 'package:trtc_scenes_demo/utils/TxUtils.dart';

class DemoSevice {
  static late TRTCCalling _tRTCCallingService;
  static late ProfileManager _profileManager;
  static late GlobalKey<NavigatorState> _navigatorKey;
  static setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  static start() async {
    _tRTCCallingService = await TRTCCalling.sharedInstance();
    _profileManager = await ProfileManager.getInstance();
    String loginId = await TxUtils.getLoginUserId();
    await _tRTCCallingService.login(GenerateTestUserSig.sdkAppId, loginId,
        await GenerateTestUserSig.genTestSig(loginId));

    _tRTCCallingService.registerListener((type, params) async {
      print("=============+++++++++++++++:" + type.toString());
      switch (type) {
        case TRTCCallingDelegate.onInvited:
          {
            BuildContext context = _navigatorKey.currentState!.overlay!.context;
            UserModel userInfo = await _profileManager
                .querySingleUserInfo(params["sponsor"].toString());
            //userInfo.avatar
            Navigator.pushReplacementNamed(
              context,
              "/calling/callingView",
              arguments: {
                "remoteUserInfo": userInfo,
                "callType": CallTypes.Type_Being_Called,
                "callingScenes": params['type'] == TRTCCalling.typeVideoCall
                    ? CallingScenes.VideoOneVOne
                    : CallingScenes.AudioOneVOne
              },
            );
          }
          break;
      }
    });
  }
}
