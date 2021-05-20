import 'package:flutter/material.dart';
import 'package:trtc_scenes_demo/TRTCCallingDemo/model/TRTCCalling.dart';
import 'package:trtc_scenes_demo/TRTCCallingDemo/model/TRTCCallingDelegate.dart';
import 'package:trtc_scenes_demo/TRTCCallingDemo/ui/base/CallTypes.dart';
import 'package:trtc_scenes_demo/debug/GenerateTestUserSig.dart';
import 'package:trtc_scenes_demo/login/ProfileManager_Mock.dart';
import 'package:trtc_scenes_demo/utils/TxUtils.dart';

class DemoSevice {
  static late TRTCCalling _tRTCCallingService;
  static late ProfileManager _profileManager;
  static start(GlobalKey<NavigatorState> navigatorKey) async {
    _tRTCCallingService = await TRTCCalling.sharedInstance();
    _profileManager = await ProfileManager.getInstance();
    String loginId = await TxUtils.getLoginUserId();
    await _tRTCCallingService.login(GenerateTestUserSig.sdkAppId, loginId,
        await GenerateTestUserSig.genTestSig(loginId));
    _tRTCCallingService.registerListener((type, params) async {
      switch (type) {
        case TRTCCallingDelegate.onInvited:
          {
            BuildContext context = navigatorKey.currentState!.overlay!.context;
            UserModel userInfo = await _profileManager
                .querySingleUserInfo(params["inviter"].toString());
            //userInfo.avatar
            Navigator.pushReplacementNamed(
              context,
              "/calling/videoCall",
              arguments: {
                "remoteUserInfo": userInfo,
                "callType": CallTypes.Type_Being_Called
              },
            );
          }
          break;
      }
    });
  }
}
