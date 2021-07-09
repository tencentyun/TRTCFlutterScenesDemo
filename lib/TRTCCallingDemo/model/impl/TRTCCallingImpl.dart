import 'dart:convert';
import 'dart:math';

import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSignalingListener.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_trtc_cloud/tx_beauty_manager.dart';

import '../TRTCCalling.dart';
import '../TRTCCallingDef.dart';
import '../TRTCCallingDelegate.dart';

//trtc sdk
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/tx_audio_effect_manager.dart';
import 'package:tencent_trtc_cloud/tx_device_manager.dart';

//im sdk
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';

class TRTCCallingImpl extends TRTCCalling {
  String logTag = "TRTCCallingImpl";
  static TRTCCallingImpl? sInstance;

  int timeOutCount = 30; //超时时间，默认30s

  int codeErr = -1;

  // 是否首次邀请
  bool isOnCalling = false;
  bool mIsInRoom = false;
  int mEnterRoomTime = 0;
  String mCurCallID = "";
  int mCurRoomID = 0;
  String mCurGroupId = ""; //当前群组通话的群组ID
  String? mNickName;
  String? mFaceUrl;

  /*
   * 当前邀请列表
   * C2C通话时会记录自己邀请的用户
   * IM群组通话时会同步群组内邀请的用户
   * 当用户接听、拒绝、忙线、超时会从列表中移除该用户
   */
  List<String> mCurInvitedList = [];

  List<dynamic> mCurCallList = [];

  //当前语音通话中的远端用户
  Set mCurRoomRemoteUserSet = new Set();
  /*
  * C2C通话的邀请人
  * 例如A邀请B，B存储的mCurSponsorForMe为A
  */
  String mCurSponsorForMe = "";
  //当前通话的类型
  int? mCurCallType;

  late int mSdkAppId;
  late String mCurUserId;
  late String mCurUserSig;
  String? mRoomId;
  String? mOwnerUserId;
  bool mIsInitIMSDK = false;
  bool mIsLogin = false;
  String mRole = "audience"; //默认为观众，archor为主播
  late V2TIMManager timManager;
  late TRTCCloud mTRTCCloud;
  late TXAudioEffectManager txAudioManager;
  late TXDeviceManager txDeviceManager;
  Set<VoiceListenerFunc> listeners = Set();

  TRTCCallingImpl() {
    //获取腾讯即时通信IM manager
    timManager = TencentImSDKPlugin.v2TIMManager;
    initTRTC();
  }

  initTRTC() async {
    mTRTCCloud = (await TRTCCloud.sharedInstance())!;
    txDeviceManager = mTRTCCloud.getDeviceManager();
    txAudioManager = mTRTCCloud.getAudioEffectManager();
  }

  static sharedInstance() {
    if (sInstance == null) {
      sInstance = new TRTCCallingImpl();
    }
    return sInstance;
  }

  static void destroySharedInstance() {
    if (sInstance != null) {
      sInstance = null;
    }
    TRTCCloud.destroySharedInstance();
  }

  @override
  void destroy() {
    mTRTCCloud.stopLocalPreview();
    mTRTCCloud.stopLocalAudio();
    mTRTCCloud.exitRoom();
  }

  @override
  void registerListener(VoiceListenerFunc func) {
    if (listeners.isEmpty) {
      //监听im事件
      timManager
          .getSignalingManager()
          .addSignalingListener(listener: signalingListener());
      //监听trtc事件
      mTRTCCloud.registerListener(rtcListener);
    }
    listeners.add(func);
  }

  @override
  void unRegisterListener(VoiceListenerFunc func) {
    listeners.remove(func);
    if (listeners.isEmpty) {
      mTRTCCloud.unRegisterListener(rtcListener);
      timManager
          .getSignalingManager()
          .removeSignalingListener(listener: signalingListener);
    }
  }

  emitEvent(type, params) {
    for (var item in listeners) {
      item(type, params);
    }
  }

  signalingListener() {
    TRTCCallingDelegate type;
    return new V2TimSignalingListener(
      onInvitationCancelled: (inviteID, inviter, data) {
        if (!_isCallingData(data)) {
          return;
        }
        if (inviteID == mCurCallID) {
          _stopCall();
          emitEvent(TRTCCallingDelegate.onCallingCancel, {});
        }
      },
      onInvitationTimeout: (inviteID, inviteeList) {
        //邀请者
        String curGroupCallId = _getGroupCallId(mCurUserId);
        if (!_isEmpty(mCurCallID) && inviteID != mCurCallID) {
          return;
        } else if (_isEmpty(mCurCallID) && inviteID != curGroupCallId) {
          return;
        }
        if (mCurSponsorForMe.isEmpty) {
          for (var i = 0; i < inviteeList.length; i++) {
            emitEvent(TRTCCallingDelegate.onNoResp, inviteeList[i]);
            mCurInvitedList.remove(inviteeList[i]);
          }
        } else {
          //被邀请者
          if (inviteeList.contains(mCurUserId)) {
            _stopCall();
            emitEvent(TRTCCallingDelegate.onCallingTimeout, {});
          }
          mCurInvitedList.remove(inviteeList);
        }
        // 每次超时都需要判断当前是否需要结束通话
        _preExitRoom(null);
      },
      onInviteeAccepted: (inviteID, invitee, data) {
        if (!_isCallingData(data)) {
          return;
        }
        mCurInvitedList.remove(invitee);
      },
      onInviteeRejected: (inviteID, invitee, data) {
        if (!_isCallingData(data)) {
          return;
        }
        String curGroupCallId = _getGroupCallId(invitee);
        if (mCurCallID == inviteID || curGroupCallId == inviteID) {
          try {
            Map<String, dynamic>? customMap = jsonDecode(data);
            mCurInvitedList.remove(invitee);
            if (customMap != null && customMap.containsKey('line_busy')) {
              emitEvent(TRTCCallingDelegate.onLineBusy, invitee);
            } else {
              emitEvent(TRTCCallingDelegate.onReject, invitee);
            }
            _preExitRoom(null);
          } catch (e) {
            print(logTag +
                "=onInviteeRejected JsonSyntaxException:" +
                e.toString());
          }
        }
      },
      onReceiveNewInvitation:
          (inviteID, inviter, groupID, inviteeList, data) async {
        if (!_isCallingData(data)) {
          return;
        }
        try {
          Map<String, dynamic>? customMap = jsonDecode(data);
          if (customMap == null) {
            print(logTag + "onReceiveNewInvitation extraMap is null, ignore");
            return;
          }
          if (customMap.containsKey('call_type')) {
            mCurCallType = customMap['call_type'];
          }
          if (customMap.containsKey('call_end')) {
            _preExitRoom(null);
            return;
          }
          if (customMap.containsKey('room_id')) {
            mCurRoomID = customMap['room_id'];
          }
        } catch (e) {
          print(logTag +
              "=onReceiveNewInvitation JsonSyntaxException:" +
              e.toString());
        }
        if (isOnCalling && inviteeList.contains(mCurUserId)) {
          // 正在通话时，收到了一个邀请我的通话请求,需要告诉对方忙线
          Map<String, dynamic> busyMap = _getCustomMap();
          busyMap['line_busy'] = 'line_busy';
          await timManager
              .getSignalingManager()
              .reject(inviteID: inviteID, data: jsonEncode(busyMap));
          return;
        }
        // 与对方处在同一个群中，此时收到了邀请群中其他人通话的请求，界面上展示连接动画
        if (!_isEmpty(groupID) && !_isEmpty(mCurGroupId)) {
          mCurInvitedList.addAll(inviteeList);
          TRTCCallingDelegate type =
              TRTCCallingDelegate.onGroupCallInviteeListUpdate;
          emitEvent(type, mCurInvitedList);
        }
        if (!inviteeList.contains(mCurUserId)) {
          return;
        }

        mCurSponsorForMe = inviter;
        mCurCallID = inviteID;
        mCurGroupId = groupID;
        type = TRTCCallingDelegate.onInvited;
        emitEvent(type, {
          'sponsor': inviter,
          'userIds': inviteeList.remove(mCurUserId),
          'isFromGroup': !_isEmpty(groupID),
          'type': mCurCallType
        });
      },
    );
  }

  rtcListener(rtcType, param) {
    String typeStr = rtcType.toString();
    TRTCCallingDelegate type;
    typeStr = typeStr.replaceFirst("TRTCCloudListener.", "");
    if (typeStr == "onEnterRoom") {
      if (param < 0) {
        _stopCall();
      } else {
        mIsInRoom = true;
      }
    } else if (typeStr == "onError") {
      type = TRTCCallingDelegate.onError;
      emitEvent(type, param);
    } else if (typeStr == "onUserVoiceVolume") {
      type = TRTCCallingDelegate.onUserVoiceVolume;
      emitEvent(type, param);
    } else if (typeStr == "onUserVideoAvailable") {
      type = TRTCCallingDelegate.onUserVideoAvailable;
      emitEvent(type, param);
    } else if (typeStr == "onUserAudioAvailable") {
      type = TRTCCallingDelegate.onUserAudioAvailable;
      emitEvent(type, param);
    } else if (typeStr == "onRemoteUserEnterRoom") {
      mCurRoomRemoteUserSet.add(param);
      // 只有单聊这个时间才是正确的，因为单聊只会有一个用户进群，群聊这个时间会被后面的人重置
      mEnterRoomTime = DateTime.now().millisecondsSinceEpoch;
      type = TRTCCallingDelegate.onUserEnter;
      emitEvent(type, param);
    } else if (typeStr == "onRemoteUserLeaveRoom") {
      mCurRoomRemoteUserSet.remove(param['userId']);
      mCurInvitedList.remove(param['userId']);
      type = TRTCCallingDelegate.onUserLeave;
      emitEvent(type, param['userId']);
      _preExitRoom(param['userId']);
    }
  }

  // 多人通话时，根据userId找到对应的通话id
  _getGroupCallId(String userId) {
    for (int i = 0; i < mCurCallList.length; i++) {
      if (mCurCallList[i]['userId'] == userId) {
        return mCurCallList[i]['callId'];
      }
    }
    return '';
  }

  /*
  * 重要：用于判断是否需要结束本次通话
  * 在用户超时、拒绝、忙线、有人退出房间时需要进行判断
  */
  _preExitRoom(String? leaveUser) {
    if (mCurRoomRemoteUserSet.isEmpty && mCurInvitedList.isEmpty && mIsInRoom) {
      // 当没有其他用户在房间里了，则结束通话。
      if (!_isEmpty(leaveUser)) {
        Map<String, dynamic> customMap = _getCustomMap();
        //customMap['call_end'] = 'call_end';
        customMap['call_end'] = 10;
        if (_isEmpty(mCurGroupId)) {
          timManager
              .getSignalingManager()
              .invite(invitee: leaveUser!, data: jsonEncode(customMap));
        } else {
          timManager.getSignalingManager().inviteInGroup(
              groupID: mCurGroupId,
              inviteeList: mCurInvitedList,
              data: jsonEncode(customMap));
        }
      }
      _exitRoom();
      _stopCall();
      emitEvent(TRTCCallingDelegate.onCallEnd, {});
    }
  }

  @override
  Future<ActionCallback> login(
      int sdkAppId, String userId, String userSig) async {
    mSdkAppId = sdkAppId;
    mCurUserId = userId;
    mCurUserSig = userSig;

    if (!mIsInitIMSDK) {
      //初始化SDK
      V2TimValueCallback<bool> initRes = await timManager.initSDK(
          sdkAppID: sdkAppId, //填入在控制台上申请的sdkappid
          loglevel: LogLevel.V2TIM_LOG_ERROR,
          listener: new V2TimSDKListener(onKickedOffline: () {
            TRTCCallingDelegate type = TRTCCallingDelegate.onKickedOffline;
            emitEvent(type, {});
          }));
      if (initRes.code != 0) {
        //初始化sdk错误
        return ActionCallback(code: 0, desc: 'init im sdk error');
      }
    }
    mIsInitIMSDK = true;

    // 登陆到 IM
    String? loginedUserId = (await timManager.getLoginUser()).data;

    if (loginedUserId != null && loginedUserId == userId) {
      mIsLogin = true;
      return ActionCallback(code: 0, desc: 'login im success');
    }
    V2TimCallback loginRes =
        await timManager.login(userID: userId, userSig: userSig);
    if (loginRes.code == 0) {
      mIsLogin = true;
      return ActionCallback(code: 0, desc: 'login im success');
    } else {
      return ActionCallback(code: codeErr, desc: loginRes.desc);
    }
  }

  @override
  Future<ActionCallback> logout() async {
    V2TimCallback loginRes = await timManager.logout();
    _stopCall();
    _exitRoom();
    mNickName = "";
    mFaceUrl = "";
    return ActionCallback(code: loginRes.code, desc: loginRes.desc);
  }

  @override
  Future<ActionCallback> call(String userId, int type) async {
    if (!isOnCalling) {
      // 首次拨打电话，生成id，并进入trtc房间
      mCurRoomID = _generateRoomID();
      mCurCallType = type;
      _enterTRTCRoom();
    }
    mCurInvitedList.add(userId);

    V2TimValueCallback res = await timManager.getSignalingManager().invite(
        invitee: userId,
        data: jsonEncode(_getCustomMap()),
        timeout: timeOutCount,
        onlineUserOnly: false);
    mCurCallID = res.data;
    mCurCallList.add({'userId': userId, 'callId': mCurCallID});
    return ActionCallback(code: res.code, desc: res.desc);
  }

  _isCallingData(String data) {
    try {
      Map<String, dynamic> customMap = jsonDecode(data);
      if (customMap.containsKey('call_type')) {
        return true;
      }
    } catch (e) {
      print("isCallingData json parse error");
      return false;
    }
    return false;
  }

  _getCustomMap() {
    Map<String, dynamic> customMap = new Map<String, dynamic>();
    customMap['version'] = 1;
    customMap['call_type'] = mCurCallType;
    customMap['room_id'] = mCurRoomID;
    return customMap;
  }

  /*
  * trtc 进房
  */
  _enterTRTCRoom() {
    isOnCalling = true;
    if (mCurCallType == TRTCCalling.typeVideoCall) {
      // 开启基础美颜
      TXBeautyManager txBeautyManager = mTRTCCloud.getBeautyManager();
      // 自然美颜
      txBeautyManager.setBeautyStyle(1);
      txBeautyManager.setBeautyLevel(6);
      // 进房前需要设置一下关键参数
      TRTCVideoEncParam encParam = new TRTCVideoEncParam();
      encParam.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540;
      encParam.videoFps = 15;
      encParam.videoBitrate = 1000;
      encParam.videoResolutionMode =
          TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT;
      encParam.enableAdjustRes = true;
      mTRTCCloud.setVideoEncoderParam(encParam);
    }

    mTRTCCloud.enableAudioVolumeEvaluation(500);
    txDeviceManager.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
    mTRTCCloud.muteLocalAudio(false);
    mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
    mTRTCCloud.enterRoom(
        TRTCParams(
            sdkAppId: mSdkAppId,
            userId: mCurUserId,
            userSig: mCurUserSig,
            roomId: mCurRoomID,
            role: TRTCCloudDef.TRTCRoleAnchor),
        mCurCallType == TRTCCalling.typeVideoCall
            ? TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL
            : TRTCCloudDef.TRTC_APP_SCENE_AUDIOCALL);
  }

  @override
  Future<ActionCallback> groupCall(
      List<String> userIdList, int type, String? groupId) async {
    if (_isListEmpty(userIdList)) {
      return ActionCallback(code: codeErr, desc: 'userIdList is empty');
    }
    if (!isOnCalling) {
      // 首次拨打电话，生成id，并进入trtc房间
      mCurRoomID = _generateRoomID();
      mCurCallType = type;
      _enterTRTCRoom();
    }

    // 过滤已经邀请的用户id
    List<String> filterInvitedList = [];
    for (var i = 0; i < userIdList.length; i++) {
      if (!mCurInvitedList.contains(userIdList[i])) {
        filterInvitedList.add(userIdList[i]);
      }
    }
    if (_isListEmpty(filterInvitedList)) {
      return ActionCallback(
          code: codeErr, desc: 'the userIdList has been invited');
    }
    mCurInvitedList = filterInvitedList;
    if (_isEmpty(groupId)) {
      for (int i = 0; i < mCurInvitedList.length; i++) {
        V2TimValueCallback res = await timManager.getSignalingManager().invite(
            invitee: mCurInvitedList[i],
            data: jsonEncode(_getCustomMap()),
            timeout: timeOutCount,
            onlineUserOnly: false);
        mCurCallList.add({'userId': mCurInvitedList[i], 'callId': res.data});
      }
      return ActionCallback(code: 0, desc: '');
    } else {
      V2TimValueCallback res = await timManager
          .getSignalingManager()
          .inviteInGroup(
              groupID: groupId!,
              inviteeList: mCurInvitedList,
              data: jsonEncode(_getCustomMap()),
              timeout: timeOutCount,
              onlineUserOnly: false);
      mCurCallID = res.data;
      return ActionCallback(code: res.code, desc: res.desc);
    }
  }

  _isListEmpty(List? list) {
    return list == null || list.length == 0;
  }

  _isEmpty(String? data) {
    return data == null || data == "";
  }

  /*
  * 停止此次通话，把所有的变量都会重置
  */
  _stopCall() {
    isOnCalling = false;
    mIsInRoom = false;
    mEnterRoomTime = 0;
    mCurCallID = "";
    mCurRoomID = 0;
    mCurInvitedList = [];
    mCurCallList = [];
    mCurRoomRemoteUserSet.clear();
    mCurSponsorForMe = "";
    mCurGroupId = "";
    mCurCallType = TRTCCalling.typeUnknow;
  }

  @override
  Future<ActionCallback> accept() async {
    _enterTRTCRoom();
    V2TimCallback res = await timManager
        .getSignalingManager()
        .accept(inviteID: mCurCallID, data: jsonEncode(_getCustomMap()));
    return ActionCallback(code: res.code, desc: res.desc);
  }

  @override
  Future<void> closeCamera() async {
    return mTRTCCloud.stopLocalPreview();
  }

  @override
  Future<void> hangup() async {
    if (!isOnCalling) {
      await reject();
      return;
    }
    _exitRoom();
    if (_isEmpty(mCurGroupId)) {
      for (int i = 0; i < mCurInvitedList.length; i++) {
        await timManager.getSignalingManager().cancel(
            inviteID: _getGroupCallId(mCurInvitedList[i]),
            data: jsonEncode(_getCustomMap()));
      }
    } else {
      if (mCurRoomRemoteUserSet.isEmpty) {
        await timManager.getSignalingManager().cancel(
            inviteID: _getGroupCallId(mCurCallID),
            data: jsonEncode(_getCustomMap()));
      }
    }
    _stopCall();
  }

  /*
  * trtc 退房
  */
  _exitRoom() {
    mTRTCCloud.stopLocalPreview();
    mTRTCCloud.stopLocalAudio();
    mTRTCCloud.exitRoom();
  }

  @override
  Future<void> openCamera(bool isFrontCamera, int viewId) {
    return mTRTCCloud.startLocalPreview(isFrontCamera, viewId);
  }

  @override
  Future<void> updateLocalView(int viewId) {
    return mTRTCCloud.updateLocalView(viewId);
  }

  @override
  Future<ActionCallback> reject() async {
    V2TimCallback res = await timManager
        .getSignalingManager()
        .reject(inviteID: mCurCallID, data: jsonEncode(_getCustomMap()));
    _stopCall();
    return ActionCallback(code: res.code, desc: res.desc);
  }

  @override
  Future<void> setHandsFree(bool isHandsFree) {
    if (isHandsFree) {
      return txDeviceManager
          .setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
    } else {
      return txDeviceManager
          .setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE);
    }
  }

  @override
  Future<void> setMicMute(bool isMute) {
    return mTRTCCloud.muteLocalAudio(isMute);
  }

  @override
  Future<void> startRemoteView(String userId, int streamType, int viewId) {
    return mTRTCCloud.startRemoteView(userId, streamType, viewId);
  }

  @override
  Future<void> stopRemoteView(String userId, int streamType) {
    return mTRTCCloud.stopRemoteView(userId, streamType);
  }

  @override
  Future<void> updateRemoteView(String userId, int streamType, int viewId) {
    return mTRTCCloud.updateRemoteView(viewId, streamType, userId);
  }

  @override
  Future<void> switchCamera(bool isFrontCamera) {
    return txDeviceManager.switchCamera(isFrontCamera);
  }

  _generateRoomID() {
    Random rng = new Random();
    //2147483647
    String numStr = '';
    for (var i = 0; i < 9; i++) {
      numStr += rng.nextInt(9).toString();
    }
    return int.tryParse(numStr);
  }
}

/// @nodoc
typedef VoiceListenerFunc<P> = void Function(
    TRTCCallingDelegate type, P params);
