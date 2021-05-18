import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:trtc_scenes_demo/TRTCCallingDemo/model/TRTCCalling.dart';
import 'package:trtc_scenes_demo/TRTCCallingDemo/model/TRTCCallingDelegate.dart';
import 'package:trtc_scenes_demo/login/ProfileManager_Mock.dart';
import 'package:trtc_scenes_demo/utils/TxUtils.dart';
import 'dart:async';
import '../base/ExtendButton.dart';
import '../base/CallStatus.dart';

class TRTCCallingVideo extends StatefulWidget {
  @override
  _TRTCCallingVideoState createState() => _TRTCCallingVideoState();
}

class _TRTCCallingVideoState extends State<TRTCCallingVideo> {
  CallStatus currentCallStatus = CallStatus.calling;
  //已经通话时长
  String hadCallingTime = "00:00";
  late DateTime startAnswerTime;
  bool isCameraOff = false;
  bool isMicrophoneOff = false;
  bool isFrontCamera = true;

  double _remoteTop = 64;
  double _remoteRight = 20;
  UserModel? _remoteUserInfo;

  late TRTCCalling _tRTCCallingService;
  late int _currentUserViewId;
  Timer? _calTimer;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      this.initRemoteInfo();
    });
    initTrtc();
  }

  initTrtc() async {
    _tRTCCallingService = await TRTCCalling.sharedInstance();
    _tRTCCallingService.registerListener((type, params) {
      switch (type) {
        case TRTCCallingDelegate.onError:
          break;
        case TRTCCallingDelegate.onWarning:
          // TODO: Handle this case.
          break;
        case TRTCCallingDelegate.onEnterRoom:
          // TODO: Handle this case.
          break;
        case TRTCCallingDelegate.onUserEnter:
          // TODO: Handle this case.
          break;
        case TRTCCallingDelegate.onUserLeave:
          // TODO: Handle this case.
          break;
        case TRTCCallingDelegate.onGroupCallInviteeListUpdate:
          // TODO: Handle this case.
          break;
        case TRTCCallingDelegate.onInvited:
          // TODO: Handle this case.
          break;
        case TRTCCallingDelegate.onReject:
          // TODO: Handle this case.
          break;
        case TRTCCallingDelegate.onNoResp:
          // TODO: Handle this case.
          break;
        case TRTCCallingDelegate.onLineBusy:
          // TODO: Handle this case.
          break;
        case TRTCCallingDelegate.onCallingCancel:
          // TODO: Handle this case.
          break;
        case TRTCCallingDelegate.onCallingTimeout:
          // TODO: Handle this case.
          break;
        case TRTCCallingDelegate.onCallEnd:
          // TODO: Handle this case.
          break;
        case TRTCCallingDelegate.onUserVideoAvailable:
          // TODO: Handle this case.
          break;
        case TRTCCallingDelegate.onUserAudioAvailable:
          // TODO: Handle this case.
          break;
        case TRTCCallingDelegate.onUserVolumeUpdate:
          // TODO: Handle this case.
          break;
        case TRTCCallingDelegate.onKickedOffline:
          // TODO: Handle this case.
          break;
      }
    });
  }

  initRemoteInfo() async {
    Map arguments = ModalRoute.of(context)!.settings.arguments! as Map;
    setState(() {
      _remoteUserInfo = arguments['remoteUserInfo'] as UserModel;
    });
  }

  //用户接听
  handleOnUserAnswer() {
    startAnswerTime = DateTime.now();
    setState(() {
      currentCallStatus = CallStatus.answer;
      hadCallingTime = "00:00";
    });
    this._callIngTimeUpdate();
  }

  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  _getDurationTimeString(Duration duration) {
    String line = "";
    if (duration.inHours != 0) {
      line = _twoDigits(duration.inHours.remainder(24)) + ":";
    }
    line = line + _twoDigits(duration.inMinutes.remainder(60)) + ":";
    line = line + _twoDigits(duration.inSeconds.remainder(60));
    return line;
  }

  _callIngTimeUpdate() {
    _calTimer = Timer.periodic(Duration(seconds: 1000), (Timer timer) {
      DateTime now = DateTime.now();
      Duration duration = now.difference(startAnswerTime);
      setState(() {
        hadCallingTime = _getDurationTimeString(duration);
      });
    });
  }

  @override
  dispose() {
    _tRTCCallingService.unRegisterListener((type, params) {});
    super.dispose();
  }

  //前后摄像头切换
  onSwitchCamera() {
    _tRTCCallingService.switchCamera(!isFrontCamera);
    setState(() {
      isFrontCamera = !isFrontCamera;
    });
  }

  //麦克风启用禁用
  onMicrophoneTap() {
    setState(() {
      isMicrophoneOff = !isMicrophoneOff;
    });
  }

  //摄像头启用禁用
  onCameraTap() {
    setState(() {
      isCameraOff = !isCameraOff;
    });
  }

  //挂断
  onHangUpCall() {
    Navigator.pushReplacementNamed(
      context,
      "/calling/videoContact",
    );
  }

  getTopBarWidget() {
    bool isCalling = currentCallStatus == CallStatus.calling ? true : false;
    var topWidget = Positioned(
      left: 0,
      top: 64,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: isCalling
            ? [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _remoteUserInfo != null ? _remoteUserInfo!.name : "--",
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '正在等待对方接受邀请…',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                )
              ]
            : [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        left: 20,
                      ),
                      decoration: BoxDecoration(),
                      child: InkWell(
                        onTap: () {
                          onSwitchCamera();
                        },
                        child: Image.asset(
                          'assets/images/callingDemo/switch-camera.png',
                          height: 32,
                          color: Color.fromRGBO(125, 123, 123, 1.0),
                        ),
                      ),
                    )
                  ],
                )
              ],
      ),
    );
    return topWidget;
  }

  getButtomWidget() {
    var buttomWidget = Positioned(
      left: 0,
      bottom: 50,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 20),
            child: currentCallStatus == CallStatus.answer
                ? Text(
                    '$hadCallingTime',
                    style: TextStyle(color: Colors.white),
                  )
                : Spacer(),
            // ExtendButton(
            //     imgUrl: "assets/images/callingDemo/switchToAudio.png",
            //     imgHieght: 18,
            //     imgColor: Color.fromRGBO(125, 123, 123, 1.0),
            //     tips: "切到语音通话",
            //     onTap: () {},
            //   ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              currentCallStatus == CallStatus.answer
                  ? ExtendButton(
                      imgUrl: isMicrophoneOff
                          ? "assets/images/callingDemo/microphone-off.png"
                          : "assets/images/callingDemo/microphone-on.png",
                      tips: "麦克风",
                      onTap: () {
                        onMicrophoneTap();
                      },
                    )
                  : Spacer(),
              ExtendButton(
                imgUrl: "assets/images/callingDemo/hangup.png",
                tips: "挂断",
                onTap: () {
                  onHangUpCall();
                },
              ),
              currentCallStatus == CallStatus.answer
                  ? ExtendButton(
                      imgUrl: isCameraOff
                          ? "assets/images/callingDemo/camera-off.png"
                          : "assets/images/callingDemo/camera-on.png",
                      tips: "摄像头",
                      onTap: () {
                        onCameraTap();
                      },
                    )
                  : Spacer(),
            ],
          )
        ],
      ),
    );
    return buttomWidget;
  }

  @override
  Widget build(BuildContext context) {
    var remotePanel = Positioned(
      top: _remoteTop,
      right: _remoteRight,
      child: GestureDetector(
        onDoubleTap: () {
          //放大
        },
        onPanUpdate: (DragUpdateDetails e) {
          //用户手指滑动时，更新偏移，重新构建
          setState(() {
            _remoteRight -= e.delta.dx;
            _remoteTop += e.delta.dy;
          });
        },
        child: Container(
          height: currentCallStatus == CallStatus.calling ? 100 : 216,
          width: 100,
          decoration: _remoteUserInfo != null
              ? BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(_remoteUserInfo!.avatar),
                    fit: BoxFit.cover,
                  ),
                )
              : BoxDecoration(),
          //child: Text('_remote user'),
        ),
      ),
    );
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Stack(
          alignment: Alignment.topLeft,
          fit: StackFit.expand,
          children: [
            Container(
              color: Color.fromRGBO(93, 91, 90, 1),
              child: TRTCCloudVideoView(
                key: ValueKey("_currentUserViewId"),
                viewType: TRTCCloudDef.TRTC_VideoView_SurfaceView,
                onViewCreated: (viewId) {
                  _currentUserViewId = viewId;
                  _tRTCCallingService.openCamera(
                      isFrontCamera, _currentUserViewId);
                  Future.delayed(Duration(microseconds: 200), () {
                    _tRTCCallingService.call(_remoteUserInfo!.userId, 2);
                  });
                },
              ),
            ),
            remotePanel,
            getTopBarWidget(),
            getButtomWidget(),
          ],
        ),
      ),
    );
  }
}
