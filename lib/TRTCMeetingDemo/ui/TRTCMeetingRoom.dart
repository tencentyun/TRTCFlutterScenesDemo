import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:replay_kit_launcher/replay_kit_launcher.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:tencent_trtc_cloud/tx_beauty_manager.dart';
import 'package:trtc_scenes_demo/TRTCMeetingDemo/model/TRTCMeetingDelegate.dart';
import 'package:trtc_scenes_demo/debug/GenerateTestUserSig.dart';
import 'package:trtc_scenes_demo/i10n/localization_intl.dart';
import 'package:trtc_scenes_demo/utils/TxUtils.dart';
import '../model/TRTCMeeting.dart';
import './TRTCMeetingMemberList.dart';
import './TRTCMeetingSetting.dart';
import './TRTCMeetingTools.dart';

const iosAppGroup = 'group.com.tencent.trtc.scenes.demo.ios';
const iosExtensionName = 'upload';
const defaultViewSize = Size(0.0, 0.0);

class MyInfo {
  String userId;
  String userSig;
  MyInfo({this.userId = '', this.userSig = ''});
}

class UserInfo {
  String userId;
  String type;
  bool visible;
  bool audioMuted;
  bool videoMuted;
  Size size;
  UserInfo(
      {this.userId = '',
      this.type = 'empty',
      this.visible = false,
      this.audioMuted = false,
      this.videoMuted = false,
      this.size = defaultViewSize});
}

class TRTCMeetingRoom extends StatefulWidget {
  TRTCMeetingRoom({Key? key}) : super(key: key);

  @override
  TRTCMeetingRoomState createState() => TRTCMeetingRoomState();
}

class TRTCMeetingRoomState extends State<TRTCMeetingRoom> {
  String _meetingNumber = '';
  bool _enabledCamera = true;
  bool _enabledMicrophone = true;
  bool _enabledFrontCamera = true;
  bool _enabledSpeak = true;
  bool _isShareWindow = false;
  bool _isDoubleTap = false;
  String _doubleUserId = '';
  String _doubleUserIdType = '';
  String _curBeauty = 'pitu';
  Map<String, int> _beautyMap = {
    'smooth': 4,
    'nature': 4,
    'pitu': 4,
    'whitening': 1,
    'ruddy': 0
  };
  List<UserInfo> _userList = [];
  List<List<UserInfo>> _screenUserList = [];
  List viewList = [];
  int? _localViewId;

  late MyInfo myInfo;
  late TRTCMeeting trtcMeeting;
  late TXBeautyManager txBeautyManager;
  late ScrollController scrollController;

  @override
  initState() {
    super.initState();
    myInfo = MyInfo(userId: '', userSig: '');
    Future.delayed(Duration.zero, () {
      initRemoteInfo();
      initRoom();
    });
    initScrollListener();
  }

  initRemoteInfo() {
    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    setState(() {
      _meetingNumber = arguments['meetingNumber'];
      _enabledCamera = arguments['enabledCamera'];
      _enabledMicrophone = arguments['enabledMicrophone'];
    });
  }

  initRoom() async {
    myInfo.userId = await TxUtils.getLoginUserId();
    trtcMeeting = await TRTCMeeting.sharedInstance();
    txBeautyManager = trtcMeeting.getBeautyManager();
    trtcMeeting.registerListener(onListener);

    enterMeeting();
    initData();

    txBeautyManager.setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_PITU);
    txBeautyManager.setBeautyLevel(_beautyMap[_curBeauty]!);
    txBeautyManager.setWhitenessLevel(_beautyMap['whitening']!);
    txBeautyManager.setRuddyLevel(_beautyMap['ruddy']!);
  }

  enterMeeting() async {
    myInfo.userSig = await GenerateTestUserSig.genTestSig(myInfo.userId);
    await trtcMeeting.login(
      GenerateTestUserSig.sdkAppId,
      myInfo.userId,
      myInfo.userSig,
    );
    trtcMeeting.createMeeting(int.parse(_meetingNumber));
  }

  initData() async {
    _userList.add(UserInfo(
      userId: myInfo.userId,
      type: _enabledCamera ? 'video' : 'empty',
      visible: _enabledCamera,
      audioMuted: false,
      videoMuted: false,
      size: defaultViewSize,
    ));

    if (_enabledMicrophone) {
      await trtcMeeting.startMicrophone();
    }

    _screenUserList = TRTCMeetingTools.getScreenList(_userList);
    setState(() {
      _userList = _userList;
      _screenUserList = _screenUserList;
    });
  }

  initScrollListener() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      var firstScreen = _screenUserList[0];

      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        for (var i = 1; i < firstScreen.length; i++) {
          if (i != 0) {
            trtcMeeting.stopRemoteView(
              firstScreen[i].userId,
              TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
            );
          }
        }
      } else if (scrollController.offset <=
              scrollController.position.minScrollExtent &&
          !scrollController.position.outOfRange) {
        for (var i = 1; i < firstScreen.length; i++) {
          if (i != 0) {
            trtcMeeting.startRemoteView(
              firstScreen[i].userId,
              TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
              viewList[i],
            );
          }
        }
      }
    });
  }

  @override
  dispose() {
    leaveMeeting();
    scrollController.dispose();
    super.dispose();
  }

  leaveMeeting() {
    trtcMeeting.unRegisterListener(onListener);
    trtcMeeting.leaveMeeting();
  }

  onListener(TRTCMeetingDelegate type, param) async {
    switch (type) {
      case TRTCMeetingDelegate.onError:
        if (param['errCode'] == -1308) {
          TxUtils.showStyledToast(
              Languages.of(context)!.failShareScreen, context);
          await stopShareScreen();
        } else {
          showErrorDialog(param['errMsg']);
        }
        break;

      case TRTCMeetingDelegate.onScreenCaptureStarted:
        TxUtils.showStyledToast(
            Languages.of(context)!.meetingShareScreenStarted, context);
        break;
      case TRTCMeetingDelegate.onScreenCapturePaused:
        TxUtils.showStyledToast(
            Languages.of(context)!.meetingShareScreenPaused, context);
        break;
      case TRTCMeetingDelegate.onScreenCaptureResumed:
        TxUtils.showStyledToast(
            Languages.of(context)!.meetingShareScreenResumed, context);
        break;
      case TRTCMeetingDelegate.onScreenCaptureStoped:
        TxUtils.showStyledToast(
            Languages.of(context)!.meetingShareScreenStoped, context);
        break;

      case TRTCMeetingDelegate.onEnterRoom:
        if (param > 0)
          TxUtils.showStyledToast(
              Languages.of(context)!.meetingEnterRoomSuccess, context);
        break;
      case TRTCMeetingDelegate.onLeaveRoom:
        if (param > 0)
          TxUtils.showStyledToast(
              Languages.of(context)!.meetingExitRoomSuccess, context);
        break;

      case TRTCMeetingDelegate.onUserEnterRoom:
        _userList.add(UserInfo(
          userId: param,
          type: 'empty',
          visible: false,
          audioMuted: false,
          videoMuted: false,
          size: defaultViewSize,
        ));
        _screenUserList = TRTCMeetingTools.getScreenList(_userList);
        setState(() {
          _userList = _userList;
          _screenUserList = _screenUserList;
        });
        break;
      case TRTCMeetingDelegate.onUserLeaveRoom:
        String userId = param['userId'];

        for (var i = 0; i < _userList.length; i++) {
          if (_userList[i].userId == userId) _userList.removeAt(i);
        }

        if (_doubleUserId == userId) {
          _isDoubleTap = false;
          _doubleUserId = '';
          _doubleUserIdType = '';
        }

        _screenUserList = TRTCMeetingTools.getScreenList(_userList);
        setState(() {
          _isDoubleTap = _isDoubleTap;
          _doubleUserId = _doubleUserId;
          _doubleUserIdType = _doubleUserIdType;
          _userList = _userList;
          _screenUserList = _screenUserList;
        });
        break;

      case TRTCMeetingDelegate.onUserVideoAvailable:
        String userId = param['userId'];

        for (var i = 0; i < _userList.length; i++) {
          if (_userList[i].userId == userId) {
            if (!param['available']) {
              if (_isDoubleTap &&
                  _doubleUserId == userId &&
                  _doubleUserIdType == 'video') {
                onDoubleTap(_userList[i]);
              }
            }
            _userList[i].type = param['available'] ? 'video' : 'empty';
            _userList[i].visible = param['available'];
          }
        }

        if (!param['available']) {
          trtcMeeting.stopRemoteView(
            userId,
            TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
          );
        }

        _screenUserList = TRTCMeetingTools.getScreenList(_userList);
        setState(() {
          _userList = _userList;
          _screenUserList = _screenUserList;
        });
        break;
      case TRTCMeetingDelegate.onUserSubStreamAvailable:
        String userId = param['userId'];

        for (var i = 0; i < _userList.length; i++) {
          if (_userList[i].userId == userId) {
            if (!param['available']) {
              if (_isDoubleTap &&
                  _doubleUserId == userId &&
                  _doubleUserIdType == 'subStream') {
                onDoubleTap(_userList[i]);
              }
            }
            _userList[i].type = param['available'] ? 'subStream' : 'empty';
            _userList[i].visible = param['available'];
          }
        }

        if (!param['available']) {
          trtcMeeting.stopRemoteView(
            userId,
            TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB,
          );
        }

        _screenUserList = TRTCMeetingTools.getScreenList(_userList);
        setState(() {
          _userList = _userList;
          _screenUserList = _screenUserList;
        });
        break;

      default:
        break;
    }
  }

  Future<bool> exitMeetingRoom() async {
    bool isExit = (await showExitConfirmDialog())!;

    if (isExit) {
      leaveMeeting();
      Navigator.pop(context);
    }

    return isExit;
  }

  Future<bool?> showExitConfirmDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(Languages.of(context)!.tipsText),
          content: Text(Languages.of(context)!.meetingLeaveTips),
          actions: <Widget>[
            TextButton(
              child: Text(Languages.of(context)!.cancelText),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(Languages.of(context)!.okText),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> showErrorDialog(errMsg) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(Languages.of(context)!.tipsText),
          content: Text(errMsg),
          actions: <Widget>[
            TextButton(
              child: Text(Languages.of(context)!.okText),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  onSpeakIconPress() {
    trtcMeeting.setSpeaker(!_enabledSpeak);
    setState(() => _enabledSpeak = !_enabledSpeak);
  }

  onCameraIconPress() {
    trtcMeeting.switchCamera(!_enabledFrontCamera);
    setState(() => _enabledFrontCamera = !_enabledFrontCamera);
  }

  onMicroIconPress() {
    if (_enabledMicrophone) {
      trtcMeeting.stopMicrophone();
    } else {
      trtcMeeting.startMicrophone();
    }
    setState(() => _enabledMicrophone = !_enabledMicrophone);
  }

  onVideoIconPress() {
    if (_isShareWindow) return;

    if (_enabledCamera) {
      trtcMeeting.stopCameraPreview();
      if (_isDoubleTap && _doubleUserId == _userList[0].userId) {
        onDoubleTap(_userList[0]);
      }
    }

    _userList[0].type = !_enabledCamera ? 'video' : 'empty';
    _userList[0].visible = !_enabledCamera;

    setState(() {
      _enabledCamera = !_enabledCamera;
      _userList = _userList;
    });
  }

  onDoubleTap(UserInfo userItem) async {
    if (userItem.type == 'empty') return;

    Size screenSize = MediaQuery.of(context).size;

    if (_isDoubleTap) {
      _isDoubleTap = false;
      _doubleUserId = '';
      _doubleUserIdType = '';
      userItem.size = defaultViewSize;
    } else {
      _isDoubleTap = true;
      _doubleUserId = userItem.userId;
      _doubleUserIdType = userItem.type;
      userItem.size = Size(screenSize.width, screenSize.height);
    }

    if (userItem.userId == myInfo.userId) {
      if (Platform.isIOS) {
        await trtcMeeting.stopCameraPreview();
      }
    } else {
      if (userItem.type == 'video') {
        await trtcMeeting.stopRemoteView(
          userItem.userId,
          TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
        );
      } else if (userItem.type == 'subStream') {
        await trtcMeeting.stopRemoteView(
          userItem.userId,
          TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB,
        );
      }

      if (!_isDoubleTap && Platform.isIOS) {
        await trtcMeeting.stopCameraPreview();
      }
    }

    setState(() {
      _isDoubleTap = _isDoubleTap;
      _doubleUserId = _doubleUserId;
      _doubleUserIdType = _doubleUserIdType;
      _userList = _userList;
    });
  }

  onSharePress() async {
    if (!_isShareWindow) {
      Navigator.pop(context);
      await startShareScreen();
      if (Platform.isIOS) {
        ReplayKitLauncher.launchReplayKitBroadcast(iosExtensionName);
      }
    }
  }

  startShareScreen() async {
    await trtcMeeting.stopCameraPreview();
    trtcMeeting.startScreenCapture(
      videoFps: 10,
      videoBitrate: 1600,
      appGroup: iosAppGroup,
    );
    _userList[0].type = 'subStream';
    _userList[0].visible = true;
    setState(() {
      _isShareWindow = true;
      _userList = _userList;
    });
  }

  stopShareScreen() async {
    await trtcMeeting.stopScreenCapture();
    _userList[0].type = _enabledCamera ? 'video' : 'empty';
    _userList[0].visible = _enabledCamera;

    if (_enabledCamera) {
      trtcMeeting.startCameraPreview(_enabledFrontCamera, _localViewId!);
    }

    setState(() {
      _isShareWindow = false;
      _userList = _userList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: exitMeetingRoom,
        child: Stack(
          children: <Widget>[
            _isShareWindow ? buildShareView() : buildViewList(),
            buildTopSetting(),
            _isShareWindow ? Align() : buildBottomSetting(),
          ],
        ),
      ),
    );
  }

  Widget buildShareView() {
    return Container(
      color: Colors.grey.shade200,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            Languages.of(context)!.meetingShareScreenStarted,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            child: Text(Languages.of(context)!.meetingStopShareScreen),
            onPressed: stopShareScreen,
            style: ButtonStyle(
              textStyle: MaterialStateProperty.all(
                TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: MaterialStateProperty.all(Colors.red),
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildViewList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _screenUserList.length,
      cacheExtent: 0,
      controller: scrollController,
      itemBuilder: (BuildContext context, int index) {
        var screenUserItem = _screenUserList[index];
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Wrap(
            children: List.generate(
              screenUserItem.length,
              (index) => LayoutBuilder(
                key: ValueKey(screenUserItem[index].userId),
                builder: (BuildContext context, BoxConstraints constraints) {
                  Size size = TRTCMeetingTools.getViewSize(
                      MediaQuery.of(context).size,
                      _userList.length,
                      screenUserItem.length);
                  double width = size.width;
                  double height = size.height;

                  if (_isDoubleTap && screenUserItem[index].size.width == 0.0) {
                    width = 1;
                    height = 1;
                  }

                  ValueKey valueKey = ValueKey(screenUserItem[index].userId +
                      (_isDoubleTap ? "1" : "0"));

                  if (screenUserItem[index].size.width > 0) {
                    width = screenUserItem[index].size.width;
                    height = screenUserItem[index].size.height;
                  }

                  return Container(
                    key: valueKey,
                    width: width,
                    height: height,
                    child: Stack(
                      key: valueKey,
                      children: <Widget>[
                        buildViewScreen(screenUserItem[index], valueKey),
                        buildVideoVoice(screenUserItem[index]),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildViewScreen(UserInfo item, ValueKey valueKey) {
    bool isMine = item.userId == myInfo.userId;
    bool showView = isMine ? item.visible : item.visible && !item.videoMuted;

    if (showView) {
      return GestureDetector(
        key: valueKey,
        onDoubleTap: () => onDoubleTap(item),
        child: TRTCCloudVideoView(
          key: valueKey,
          viewType: TRTCCloudDef.TRTC_VideoView_SurfaceView,
          onViewCreated: (viewId) {
            if (isMine) {
              trtcMeeting.startCameraPreview(_enabledFrontCamera, viewId);
              setState(() => _localViewId = viewId);
            } else {
              var streamType = item.type == 'video'
                  ? TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG
                  : TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB;
              trtcMeeting.startRemoteView(item.userId, streamType, viewId);
            }
          },
        ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        child: ClipOval(
          child: Image.network(
            'https://imgcache.qq.com/qcloud/public/static//avatar3_100.20191230.png',
            scale: 3.5,
          ),
        ),
      );
    }
  }

  Widget buildVideoVoice(UserInfo item) {
    return Positioned(
      left: 24.0,
      bottom: 70.0,
      child: Container(
        child: Row(
          children: <Widget>[
            Text(
              item.userId == myInfo.userId ? item.userId + '(me)' : item.userId,
              style: TextStyle(color: Colors.black),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0),
              child: Icon(
                Icons.signal_cellular_alt,
                color: Colors.black,
                size: 20.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTopSetting() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: Colors.grey.shade400,
        height: 50.0,
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(
                _enabledSpeak ? Icons.volume_up : Icons.hearing,
                color: Colors.white,
                size: 36.0,
              ),
              onPressed: onSpeakIconPress,
            ),
            IconButton(
              icon: Icon(
                Icons.flip_camera_ios_sharp,
                color: Colors.white,
                size: 36.0,
              ),
              onPressed: onCameraIconPress,
            ),
            Text(
              _meetingNumber.toString(),
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
            TextButton(
              child: Text(Languages.of(context)!.meetingLeaveLabel),
              onPressed: exitMeetingRoom,
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all(
                  TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: MaterialStateProperty.all(Colors.red),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomSetting() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.grey.shade400,
        height: 60.0,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(
                _enabledMicrophone ? Icons.mic : Icons.mic_off,
                color: Colors.white,
                size: 36.0,
              ),
              onPressed: onMicroIconPress,
            ),
            IconButton(
              icon: Icon(
                _enabledCamera ? Icons.videocam : Icons.videocam_off,
                color: Colors.white,
                size: 36.0,
              ),
              onPressed: onVideoIconPress,
            ),
            IconButton(
              icon: Icon(
                Icons.face,
                color: Colors.white,
                size: 36.0,
              ),
              onPressed: showBeautySettingDialog,
            ),
            TRTCMeetingMemberList(
              myInfo: myInfo,
              userList: _userList,
              onMemberListClose: (List<UserInfo> userList) =>
                  setState(() => _userList = userList),
            ),
            TRTCMeetingSetting(onSharePress: onSharePress),
          ],
        ),
      ),
    );
  }

  showBeautySettingDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (_context, _setState) {
          return Container(
            color: Colors.white,
            padding: EdgeInsets.all(10.0),
            width: MediaQuery.of(context).size.width,
            height: 150.0,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Languages.of(context)!.meetingBeautyLevel,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                    Container(
                      width: 280.0,
                      child: Slider(
                        value: _beautyMap[_curBeauty]!.toDouble(),
                        min: 0.0,
                        max: 9.0,
                        divisions: 9,
                        onChanged: (double value) {
                          _beautyMap[_curBeauty] = value.toInt();

                          if (_curBeauty == 'whitening') {
                            txBeautyManager.setWhitenessLevel(value.round());
                          } else if (_curBeauty == 'ruddy') {
                            txBeautyManager.setRuddyLevel(value.round());
                          } else {
                            txBeautyManager.setRuddyLevel(value.round());
                          }

                          _setState(() => _beautyMap = _beautyMap);
                        },
                      ),
                    ),
                    Text(
                      _beautyMap[_curBeauty].toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      buildBeautyOption(
                          Languages.of(context)!.meetingBeautySmooth,
                          'smooth',
                          _setState),
                      buildBeautyOption(
                          Languages.of(context)!.meetingBeautyNature,
                          'nature',
                          _setState),
                      buildBeautyOption(
                          Languages.of(context)!.meetingBeautyPitu,
                          'pitu',
                          _setState),
                      buildBeautyOption(
                          Languages.of(context)!.meetingBeautyWhitening,
                          'whitening',
                          _setState),
                      buildBeautyOption(
                          Languages.of(context)!.meetingBeautyRuddy,
                          'ruddy',
                          _setState),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget buildBeautyOption(String text, String beautyStyle,
      void Function(void Function()) _setState) {
    return GestureDetector(
        child: Container(
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
                color: _curBeauty == beautyStyle ? Colors.blue : Colors.black,
                fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {
          switch (beautyStyle) {
            case 'smooth':
              txBeautyManager
                  .setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_SMOOTH);
              txBeautyManager.setBeautyStyle(_beautyMap['smooth']!);
              break;
            case 'nature':
              txBeautyManager
                  .setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_NATURE);
              txBeautyManager.setBeautyStyle(_beautyMap['nature']!);
              break;
            case 'pitu':
              txBeautyManager
                  .setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_PITU);
              txBeautyManager.setBeautyStyle(_beautyMap['pitu']!);
              break;
            default:
              break;
          }

          _setState(() => _curBeauty = beautyStyle);
        });
  }
}
