import 'dart:convert';
import 'package:tencent_im_sdk_plugin/enum/log_level_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority_enum.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:tencent_trtc_cloud/tx_device_manager.dart';
import 'package:tencent_trtc_cloud/tx_beauty_manager.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin/enum/group_add_opt_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import '../TRTCMeeting.dart';
import '../TRTCMeetingDef.dart';
import '../TRTCMeetingDelegate.dart';

class TRTCMeetingImpl extends TRTCMeeting {
  String logTag = 'TRTCMeetingImpl';
  late int mSdkAppId;
  late String mUserId;
  late String mUserSig;
  bool mIsInitIMSDK = false;
  bool mIsLogin = false;
  bool mIsEnterMeeting = false;
  int codeErr = -1;
  int customCmd = 301;
  Set<MeetingListenerFunc> listeners = Set();

  static TRTCMeetingImpl? sInstance;
  String? mRoomId;
  String? mSelfUserName;
  String? mSelfAvatar;
  String? mOwnerUserId;

  late TRTCCloud mTRTCCloud;
  late TXDeviceManager txDeviceManager;
  late TXBeautyManager txBeautyManager;
  late V2TIMManager timManager;

  TRTCMeetingImpl() {
    timManager = TencentImSDKPlugin.v2TIMManager;
    initTRTC();
  }

  initTRTC() async {
    mTRTCCloud = (await TRTCCloud.sharedInstance())!;
    txDeviceManager = mTRTCCloud.getDeviceManager();
    txBeautyManager = mTRTCCloud.getBeautyManager();
  }

  static sharedInstance() {
    if (sInstance == null) {
      sInstance = new TRTCMeetingImpl();
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
  void registerListener(MeetingListenerFunc func) {
    if (listeners.isEmpty) {
      timManager.addGroupListener(listener: groupListener());
      timManager.addSimpleMsgListener(listener: simpleMsgListener());
      mTRTCCloud.registerListener(rtcListener);
    }

    listeners.add(func);
  }

  @override
  void unRegisterListener(MeetingListenerFunc func) {
    listeners.remove(func);

    if (listeners.isEmpty) {
      mTRTCCloud.unRegisterListener(rtcListener);
      timManager.removeSimpleMsgListener();
      timManager.removeGroupListener();
    }
  }

  @override
  Future<ActionCallback> login(
      int sdkAppId, String userId, String userSig) async {
    mSdkAppId = sdkAppId;
    mUserId = userId;
    mUserSig = userSig;

    if (!mIsInitIMSDK) {
      V2TimValueCallback<bool> initRes = await timManager.initSDK(
          sdkAppID: sdkAppId,
          loglevel: LogLevelEnum.V2TIM_LOG_ERROR,
          listener: new V2TimSDKListener(onKickedOffline: () {
            TRTCMeetingDelegate type = TRTCMeetingDelegate.onKickedOffline;
            emitEvent(type, {});
          }));

      if (initRes.code != 0) {
        return ActionCallback(code: codeErr, desc: initRes.desc);
      }
    }

    mIsInitIMSDK = true;

    String? loginedUserId = (await timManager.getLoginUser()).data;

    if (loginedUserId != null && loginedUserId == userId) {
      mIsLogin = true;
      return ActionCallback(code: 0, desc: 'Login IM success.');
    }

    V2TimCallback loginRes =
        await timManager.login(userID: userId, userSig: userSig);

    if (loginRes.code == 0) {
      mIsLogin = true;
      return ActionCallback(code: 0, desc: 'Login IM success.');
    } else {
      mIsLogin = false;
      return ActionCallback(code: codeErr, desc: loginRes.desc);
    }
  }

  @override
  Future<ActionCallback> logout() async {
    V2TimCallback logoutRes = await timManager.logout();
    mSdkAppId = 0;
    mUserId = '';
    mUserSig = '';
    mIsLogin = false;
    mSelfUserName = '';
    mSelfAvatar = '';
    return ActionCallback(code: logoutRes.code, desc: logoutRes.desc);
  }

  @override
  Future<ActionCallback> setSelfProfile(
      String userName, String avatarURL) async {
    mSelfUserName = userName;
    mSelfAvatar = avatarURL;
    V2TimCallback res = await timManager.setSelfInfo(
        userFullInfo:
            V2TimUserFullInfo(nickName: userName, faceUrl: avatarURL));
    if (res.code == 0) {
      return ActionCallback(code: 0, desc: 'Set profile success.');
    } else {
      return ActionCallback(code: res.code, desc: res.desc);
    }
  }

  @override
  Future<ActionCallback> createMeeting(int roomId) async {
    if (!mIsLogin) {
      return ActionCallback(
          code: codeErr, desc: 'IM not login yet, create meeting fail.');
    }

    V2TimValueCallback<String> res =
        await timManager.getGroupManager().createGroup(
              groupType: 'Meeting',
              groupName: roomId.toString(),
              groupID: roomId.toString(),
            );
    String desc = res.desc;
    int code = res.code;

    if (code == 0) {
      desc = 'Create meeting success.';
    } else if (code == 10036) {
      desc =
          '您当前使用的云通讯账号未开通音视频聊天室功能，创建聊天室数量超过限额，请前往腾讯云官网开通【IM音视频聊天室】，地址：https://cloud.tencent.com/document/product/269/11673';
    } else if (code == 10037) {
      desc =
          '单个用户可创建和加入的群组数量超过了限制，请购买相关套餐,价格地址：https://cloud.tencent.com/document/product/269/11673';
    } else if (code == 10038) {
      desc =
          '群成员数量超过限制，请参考，请购买相关套餐，价格地址：https://cloud.tencent.com/document/product/269/11673';
    } else if (code == 10025 || code == 10021) {
      V2TimCallback joinRes =
          await timManager.joinGroup(groupID: roomId.toString(), message: '');

      if (joinRes.code == 0) {
        code = 0;
        desc = 'Group has been created. Join group success.';
      } else {
        code = joinRes.code;
        desc = joinRes.desc;
      }
    }

    if (code == 0 || code == 10013) {
      mRoomId = roomId.toString();
      mIsEnterMeeting = true;
      mTRTCCloud.callExperimentalAPI(
          "{\"api\": \"setFramework\", \"params\": {\"framework\": 7, \"component\": 5}}");
      mTRTCCloud.enterRoom(
        TRTCParams(
          sdkAppId: mSdkAppId,
          userId: mUserId,
          userSig: mUserSig,
          roomId: roomId,
          role: TRTCCloudDef.TRTCRoleAnchor,
        ),
        TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL,
      );

      timManager.getGroupManager().setGroupInfo(
              info: V2TimGroupInfo(
            groupType: 'Meeting',
            groupName: roomId.toString(),
            groupID: roomId.toString(),
            groupAddOpt: GroupAddOptType.V2TIM_GROUP_ADD_ANY,
            introduction: mSelfUserName,
          ));
    }

    return ActionCallback(code: code, desc: desc);
  }

  @override
  Future<ActionCallback> destroyMeeting(int roomId) async {
    V2TimCallback dismissRes =
        await timManager.dismissGroup(groupID: roomId.toString());

    if (dismissRes.code == 0) {
      mIsEnterMeeting = false;
      await mTRTCCloud.exitRoom();
      return ActionCallback(code: 0, desc: 'Dismiss meeting success.');
    } else {
      return ActionCallback(code: dismissRes.code, desc: dismissRes.desc);
    }
  }

  @override
  Future<ActionCallback> enterMeeting(int roomId) async {
    if (mIsEnterMeeting) {
      return ActionCallback(
          code: codeErr,
          desc: 'You have been in room: ' +
              mRoomId! +
              '. Can\'t create another room: ' +
              roomId.toString() +
              '.');
    }

    V2TimCallback joinRes =
        await timManager.joinGroup(groupID: roomId.toString(), message: '');

    if (joinRes.code == 0 || joinRes.code == 10013) {
      mRoomId = roomId.toString();
      mIsEnterMeeting = true;
      await mTRTCCloud.enterRoom(
        TRTCParams(
          sdkAppId: mSdkAppId,
          userId: mUserId,
          userSig: mUserSig,
          roomId: roomId,
          role: TRTCCloudDef.TRTCRoleAnchor,
        ),
        TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL,
      );
      mTRTCCloud.callExperimentalAPI(
          "{\"api\": \"setFramework\", \"params\": {\"framework\": 7, \"component\": 5}}");

      V2TimValueCallback<List<V2TimGroupInfoResult>> res = await timManager
          .getGroupManager()
          .getGroupsInfo(groupIDList: [roomId.toString()]);
      List<V2TimGroupInfoResult> groupResult = res.data!;
      mOwnerUserId = groupResult[0].groupInfo!.owner!;
    }

    return ActionCallback(code: joinRes.code, desc: joinRes.desc);
  }

  @override
  Future<ActionCallback> leaveMeeting() async {
    if (mRoomId == null) {
      return ActionCallback(code: codeErr, desc: 'Not enter meeting yet.');
    }

    mIsEnterMeeting = false;
    await mTRTCCloud.exitRoom();
    V2TimCallback quitRes = await timManager.quitGroup(groupID: mRoomId!);

    if (quitRes.code != 0) {
      return ActionCallback(code: codeErr, desc: quitRes.desc);
    }

    return ActionCallback(code: 0, desc: 'Quit meeting success.');
  }

  @override
  Future<UserListCallback> getUserInfoList(List<String> userIdList) async {
    V2TimValueCallback<List<V2TimUserFullInfo>> res =
        await timManager.getUsersInfo(userIDList: userIdList);
    if (res.code == 0) {
      List<V2TimUserFullInfo> userInfo = res.data!;
      List<UserInfo> newInfo = [];
      for (var i = 0; i < userInfo.length; i++) {
        newInfo.add(UserInfo(
          userId: userInfo[i].userID,
          userName: userInfo[i].nickName,
          userAvatar: userInfo[i].faceUrl,
        ));
      }
      return UserListCallback(
          code: 0, desc: 'Get user info success.', list: newInfo);
    } else {
      return UserListCallback(code: res.code, desc: res.desc);
    }
  }

  @override
  Future<UserListCallback> getUserInfo(String userId) {
    return getUserInfoList([userId]);
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
  Future<void> updateRemoteView(int viewId, int streamType, String userId) {
    return mTRTCCloud.updateRemoteView(userId, streamType, viewId);
  }

  @override
  Future<void> setRemoteViewParam(String userId, int streamType,
      {int fillMode = TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL,
      int rotation = TRTCCloudDef.TRTC_VIDEO_ROTATION_0,
      int mirrorType = TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_AUTO}) {
    return mTRTCCloud.setRemoteRenderParams(
      userId,
      streamType,
      TRTCRenderParams(
          fillMode: fillMode, rotation: rotation, mirrorType: mirrorType),
    );
  }

  @override
  Future<void> muteRemoteAudio(String userId, bool mute) {
    return mTRTCCloud.muteRemoteAudio(userId, mute);
  }

  @override
  Future<void> muteAllRemoteAudio(bool mute) {
    return mTRTCCloud.muteAllRemoteAudio(mute);
  }

  @override
  Future<void> muteRemoteVideoStream(String userId, bool mute) {
    return mTRTCCloud.muteRemoteVideoStream(userId, mute);
  }

  @override
  Future<void> muteAllRemoteVideoStream(bool mute) {
    return mTRTCCloud.muteAllRemoteVideoStreams(mute);
  }

  @override
  Future<void> startCameraPreview(bool isFront, int viewId) {
    return mTRTCCloud.startLocalPreview(isFront, viewId);
  }

  @override
  Future<void> stopCameraPreview() {
    return mTRTCCloud.stopLocalPreview();
  }

  @override
  Future<void> updateCameraPreview(int viewId) {
    return mTRTCCloud.updateLocalView(viewId);
  }

  @override
  Future<void> switchCamera(bool isFront) {
    return txDeviceManager.switchCamera(isFront);
  }

  @override
  Future<void> setVideoEncoderParam({
    int videoFps = 15,
    int videoBitrate = 600,
    int videoResolution = 108,
    int videoResolutionMode = 1,
  }) {
    return mTRTCCloud.setVideoEncoderParam(TRTCVideoEncParam(
      videoFps: videoFps,
      videoBitrate: videoBitrate,
      videoResolution: videoResolution,
      videoResolutionMode: videoResolutionMode,
    ));
  }

  @override
  Future<void> setLocalViewMirror(bool isMirror) {
    if (isMirror) {
      return mTRTCCloud.setLocalRenderParams(TRTCRenderParams(
          mirrorType: TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE));
    } else {
      return mTRTCCloud.setLocalRenderParams(TRTCRenderParams(
          mirrorType: TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_DISABLE));
    }
  }

  @override
  Future<void> startMicrophone({int quality = 2}) {
    return mTRTCCloud.startLocalAudio(quality);
  }

  @override
  Future<void> stopMicrophone() {
    return mTRTCCloud.stopLocalAudio();
  }

  @override
  Future<void> muteLocalAudio(bool mute) {
    return mTRTCCloud.muteLocalAudio(mute);
  }

  @override
  Future<void> setSpeaker(bool useSpeaker) {
    if (useSpeaker) {
      return txDeviceManager
          .setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER);
    } else {
      return txDeviceManager
          .setAudioRoute(TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE);
    }
  }

  @override
  Future<void> setAudioCaptureVolume(int volume) {
    return mTRTCCloud.setAudioCaptureVolume(volume);
  }

  @override
  Future<void> setAudioPlayoutVolume(int volume) {
    return mTRTCCloud.setAudioPlayoutVolume(volume);
  }

  @override
  Future<int?> startAudioRecording(String filePath) {
    return mTRTCCloud
        .startAudioRecording(TRTCAudioRecordingParams(filePath: filePath));
  }

  @override
  Future<void> stopAudioRecording() {
    return mTRTCCloud.stopAudioRecording();
  }

  @override
  Future<void> enableAudioVolumeEvaluation(int intervalMs) {
    return mTRTCCloud.enableAudioVolumeEvaluation(intervalMs);
  }

  @override
  Future<void> startScreenCapture(
      {int videoFps = 10,
      int videoBitrate = 1600,
      int videoResolution = 112,
      int videoResolutionMode = 1,
      String appGroup = ''}) {
    return mTRTCCloud.startScreenCapture(
        TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
        TRTCVideoEncParam(
            videoFps: videoFps,
            videoBitrate: videoBitrate,
            videoResolution: videoResolution,
            videoResolutionMode: videoResolutionMode),
        appGroup: appGroup);
  }

  @override
  Future<void> stopScreenCapture() {
    return mTRTCCloud.stopScreenCapture();
  }

  @override
  Future<void> pauseScreenCapture() {
    return mTRTCCloud.pauseScreenCapture();
  }

  @override
  Future<void> resumeScreenCapture() {
    return mTRTCCloud.resumeScreenCapture();
  }

  @override
  TXDeviceManager getDeviceManager() {
    return txDeviceManager;
  }

  @override
  TXBeautyManager getBeautyManager() {
    return txBeautyManager;
  }

  @override
  Future<ActionCallback> sendRoomTextMsg(String message) async {
    V2TimValueCallback<V2TimMessage> res =
        await timManager.sendGroupTextMessage(
      text: message,
      groupID: mRoomId.toString(),
      priority: MessagePriority.V2TIM_PRIORITY_NORMAL,
    );
    if (res.code == 0) {
      return ActionCallback(code: 0, desc: 'Send room message success.');
    } else {
      return ActionCallback(code: res.code, desc: res.desc);
    }
  }

  @override
  Future<ActionCallback> sendRoomCustomMsg(String cmd, String message) async {
    V2TimValueCallback<V2TimMessage> res =
        await timManager.sendGroupCustomMessage(
      customData: jsonEncode({
        'command': cmd,
        'message': message,
        'version': '1.0.0',
        'action': customCmd,
      }),
      groupID: mRoomId.toString(),
      priority: MessagePriorityEnum.V2TIM_PRIORITY_LOW,
    );
    if (res.code == 0) {
      return ActionCallback(code: 0, desc: 'Send room message success.');
    } else {
      return ActionCallback(code: res.code, desc: res.desc);
    }
  }

  emitEvent(type, params) {
    for (var item in listeners) {
      item(type, params);
    }
  }

  rtcListener(TRTCCloudListener rtcType, param) {
    TRTCMeetingDelegate type;

    switch (rtcType) {
      case TRTCCloudListener.onError:
        type = TRTCMeetingDelegate.onError;
        break;
      case TRTCCloudListener.onWarning:
        type = TRTCMeetingDelegate.onWarning;
        break;
      case TRTCCloudListener.onNetworkQuality:
        type = TRTCMeetingDelegate.onNetworkQuality;
        break;
      case TRTCCloudListener.onUserVoiceVolume:
        type = TRTCMeetingDelegate.onUserVolumeUpdate;
        break;
      case TRTCCloudListener.onEnterRoom:
        mIsEnterMeeting = param >= 0;
        type = TRTCMeetingDelegate.onEnterRoom;
        break;
      case TRTCCloudListener.onExitRoom:
        type = TRTCMeetingDelegate.onLeaveRoom;
        break;
      case TRTCCloudListener.onRemoteUserEnterRoom:
        type = TRTCMeetingDelegate.onUserEnterRoom;
        break;
      case TRTCCloudListener.onRemoteUserLeaveRoom:
        type = TRTCMeetingDelegate.onUserLeaveRoom;
        break;
      case TRTCCloudListener.onUserAudioAvailable:
        type = TRTCMeetingDelegate.onUserAudioAvailable;
        break;
      case TRTCCloudListener.onUserVideoAvailable:
        type = TRTCMeetingDelegate.onUserVideoAvailable;
        break;
      case TRTCCloudListener.onUserSubStreamAvailable:
        type = TRTCMeetingDelegate.onUserSubStreamAvailable;
        break;
      case TRTCCloudListener.onScreenCaptureStarted:
        type = TRTCMeetingDelegate.onScreenCaptureStarted;
        break;
      case TRTCCloudListener.onScreenCapturePaused:
        type = TRTCMeetingDelegate.onScreenCapturePaused;
        break;
      case TRTCCloudListener.onScreenCaptureResumed:
        type = TRTCMeetingDelegate.onScreenCaptureResumed;
        break;
      case TRTCCloudListener.onScreenCaptureStoped:
        type = TRTCMeetingDelegate.onScreenCaptureStoped;
        break;
      default:
        emitEvent(rtcType, param);
        return;
    }

    emitEvent(type, param);
  }

  groupListener() {
    TRTCMeetingDelegate type;

    return new V2TimGroupListener(
      onGroupDismissed: (String groupId, V2TimGroupMemberInfo opUser) {
        type = TRTCMeetingDelegate.onRoomDestroy;
        emitEvent(type, {'roomId': groupId});
      },
    );
  }

  simpleMsgListener() {
    TRTCMeetingDelegate type;

    return new V2TimSimpleMsgListener(
      onRecvGroupCustomMessage: (String msgId, String groupId,
          V2TimGroupMemberInfo sender, String customData) {
        try {
          Map<String, dynamic>? customMap = jsonDecode(customData);

          if (customMap == null) return;

          if (customMap.containsKey('command') &&
              customMap.containsKey('action') &&
              customMap['action'] == customCmd) {
            type = TRTCMeetingDelegate.onRecvRoomCustomMsg;
            emitEvent(type, {
              'command': customMap['command'],
              'message': customMap['message'],
              'sendId': sender.userID,
              'userAvatar': sender.faceUrl,
              'userName': sender.nickName,
            });
          }
        } catch (e) {
          print(
              logTag + ' onRecvGroupCustomMessage error log. ' + e.toString());
        }
      },
      onRecvGroupTextMessage: (String msgId, String groupId,
          V2TimGroupMemberInfo sender, String customData) {
        type = TRTCMeetingDelegate.onRecvRoomTextMsg;
        emitEvent(type, {
          'message': customData,
          'sendId': sender.userID,
          'userAvatar': sender.faceUrl,
          'userName': sender.nickName,
        });
      },
    );
  }
}

/// @nodoc
typedef MeetingListenerFunc<P> = void Function(
    TRTCMeetingDelegate type, P params);
