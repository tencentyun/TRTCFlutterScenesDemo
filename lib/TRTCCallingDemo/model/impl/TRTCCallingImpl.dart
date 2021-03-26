import 'dart:convert';
import 'dart:math';

import 'package:tencent_im_sdk_plugin/enum/group_add_opt_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_event_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_signal_fullinfo.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
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
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';

final int VALUE_PROTOCOL_VERSION = 1;
// 系统错误
final int VIDEO_CALL_ACTION_ERROR = -1;
// 未知信令
final int VIDEO_CALL_ACTION_UNKNOWN = 0;
// 正在呼叫
final int VIDEO_CALL_ACTION_DIALING = 1;
// 发起人取消
final int VIDEO_CALL_ACTION_SPONSOR_CANCEL = 2;
// 拒接电话
final int VIDEO_CALL_ACTION_REJECT = 3;
//无人接听
final int VIDEO_CALL_ACTION_SPONSOR_TIMEOUT = 4;
//挂断
final int VIDEO_CALL_ACTION_HANGUP = 5;
//电话占线
final int VIDEO_CALL_ACTION_LINE_BUSY = 6;
// 接听电话
final int VIDEO_CALL_ACTION_ACCEPT = 7;
Map<String, dynamic> initCallModel = {
  'action': VIDEO_CALL_ACTION_UNKNOWN,
  'version': 0,
  'callId': null,
  'roomId': 0,
  'groupId': '',
  'callType': 0,
  'invitedList': null,
  'duration': 0,
  'code': 0,
  'timestamp': 0,
  'sender': null,
  'timeout': null,
  'data': null
};

class TRTCCallingImpl extends TRTCCalling {
  String logTag = "TRTCCallingImpl";
  VoiceListenerFunc emitEvent;
  static TRTCCallingImpl sInstance;

  int TIME_OUT_COUNT = 30; //超时时间，默认30s

  int codeErr = -1;

  // 是否首次邀请
  bool isOnCalling = false;
  bool mIsInRoom = false;
  int mEnterRoomTime = 0;
  String mCurCallID = "";
  int mCurRoomID = 0;
  String mCurGroupId = ""; //当前群组通话的群组ID
  String mNickName;
  String mFaceUrl;

  //最近使用的通话信令，用于快速处理
  Map<String, dynamic> mLastCallModel = new Map.from(initCallModel);
  /*
   * 当前邀请列表
   * C2C通话时会记录自己邀请的用户
   * IM群组通话时会同步群组内邀请的用户
   * 当用户接听、拒绝、忙线、超时会从列表中移除该用户
   */
  List<String> mCurInvitedList = [];

  //当前语音通话中的远端用户
  Set mCurRoomRemoteUserSet = new Set();
  /*
  * C2C通话的邀请人
  * 例如A邀请B，B存储的mCurSponsorForMe为A
  */
  String mCurSponsorForMe = "";
  //当前通话的类型
  int mCurCallType;

  int mSdkAppId;
  String mCurUserId;
  String mCurUserSig;
  String mRoomId;
  String mOwnerUserId;
  bool mIsInitIMSDK = false;
  bool mIsLogin = false;
  String mRole = "audience"; //默认为观众，archor为主播
  V2TIMManager timManager;
  TRTCCloud mTRTCCloud;
  TXAudioEffectManager txAudioManager;
  TXDeviceManager txDeviceManager;

  TRTCCallingImpl() {
    //获取腾讯即时通信IM manager
    timManager = TencentImSDKPlugin.v2TIMManager;
    initTRTC();
  }

  initTRTC() async {
    mTRTCCloud = await TRTCCloud.sharedInstance();
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
    emitEvent = func;
    //监听im事件
    timManager.getSignalingManager().addSignalingListener(
          listener: signalingListener,
        );
    //监听trtc事件
    mTRTCCloud.registerListener(rtcListener);
  }

  @override
  void unRegisterListener(VoiceListenerFunc func) {
    emitEvent = null;
    timManager
        .getSignalingManager()
        .removeSignalingListener(listener: signalingListener);
    mTRTCCloud.unRegisterListener(rtcListener);
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
      type = TRTCCallingDelegate.onUserVolumeUpdate;
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

  /*
  * 重要：用于判断是否需要结束本次通话
  * 在用户超时、拒绝、忙线、有人退出房间时需要进行判断
  */
  _preExitRoom(String userId) {
    if (mCurRoomRemoteUserSet.isEmpty && mCurInvitedList.isEmpty && mIsInRoom) {
      // 当没有其他用户在房间里了，则结束通话。
      // if (!TextUtils.isEmpty(leaveUser)) {
      //   if (TextUtils.isEmpty(mCurGroupId)) {
      //     sendModel(leaveUser, CallModel.VIDEO_CALL_ACTION_HANGUP);
      //   } else {
      //     sendModel("", CallModel.VIDEO_CALL_ACTION_HANGUP);
      //   }
      // }
      _exitRoom();
      _stopCall();
      emitEvent(TRTCCallingDelegate.onCallEnd, {});
    }
  }

  signalingListener(V2TimEventCallback data) {
    print("==signalingListener data type=" + data.type.toString());
    print("==signalingListener data data=" + data.data.toString());
    print("==signalingListener data inviteID=" + data.data.inviteID.toString());
    print("==signalingListener data inviter=" + data.data.inviter.toString());
    TRTCCallingDelegate type;
    V2TimSignalFullinfo infoData = data.data;
    if (data.type == 'onInviteeAccepted') {
      if (!_isCallingData(infoData.data)) {
        return;
      }
      mCurInvitedList.remove(infoData.invitee);
    } else if (data.type == 'onInviteeRejected') {
      if (!_isCallingData(infoData.data)) {
        return;
      }
      if (mCurCallID == infoData.inviteID) {
        try {
          Map<String, dynamic> customMap = jsonDecode(infoData.data);
          mCurInvitedList.remove(infoData.invitee);
          if (customMap != null && customMap.containsKey('line_busy')) {
            emitEvent(TRTCCallingDelegate.onLineBusy, infoData.invitee);
          } else {
            emitEvent(TRTCCallingDelegate.onReject, infoData.invitee);
          }
          _preExitRoom(null);
        } catch (e) {
          print(logTag +
              "=onInviteeRejected JsonSyntaxException:" +
              e.toString());
        }
      }
    } else if (data.type == 'onInvitationCancelled') {
      if (!_isCallingData(infoData.data)) {
        return;
      }
      if (infoData.inviteID == mCurCallID) {
        _stopCall();
        emitEvent(TRTCCallingDelegate.onCallingCancel, {});
      }
    } else if (data.type == 'onInvitationTimeout') {
      if (mCurCallID != infoData.inviteID) {
        return;
      }
      //邀请者
      if (mCurSponsorForMe.isEmpty) {
        for (var i = 0; i < infoData.inviteeList.length; i++) {
          emitEvent(TRTCCallingDelegate.onNoResp, infoData.inviteeList[i]);
          mCurInvitedList.remove(infoData.inviteeList[i]);
        }
      } else {
        //被邀请者
        if (infoData.inviteeList.contains(mCurUserId)) {
          _stopCall();
          emitEvent(TRTCCallingDelegate.onCallingTimeout, {});
        }
        mCurInvitedList.remove(infoData.inviteeList);
      }
      // 每次超时都需要判断当前是否需要结束通话
      _preExitRoom(null);
      type = TRTCCallingDelegate.onCallingTimeout;
      emitEvent(type, infoData);
    } else if (data.type == 'onReceiveNewInvitation') {
      if (!_isCallingData(infoData.data)) {
        return;
      }
      try {
        Map<String, dynamic> customMap = jsonDecode(infoData.data);
        if (customMap == null) {
          print(logTag + "onReceiveNewInvitation extraMap is null, ignore");
          return;
        }
        if (customMap.containsKey('call_end')) {
          _preExitRoom(null);
          return;
        }
      } catch (e) {
        print(logTag +
            "=onReceiveNewInvitation JsonSyntaxException:" +
            e.toString());
      }
      mCurSponsorForMe = infoData.inviter;
      mCurCallID = infoData.inviteID;
      type = TRTCCallingDelegate.onInvited;
      emitEvent(type, infoData);
    }
  }

  _initImLisener(V2TimEventCallback data) {
    if (data.type == "onKickedOffline") {
      TRTCCallingDelegate type = TRTCCallingDelegate.onKickedOffline;
      emitEvent(type, {});
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
          listener: _initImLisener);
      if (initRes.code != 0) {
        //初始化sdk错误
        return ActionCallback(code: 0, desc: 'init im sdk error');
      }
    }
    mIsInitIMSDK = true;

    // 登陆到 IM
    String loginedUserId = (await timManager.getLoginUser()).data;

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
      isOnCalling = true;
    }
    mCurInvitedList.add(userId);

    mLastCallModel['action'] = VIDEO_CALL_ACTION_DIALING;
    mLastCallModel['invitedList'] = mCurInvitedList;
    mLastCallModel['roomId'] = mCurRoomID;
    mLastCallModel['groupId'] = mCurGroupId;
    mLastCallModel['callType'] = mCurCallType;

    V2TimValueCallback res = await timManager.getSignalingManager().invite(
        invitee: userId,
        data: _getCurMap(),
        timeout: TIME_OUT_COUNT,
        onlineUserOnly: false);
    mCurCallID = res.data;
    mLastCallModel['callId'] = mCurCallID;
    print("==mCurCallID=" + mCurCallID.toString());
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

  _getCurMap() {
    Map<String, dynamic> customMap = new Map<String, dynamic>();
    customMap['version'] = 1;
    customMap['call_type'] = mCurCallType;
    customMap['room_id'] = mCurRoomID;
    return jsonEncode(customMap);
  }

  /*
  * trtc 进房
  */
  _enterTRTCRoom() {
    if (mCurCallType == TRTCCalling.TYPE_VIDEO_CALL) {
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

    mTRTCCloud.enableAudioVolumeEvaluation(300);
    txDeviceManager.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
    mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
    // 收到来电，开始监听 trtc 的消息
    // mTRTCCloud.setListener(mTRTCCloudListener);
    mTRTCCloud.enterRoom(
        TRTCParams(
            sdkAppId: mSdkAppId,
            userId: mCurUserId,
            userSig: mCurUserSig,
            roomId: mCurRoomID,
            role: TRTCCloudDef.TRTCRoleAnchor),
        mCurCallType == TRTCCalling.TYPE_VIDEO_CALL
            ? TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL
            : TRTCCloudDef.TRTC_APP_SCENE_AUDIOCALL);
  }

  @override
  Future<ActionCallback> groupCall(
      List<String> userIdList, int type, String groupId) async {
    if (_isListEmpty(userIdList)) {
      return ActionCallback(code: codeErr, desc: 'userIdList is empty');
    }
    // 非首次拨打，不能发起新的groupId通话
    if (groupId == mCurGroupId) {
      return ActionCallback(
          code: codeErr,
          desc:
              'You cannot initiate a new groupid call unless you dial it for the first time');
    }
    if (!isOnCalling) {
      // 首次拨打电话，生成id，并进入trtc房间
      mCurRoomID = _generateRoomID();
      mCurCallType = type;
      _enterTRTCRoom();
      isOnCalling = true;
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

    mLastCallModel['action'] = VIDEO_CALL_ACTION_DIALING;
    mLastCallModel['invitedList'] = mCurInvitedList;
    mLastCallModel['roomId'] = mCurRoomID;
    mLastCallModel['groupId'] = mCurGroupId;
    mLastCallModel['callType'] = mCurCallType;

    Map<String, Object> customMap;
    customMap['version'] = 1;
    customMap['call_type'] = mCurCallType;
    customMap['room_id'] = mCurRoomID;

    V2TimValueCallback res = await timManager
        .getSignalingManager()
        .inviteInGroup(
            groupID: groupId,
            data: jsonEncode(customMap),
            inviteeList: mCurInvitedList,
            timeout: TIME_OUT_COUNT,
            onlineUserOnly: false);
    mCurCallID = res.data;
    mLastCallModel['callId'] = mCurCallID;
    return ActionCallback(code: res.code, desc: res.data);
  }

  _isListEmpty(List list) {
    return list == null || list.length == 0;
  }

  _isEmpty(String data) {
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
    // mCurRoomRemoteUserSet.clear();
    mCurSponsorForMe = "";
    // mLastCallModel = new CallModel();
    // mLastCallModel.version = CallModel.VALUE_PROTOCOL_VERSION;
    mCurGroupId = "";
    mCurCallType = TRTCCalling.TYPE_UNKNOWN;
  }

  _internalCall() {}

  @override
  Future<ActionCallback> accept() async {
    _enterTRTCRoom();
    V2TimCallback res = await timManager
        .getSignalingManager()
        .accept(inviteID: mCurCallID, data: _getCurMap());
    return ActionCallback(code: res.code, desc: res.desc);
  }

  @override
  void closeCamera() {
    mTRTCCloud.stopLocalPreview();
  }

  @override
  void hangup() async {
    if (!isOnCalling) {
      reject();
      return;
    }

    if (mCurGroupId.isEmpty) {
      if (mEnterRoomTime != 0) {
        // realCallModel.duration =
        //     (int)(System.currentTimeMillis() - mEnterRoomTime) / 1000;
        mEnterRoomTime = 0;
      }
    } else {}
    V2TimCallback res = await timManager
        .getSignalingManager()
        .cancel(inviteID: mCurCallID, data: _getCurMap());
    _stopCall();
    _exitRoom();
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
  void openCamera(bool isFrontCamera, int viewId) {
    mTRTCCloud.startLocalPreview(isFrontCamera, viewId);
  }

  @override
  Future<ActionCallback> reject() async {
    V2TimCallback res = await timManager
        .getSignalingManager()
        .reject(inviteID: mCurCallID, data: _getCurMap());
    _stopCall();
    return ActionCallback(code: res.code, desc: res.desc);
  }

  @override
  void setHandsFree(bool isHandsFree) {
    if (isHandsFree) {
      txDeviceManager.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
    } else {
      txDeviceManager.setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE);
    }
  }

  @override
  void setMicMute(bool isMute) {
    mTRTCCloud.muteLocalAudio(isMute);
  }

  @override
  void startRemoteView(String userId, int streamType, int viewId) {
    mTRTCCloud.startRemoteView(userId, streamType, viewId);
  }

  @override
  void stopRemoteView(String userId, int streamType) {
    mTRTCCloud.stopRemoteView(userId, streamType);
  }

  @override
  void switchCamera(bool isFrontCamera) {
    txDeviceManager.switchCamera(isFrontCamera);
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

  _sendModel(String model) {
    switch (model) {
      case 'ACTION_DIALING_ONE':
        {
          timManager.getSignalingManager().invite(
              invitee: null,
              data: null,
              timeout: TIME_OUT_COUNT,
              onlineUserOnly: null);
          break;
        }
      case 'ACTION_DIALING_GROUP':
        {
          break;
        }
    }
  }
}

/// @nodoc
typedef VoiceListenerFunc<P> = void Function(
    TRTCCallingDelegate type, P params);
