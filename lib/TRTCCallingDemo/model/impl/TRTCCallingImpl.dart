import 'dart:convert';
import 'dart:math';

import 'package:tencent_im_sdk_plugin/enum/group_add_opt_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
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

class TRTCCallingImpl extends TRTCCalling {
  String logTag = "VoiceRoomFlutterSdk";
  static TRTCCallingImpl sInstance;
  static VoiceRoomListener listener;

  int TIME_OUT_COUNT = 30; //超时时间，默认30s

  int codeErr = -1;

  // 是否首次邀请
  bool isOnCalling = false;
  bool mIsInRoom = false;
  int mEnterRoomTime = 0;
  String mCurCallID = "";
  int mCurRoomID = 0;
  String mCurGroupId = ""; //当前群组通话的群组ID
  /*
   * 当前邀请列表
   * C2C通话时会记录自己邀请的用户
   * IM群组通话时会同步群组内邀请的用户
   * 当用户接听、拒绝、忙线、超时会从列表中移除该用户
   */
  List<String> mCurInvitedList = [];
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
  void registerListener(VoiceListenerFunc func) async {
    if (listener == null) {
      listener = VoiceRoomListener(mTRTCCloud, timManager);
    }
    listener.addListener(func);
  }

  @override
  void unRegisterListener(VoiceListenerFunc func) async {
    listener.removeListener(func, mTRTCCloud, timManager);
  }

  @override
  Future<ActionCallback> login(
      int sdkAppId, String userId, String userSig) async {
    mSdkAppId = sdkAppId;
    mCurUserId = userId;
    mCurUserSig = userSig;

    if (!mIsInitIMSDK) {
      listener = VoiceRoomListener(mTRTCCloud, timManager);
      //初始化SDK
      V2TimValueCallback<bool> initRes = await timManager.initSDK(
        sdkAppID: sdkAppId, //填入在控制台上申请的sdkappid
        loglevel: LogLevel.V2TIM_LOG_ERROR,
        listener: listener.initImLisener,
      );
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

    V2TimValueCallback res = await timManager.getSignalingManager().invite(
        invitee: userId,
        data: _getCurMap(),
        timeout: TIME_OUT_COUNT,
        onlineUserOnly: false);
    mCurCallID = res.data;
    return ActionCallback(code: res.code, desc: res.desc);
  }

  _getCurMap() {
    Map<String, Object> customMap;
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
    return ActionCallback(code: res.code, desc: res.data);
  }

  _isListEmpty(List list) {
    return list == null || list.length == 0;
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
        .accept(inviteID: mCurSponsorForMe, data: _getCurMap());
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

    if (mCurGroupId == "" || mCurGroupId == null) {
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
        .reject(inviteID: mCurSponsorForMe, data: _getCurMap());
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
