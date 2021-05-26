import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:trtc_scenes_demo/TRTCCallingDemo/model/TRTCCalling.dart';
import 'package:trtc_scenes_demo/TRTCCallingDemo/model/TRTCCallingDelegate.dart';
import 'package:trtc_scenes_demo/TRTCCallingDemo/ui/base/CallTypes.dart';
import 'package:trtc_scenes_demo/TRTCCallingDemo/ui/base/CallingScenes.dart';
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
  CallStatus _currentCallStatus = CallStatus.calling;
  CallTypes _currentCallType = CallTypes.Type_Call_Someone;
  CallingScenes _callingScenes = CallingScenes.AudioOneVOne;
  //已经通话时长
  String _hadCallingTime = "00:00";
  late DateTime _startAnswerTime;
  bool _isCameraOff = false;
  bool _isHandsFree = true;
  bool _isMicrophoneOff = false;
  bool _isFrontCamera = true;
  late int _bigVideoViewId;
  Timer? _hadCalledCalcTimer;

  late int _smallVideoViewId;
  double _smallViewTop = 64;
  double _smallViewRight = 20;
  //为false的时候，在已接听状态的时候。小画面显示本地视频，大画面显示远端视频。
  bool isChangeBigSmallVideo = false;
  UserModel? _remoteUserInfo;
  //远端画面可见不可见
  bool _remoteUserAvailable = true;

  late TRTCCalling _tRTCCallingService;

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
    _tRTCCallingService.registerListener(onRtcListener);
  }

  onRtcListener(type, params) {
    switch (type) {
      case TRTCCallingDelegate.onError:
        showMessageTips("发生错误:" + params['errCode'] + "," + params['errMsg'],
            stopCameraAndFinish);
        break;
      case TRTCCallingDelegate.onWarning:
        print('onWarning:warning code = ' +
            params['warningCode'] +
            " ,warning msg = " +
            params['warningMsg']);
        break;
      case TRTCCallingDelegate.onUserEnter:
        handleOnUserAnswer();
        break;
      case TRTCCallingDelegate.onUserLeave:
        showMessageTips("用户离开了", stopCameraAndFinish);
        break;
      case TRTCCallingDelegate.onReject:
        showMessageTips("拒绝通话", stopCameraAndFinish);
        break;
      case TRTCCallingDelegate.onNoResp:
        showMessageTips("无响应", stopCameraAndFinish);
        break;
      case TRTCCallingDelegate.onLineBusy:
        showMessageTips("忙线", stopCameraAndFinish);
        break;
      case TRTCCallingDelegate.onCallingCancel:
        showMessageTips("取消了通话", stopCameraAndFinish);
        break;
      case TRTCCallingDelegate.onCallingTimeout:
        showMessageTips("本次通话超时未应答", stopCameraAndFinish);
        break;
      case TRTCCallingDelegate.onCallEnd:
        showMessageTips("结束通话", stopCameraAndFinish);
        break;
      case TRTCCallingDelegate.onUserVideoAvailable:
        handleOnUserVideoAvailable(params);
        break;
      case TRTCCallingDelegate.onKickedOffline:
        showMessageTips("你被踢下线了", stopCameraAndFinish);
        break;
    }
  }

  initRemoteInfo() async {
    Map arguments = ModalRoute.of(context)!.settings.arguments! as Map;
    safeSetState(() {
      _remoteUserInfo = arguments['remoteUserInfo'] as UserModel;
      _currentCallType = arguments["callType"] as CallTypes;
      _callingScenes = arguments['callingScenes'] as CallingScenes;
      Future.delayed(Duration(microseconds: 100), () {
        if (_currentCallType == CallTypes.Type_Call_Someone) {
          _tRTCCallingService.call(
              _remoteUserInfo!.userId,
              _callingScenes == CallingScenes.VideoOneVOne
                  ? TRTCCalling.typeVideoCall
                  : TRTCCalling.typeAudioCall);
        }
      });
    });
  }

  //用户接听
  handleOnUserAnswer() async {
    //await _tRTCCallingService.closeCamera();
    if (_remoteUserInfo != null) {
      _startAnswerTime = DateTime.now();
      safeSetState(() async {
        _currentCallStatus = CallStatus.answer;
        _hadCallingTime = "00:00";
        await _tRTCCallingService.startRemoteView(
          _remoteUserInfo!.userId,
          TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL,
          _bigVideoViewId,
        );
      });
      this._callIngTimeUpdate();
    }
  }

  handleOnUserVideoAvailable(params) async {
    if (_remoteUserInfo != null &&
        params["userId"].toString() == _remoteUserInfo!.userId) {
      safeSetState(() {
        _remoteUserAvailable = params["available"] as bool;
      });
    }
  }

  showMessageTips(String msg, Function callback) {
    TxUtils.showErrorToast(msg, context);
    Future.delayed(Duration(seconds: 1), () {
      callback();
    });
  }

  stopCameraAndFinish() {
    _tRTCCallingService.setMicMute(true);
    _tRTCCallingService.closeCamera();
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          "/index",
        );
      }
    });
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
    _hadCalledCalcTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      DateTime now = DateTime.now();
      Duration duration = now.difference(_startAnswerTime);
      safeSetState(() {
        _hadCallingTime = _getDurationTimeString(duration);
      });
    });
  }

  double _getOpacityByVis(bool vis) {
    return vis ? 1.0 : 0;
  }

  safeSetState(callBack) {
    setState(() {
      if (mounted) {
        callBack();
      }
    });
  }

  @override
  dispose() {
    if (_hadCalledCalcTimer != null) {
      _hadCalledCalcTimer!.cancel();
    }
    _tRTCCallingService.unRegisterListener(onRtcListener);
    super.dispose();
  }

  //前后摄像头切换
  onSwitchCamera() {
    _tRTCCallingService.switchCamera(!_isFrontCamera);
    safeSetState(() {
      _isFrontCamera = !_isFrontCamera;
    });
  }

  //麦克风启用禁用
  onMicrophoneTap() {
    _tRTCCallingService.setMicMute(!_isMicrophoneOff);
    setState(() {
      _isMicrophoneOff = !_isMicrophoneOff;
    });
  }

  //摄像头启用禁用
  onCameraTap() async {
    if (!_isCameraOff) {
      await _tRTCCallingService.closeCamera();
    } else {
      //为false的时候，在已接听状态的时候。小画面显示本地视频，大画面显示远端视频。
      if (isChangeBigSmallVideo) {
        await _tRTCCallingService.openCamera(_isFrontCamera, _bigVideoViewId);
      } else {
        await _tRTCCallingService.openCamera(_isFrontCamera, _smallVideoViewId);
      }
    }
    safeSetState(() {
      _isCameraOff = !_isCameraOff;
    });
  }

  //扬声器是否禁用
  onHandsfreeTap() {
    _tRTCCallingService.setHandsFree(!_isHandsFree);
    setState(() {
      _isHandsFree = !_isHandsFree;
    });
  }

  onSwitchAudioTap() {
    //先不支持切到语音通话
    _tRTCCallingService.closeCamera();
    safeSetState(() {
      _callingScenes = CallingScenes.AudioOneVOne;
    });
  }

  //挂断
  onHangUpCall() async {
    _tRTCCallingService.closeCamera();
    if (_currentCallType == CallTypes.Type_Being_Called &&
        _currentCallStatus == CallStatus.calling) {
      await _tRTCCallingService.reject();
    } else {
      await _tRTCCallingService.hangup();
    }
    Navigator.pushReplacementNamed(
      context,
      "/index",
    );
  }

  //接听
  onAcceptCall() async {
    await _tRTCCallingService.closeCamera();
    await _tRTCCallingService.accept();
    safeSetState(() {
      _currentCallStatus = CallStatus.answer;
    });
  }

  getTopBarWidget() {
    bool isCalling = _currentCallStatus == CallStatus.calling ? true : false;
    var topWidget = Positioned(
      left: 0,
      top: _callingScenes == CallingScenes.VideoOneVOne ? 64 : 185,
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
                        fontWeight: FontWeight.bold,
                      ),
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
            : _callingScenes == CallingScenes.VideoOneVOne
                ? [
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
                  ]
                : [
                    //1V1语音通话显示名字
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _remoteUserInfo != null
                              ? _remoteUserInfo!.name
                              : "--",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
      ),
    );
    return topWidget;
  }

  getButtomWidget() {
    var callSomeBtnList = [
      _currentCallStatus == CallStatus.answer
          ? ExtendButton(
              imgUrl: _isMicrophoneOff
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
      _currentCallStatus == CallStatus.answer
          ? ExtendButton(
              imgUrl: _callingScenes == CallingScenes.VideoOneVOne
                  ? _isCameraOff
                      ? "assets/images/callingDemo/camera-off.png"
                      : "assets/images/callingDemo/camera-on.png"
                  : _isHandsFree
                      ? "assets/images/callingDemo/trtccalling_ic_handsfree_enable.png"
                      : "assets/images/callingDemo/trtccalling_ic_handsfree_disable.png",
              tips:
                  _callingScenes == CallingScenes.VideoOneVOne ? "摄像头" : "扬声器",
              onTap: () {
                if (_callingScenes == CallingScenes.VideoOneVOne)
                  onCameraTap();
                else
                  onHandsfreeTap();
              },
            )
          : Spacer(),
    ];
    if (_currentCallType == CallTypes.Type_Being_Called &&
        _currentCallStatus == CallStatus.calling) {
      callSomeBtnList.insert(
        2,
        Spacer(),
      );
      callSomeBtnList.insert(
        3,
        ExtendButton(
          imgUrl: "assets/images/callingDemo/trtccalling_ic_dialing.png",
          tips: "接听",
          onTap: () {
            onAcceptCall();
          },
        ),
      );
    }
    var buttomWidget = Positioned(
      left: 0,
      bottom: 50,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 20),
            child: _currentCallStatus == CallStatus.answer
                ? Text(
                    '$_hadCallingTime',
                    style: TextStyle(color: Colors.white),
                  )
                :
                // _callingScenes == CallingScenes.VideoOneVOne
                //     ? ExtendButton(
                //         imgUrl: "assets/images/callingDemo/switchToAudio.png",
                //         imgHieght: 18,
                //         imgColor: Color.fromRGBO(125, 123, 123, 1.0),
                //         tips: "切到语音通话",
                //         onTap: () {
                //           onSwitchAudioTap();
                //         },
                //       ):
                Spacer(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: callSomeBtnList,
          )
        ],
      ),
    );
    return buttomWidget;
  }

  getBigVideo() {
    if (_callingScenes == CallingScenes.AudioOneVOne) return Container();
    bool nowIsLocalView = true; //判断当前大窗口是否显示本地摄像头
    if (_currentCallStatus == CallStatus.calling)
      nowIsLocalView = true;
    else {
      //已经接听
      if (isChangeBigSmallVideo) {
        nowIsLocalView = true;
      } else {
        nowIsLocalView = false; //远端画面
      }
    }
    return _callingScenes == CallingScenes.VideoOneVOne
        ? AnimatedOpacity(
            duration: Duration(milliseconds: 100),
            opacity: nowIsLocalView
                ? _getOpacityByVis(!_isCameraOff)
                : _getOpacityByVis(_remoteUserAvailable),
            child: TRTCCloudVideoView(
              key: ValueKey("_bigVideoViewId"),
              viewType: TRTCCloudDef.TRTC_VideoView_SurfaceView,
              onViewCreated: (viewId) async {
                _bigVideoViewId = viewId;
                if (_callingScenes == CallingScenes.VideoOneVOne) {
                  await _tRTCCallingService.openCamera(
                      _isFrontCamera, _bigVideoViewId);
                }
              },
            ),
          )
        : Container();
  }

  getSmallVideoContainer() {
    if (_callingScenes == CallingScenes.AudioOneVOne) {
      return Container(
        height: 100,
        width: 100,
        child: Container(),
        decoration: _remoteUserInfo != null
            ? BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_remoteUserInfo!.avatar),
                  fit: BoxFit.cover,
                ),
              )
            : BoxDecoration(),
      );
    }
    bool nowIsRemoteView = false; //判断当前小窗口是否显示远端画面
    if (_currentCallStatus == CallStatus.calling)
      nowIsRemoteView = true;
    else {
      //已经接听
      if (isChangeBigSmallVideo) {
        nowIsRemoteView = true;
      } else {
        nowIsRemoteView = false; //本地摄像头
      }
    }
    return Container(
      height: _currentCallStatus == CallStatus.calling ? 100 : 216,
      width: 100,
      child: _currentCallStatus == CallStatus.answer
          ? AnimatedOpacity(
              duration: Duration(milliseconds: 100),
              opacity: nowIsRemoteView
                  ? _getOpacityByVis(_remoteUserAvailable)
                  : _getOpacityByVis(!_isCameraOff),
              child: TRTCCloudVideoView(
                key: ValueKey("_smallVideoViewId"),
                viewType: TRTCCloudDef.TRTC_VideoView_SurfaceView,
                onViewCreated: (viewId) async {
                  _smallVideoViewId = viewId;
                  await _tRTCCallingService.closeCamera();
                  await _tRTCCallingService.openCamera(
                      _isFrontCamera, _smallVideoViewId);
                },
              ),
            )
          : Container(),
      decoration:
          _remoteUserInfo != null && _currentCallStatus == CallStatus.calling
              ? BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(_remoteUserInfo!.avatar),
                    fit: BoxFit.cover,
                  ),
                )
              : BoxDecoration(),
    );
  }

  changeVideoView() {
    if (_callingScenes == CallingScenes.AudioOneVOne ||
        _currentCallStatus == CallStatus.calling) return;

    setState(() async {
      isChangeBigSmallVideo = !isChangeBigSmallVideo;
      //为false的时候，在已接听状态的时候。小画面显示本地视频，大画面显示远端视频。
      if (isChangeBigSmallVideo) {
        await _tRTCCallingService.closeCamera();
        await _tRTCCallingService.openCamera(_isFrontCamera, _bigVideoViewId);
        await _tRTCCallingService.startRemoteView(_remoteUserInfo!.userId,
            TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL, _smallVideoViewId);
      } else {
        await _tRTCCallingService.closeCamera();
        await _tRTCCallingService.openCamera(_isFrontCamera, _smallVideoViewId);
        await _tRTCCallingService.startRemoteView(_remoteUserInfo!.userId,
            TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL, _bigVideoViewId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var remotePanel = Positioned(
        top: _smallViewTop,
        right: _callingScenes == CallingScenes.VideoOneVOne
            ? _smallViewRight
            : MediaQuery.of(context).size.width / 2 - 100 / 2,
        child: GestureDetector(
          onDoubleTap: () {
            changeVideoView();
          },
          onPanUpdate: (DragUpdateDetails e) {
            //用户手指滑动时，更新偏移，重新构建
            if (_callingScenes == CallingScenes.VideoOneVOne) {
              safeSetState(() {
                _smallViewRight -= e.delta.dx;
                _smallViewTop += e.delta.dy;
              });
            }
          },
          child: getSmallVideoContainer(),
        ));
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
              color: Color.fromRGBO(
                  93, 91, 90, 1), //Color.fromRGBO(242, 243, 248, 1),
              child: getBigVideo(),
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
