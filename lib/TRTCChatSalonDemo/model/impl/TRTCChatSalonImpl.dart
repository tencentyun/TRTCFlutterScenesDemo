import 'package:tencent_im_sdk_plugin/enum/group_add_opt_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';

import '../TRTCChatSalon.dart';
import '../TRTCChatSalonDef.dart';
import '../TRTCChatSalonDelegate.dart';

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

class TRTCChatSalonImpl extends TRTCChatSalon {
  String logTag = "VoiceRoomFlutterSdk";
  static TRTCChatSalonImpl? sInstance;
  static VoiceRoomListener? listener;

  int codeErr = -1;

  late int mSdkAppId;
  late String mUserId;
  late String mUserSig;
  String? mRoomId;
  String? mOwnerUserId;
  String? mSelfUserName;
  bool mIsInitIMSDK = false;
  bool mIsLogin = false;
  String mRole = "audience"; //默认为观众，archor为主播
  late V2TIMManager timManager;
  late TRTCCloud mTRTCCloud;
  late TXAudioEffectManager txAudioManager;
  late TXDeviceManager txDeviceManager;

  TRTCChatSalonImpl() {
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
      sInstance = new TRTCChatSalonImpl();
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
  Future<ActionCallback> createRoom(int roomId, RoomParam roomParam) async {
    if (!mIsLogin) {
      return ActionCallback(
          code: codeErr, desc: 'im not login yet, create room fail.');
    }
    mOwnerUserId = mUserId;
    V2TimValueCallback<String> res = await timManager
        .getGroupManager()
        .createGroup(
            groupType: "AVChatRoom",
            groupName: roomParam.roomName,
            groupID: roomId.toString());
    String msg = res.desc;
    int code = res.code;
    if (code == 0) {
      msg = 'create room success';
    } else if (code == 10036) {
      msg =
          "您当前使用的云通讯账号未开通音视频聊天室功能，创建聊天室数量超过限额，请前往腾讯云官网开通【IM音视频聊天室】，地址：https://cloud.tencent.com/document/product/269/11673";
    } else if (code == 10037) {
      msg =
          "单个用户可创建和加入的群组数量超过了限制，请购买相关套餐,价格地址：https://cloud.tencent.com/document/product/269/11673";
    } else if (code == 10038) {
      msg =
          "群成员数量超过限制，请参考，请购买相关套餐，价格地址：https://cloud.tencent.com/document/product/269/11673";
    } else if (code == 10025 || code == 10021) {
      // 10025 表明群主是自己，那么认为创建房间成功
      // 群组 ID 已被其他人使用，此时走进房逻辑
      V2TimCallback joinRes =
          await timManager.joinGroup(groupID: roomId.toString(), message: "");
      if (joinRes.code == 0) {
        code = 0;
        msg = 'group has been created.join group success.';
      } else {
        code = joinRes.code;
        msg = joinRes.desc;
      }
    }
    //setGroupInfos
    if (code == 0) {
      mRoomId = roomId.toString();
      mTRTCCloud.enterRoom(
          TRTCParams(
              sdkAppId: mSdkAppId, //应用Id
              userId: mUserId, // 用户Id
              userSig: mUserSig, // 用户签名
              role: TRTCCloudDef.TRTCRoleAnchor,
              roomId: roomId),
          TRTCCloudDef.TRTC_APP_SCENE_VOICE_CHATROOM);
      // 默认打开麦克风
      await enableAudioVolumeEvaluation(true);
      mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
      // 设置群信息
      // timManager.getGroupManager().setGroupInfo(
      //     addOpt: GroupAddOptType.V2TIM_GROUP_ADD_ANY,
      //     groupID: roomId.toString(),
      //     groupName: roomParam.roomName,
      //     faceUrl: roomParam.coverUrl,
      //     introduction: mSelfUserName);

      timManager.getGroupManager().setGroupInfo(
          info: V2TimGroupInfo(
              groupAddOpt: GroupAddOptType.V2TIM_GROUP_ADD_ANY,
              groupID: roomId.toString(),
              groupName: roomParam.roomName,
              faceUrl: roomParam.coverUrl,
              introduction: mSelfUserName,
              groupType: "AVChatRoom"));

      listener!.initData(mOwnerUserId!, {mUserId: "1"});
      V2TimCallback initRes = await timManager
          .getGroupManager()
          .initGroupAttributes(groupID: mRoomId!, attributes: {mUserId: "1"});

      if (initRes.code != 0) {
        return ActionCallback(code: initRes.code, desc: initRes.desc);
      }
    }
    return ActionCallback(code: code, desc: msg);
  }

  enableAudioVolumeEvaluation(bool enable) async {
    await mTRTCCloud.enableAudioVolumeEvaluation(enable ? 500 : 0);
  }

  @override
  Future<ActionCallback> destroyRoom() async {
    V2TimCallback dismissRes = await timManager.dismissGroup(groupID: mRoomId!);
    if (dismissRes.code == 0) {
      await mTRTCCloud.exitRoom();
      return ActionCallback(code: 0, desc: "dismiss room success.");
    } else {
      return ActionCallback(code: codeErr, desc: "dismiss room fail.");
    }
  }

  @override
  Future<ActionCallback> enterRoom(int roomId) async {
    V2TimCallback joinRes =
        await timManager.joinGroup(groupID: roomId.toString(), message: '');
    if (joinRes.code == 0 || joinRes.code == 10013) {
      mRoomId = roomId.toString();
      mTRTCCloud.enterRoom(
          TRTCParams(
              sdkAppId: mSdkAppId, //应用Id
              userId: mUserId, // 用户Id
              userSig: mUserSig, // 用户签名
              role: TRTCCloudDef.TRTCRoleAudience,
              roomId: roomId),
          TRTCCloudDef.TRTC_APP_SCENE_LIVE);
      V2TimValueCallback<List<V2TimGroupInfoResult>> res = await timManager
          .getGroupManager()
          .getGroupsInfo(groupIDList: [roomId.toString()]);
      List<V2TimGroupInfoResult> groupResult = res.data!;
      mOwnerUserId = groupResult[0].groupInfo!.owner!;

      V2TimValueCallback<Map<String, String>> attrRes = await timManager
          .getGroupManager()
          .getGroupAttributes(groupID: mRoomId!, keys: []);
      Map<String, String> attributeMap = attrRes.data!;
      listener!.initData(mUserId, attributeMap);
    }

    return ActionCallback(code: joinRes.code, desc: joinRes.desc);
  }

  @override
  Future<ActionCallback> exitRoom() async {
    if (mRoomId == null) {
      return ActionCallback(code: codeErr, desc: "not enter room yet");
    }
    await mTRTCCloud.exitRoom();
    //角色为主播，需要删除群属性，删除主播列表
    if (mRole == "archor") {
      //删除群属性
      V2TimCallback deleteRes = await timManager
          .getGroupManager()
          .deleteGroupAttributes(groupID: mRoomId!, keys: [mUserId]);
      if (deleteRes.code != 0) {
        return ActionCallback(code: codeErr, desc: deleteRes.desc);
      }
    }
    V2TimCallback quitRes = await timManager.quitGroup(groupID: mRoomId!);
    if (quitRes.code != 0) {
      return ActionCallback(code: codeErr, desc: quitRes.desc);
    }

    return ActionCallback(code: 0, desc: "quit room success.");
  }

  @override
  TXAudioEffectManager getAudioEffectManager() {
    return txAudioManager;
  }

  @override
  Future<RoomInfoCallback> getRoomInfoList(List<String> roomIdList) async {
    V2TimValueCallback<List<V2TimGroupInfoResult>> res = await timManager
        .getGroupManager()
        .getGroupsInfo(groupIDList: roomIdList);
    if (res.code != 0) {
      return RoomInfoCallback(code: res.code, desc: res.desc);
    }

    List<V2TimGroupInfoResult> listInfo = res.data!;

    List<RoomInfo> newInfo = [];
    for (var i = 0; i < listInfo.length; i++) {
      V2TimGroupInfo groupInfo = listInfo[i].groupInfo!;
      newInfo.add(RoomInfo(
          roomId: int.parse(groupInfo.groupID),
          roomName: groupInfo.groupName,
          coverUrl: groupInfo.faceUrl,
          ownerId: groupInfo.owner,
          ownerName: groupInfo.introduction,
          memberCount: groupInfo.memberCount));
    }

    return RoomInfoCallback(
        code: 0, desc: 'getRoomInfoList success', list: newInfo);
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
            userAvatar: userInfo[i].faceUrl));
      }
      return UserListCallback(
          code: 0, desc: 'get archorInfo success.', list: newInfo);
    } else {
      return UserListCallback(code: res.code, desc: res.desc);
    }
  }

  @override
  Future<UserListCallback> getArchorInfoList() async {
    if (mRoomId == null) {
      return UserListCallback(code: codeErr, desc: "not enter room yet");
    }
    V2TimValueCallback<Map<String, String>> attrRes = await timManager
        .getGroupManager()
        .getGroupAttributes(groupID: mRoomId!, keys: []);
    if (attrRes.code == 0) {
      Map<String, String>? attrData = attrRes.data;
      if (attrData == null) {
        return UserListCallback(
            code: 0, desc: 'get archorInfo success.', list: []);
      }
      List<String> userIdList = [];
      attrData.forEach((k, v) => userIdList.add(k));

      V2TimValueCallback<List<V2TimUserFullInfo>> res =
          await timManager.getUsersInfo(userIDList: userIdList);
      if (res.code == 0) {
        List<V2TimUserFullInfo> userInfo = res.data!;
        List<UserInfo> newInfo = [];
        for (var i = 0; i < userInfo.length; i++) {
          newInfo.add(UserInfo(
              userId: userInfo[i].userID,
              mute: attrData[userInfo[i].userID] == "1" ? false : true,
              userName: userInfo[i].nickName,
              userAvatar: userInfo[i].faceUrl));
        }
        return UserListCallback(
            code: 0, desc: 'get archorInfo success.', list: newInfo);
      } else {
        return UserListCallback(code: res.code, desc: res.desc);
      }
    } else {
      return UserListCallback(code: attrRes.code, desc: attrRes.desc);
    }
  }

  @override
  Future<int> getRoomOnlineMemberCount() async {
    V2TimValueCallback<int> memberRes = await timManager
        .getGroupManager()
        .getGroupOnlineMemberCount(groupID: mRoomId!);
    if (memberRes.code != 0) {
      return 0;
    }
    return memberRes.data!;
  }

  @override
  Future<MemberListCallback> getRoomMemberList(int nextSeq) async {
    V2TimValueCallback<V2TimGroupMemberInfoResult> memberRes = await timManager
        .getGroupManager()
        .getGroupMemberList(
            groupID: mRoomId!,
            filter: GroupMemberFilterType.V2TIM_GROUP_MEMBER_FILTER_ALL,
            nextSeq: nextSeq);
    if (memberRes.code != 0) {
      return MemberListCallback(code: memberRes.code, desc: memberRes.desc);
    }
    List<V2TimGroupMemberFullInfo?> memberInfoList =
        memberRes.data!.memberInfoList!;
    List<UserInfo> newInfo = [];
    for (var i = 0; i < memberInfoList.length; i++) {
      newInfo.add(UserInfo(
          userId: memberInfoList[i]!.userID,
          userName: memberInfoList[i]!.nickName,
          userAvatar: memberInfoList[i]!.faceUrl));
    }
    return MemberListCallback(
        code: 0,
        desc: 'get member list success',
        nextSeq: memberRes.data!.nextSeq!,
        list: newInfo);
  }

  @override
  Future<ActionCallback> logout() async {
    V2TimCallback loginRes = await timManager.logout();
    return ActionCallback(code: loginRes.code, desc: loginRes.desc);
  }

  @override
  void muteAllRemoteAudio(bool mute) {
    mTRTCCloud.muteAllRemoteAudio(mute);
  }

  @override
  void muteLocalAudio(bool mute) {
    mTRTCCloud.muteLocalAudio(mute);
  }

  @override
  void muteRemoteAudio(String userId, bool mute) {
    mTRTCCloud.muteRemoteAudio(userId, mute);
  }

  @override
  Future<ActionCallback> sendRoomTextMsg(String message) async {
    V2TimValueCallback<V2TimMessage> res =
        await timManager.sendGroupTextMessage(
            text: message,
            groupID: mRoomId.toString(),
            priority: MessagePriority.V2TIM_PRIORITY_NORMAL);
    if (res.code == 0) {
      return ActionCallback(code: 0, desc: "send group message success.");
    } else {
      return ActionCallback(
          code: res.code, desc: "send room text fail, not enter room yet.");
    }
  }

  @override
  void setAudioCaptureVolume(int volume) {
    mTRTCCloud.setAudioCaptureVolume(volume);
  }

  @override
  void setAudioPlayoutVolume(int volume) {
    mTRTCCloud.setAudioPlayoutVolume(volume);
  }

  @override
  void registerListener(VoiceListenerFunc func) async {
    if (listener == null) {
      listener = VoiceRoomListener(mTRTCCloud, timManager);
    }
    listener!.addListener(func);
  }

  @override
  void unRegisterListener(VoiceListenerFunc func) async {
    listener!.removeListener(func, mTRTCCloud, timManager);
  }

  @override
  Future<ActionCallback> setSelfProfile(
      String userName, String avatarURL) async {
    mSelfUserName = userName;
    V2TimCallback res =
        // await timManager.setSelfInfo(nickName: userName, faceUrl: avatarURL);
        await timManager.setSelfInfo(
            userFullInfo:
                V2TimUserFullInfo(nickName: userName, faceUrl: avatarURL));
    if (res.code == 0) {
      return ActionCallback(code: 0, desc: "set profile success.");
    } else {
      return ActionCallback(code: res.code, desc: "set profile fail.");
    }
  }

  @override
  void setSpeaker(bool useSpeaker) {
    txDeviceManager.setAudioRoute(useSpeaker
        ? TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER
        : TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE);
  }

  @override
  void startMicrophone(int quality) {
    mTRTCCloud.startLocalAudio(quality);
  }

  @override
  void stopMicrophone() {
    mTRTCCloud.stopLocalAudio();
  }

  @override
  Future<ActionCallback> login(
      int sdkAppId, String userId, String userSig) async {
    mSdkAppId = sdkAppId;
    mUserId = userId;
    mUserSig = userSig;

    if (!mIsInitIMSDK) {
      listener = VoiceRoomListener(mTRTCCloud, timManager);
      //初始化SDK
      V2TimValueCallback<bool> initRes = await timManager.initSDK(
        sdkAppID: sdkAppId, //填入在控制台上申请的sdkappid
        loglevel: LogLevel.V2TIM_LOG_ERROR,
        listener: listener!.initImLisener(),
      );
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
  Future<ActionCallback> agreeToSpeak(String userId) async {
    V2TimValueCallback<V2TimMessage> res = await timManager
        .sendC2CCustomMessage(customData: 'agreeToSpeak', userID: userId);

    if (res.code == 0) {
      return ActionCallback(code: 0, desc: 'agreeToSpeak success');
    } else {
      return ActionCallback(code: codeErr, desc: res.desc);
    }
  }

  @override
  Future<ActionCallback> kickMic(String userId) async {
    if (mRoomId == null) {
      return ActionCallback(code: codeErr, desc: 'mRoomId is not valid');
    }
    V2TimValueCallback<V2TimMessage> res = await timManager
        .sendC2CCustomMessage(customData: 'kickMic', userID: userId);
    if (res.code == 0) {
      return ActionCallback(code: 0, desc: 'kickMic success');
    } else {
      return ActionCallback(code: codeErr, desc: res.desc);
    }
  }

  @override
  Future<ActionCallback> enterMic() async {
    if (mRoomId == null) {
      return ActionCallback(code: codeErr, desc: 'mRoomId is not valid');
    }

    //设置群属性
    V2TimCallback setRes = await timManager
        .getGroupManager()
        .setGroupAttributes(groupID: mRoomId!, attributes: {mUserId: "1"});
    if (setRes.code == 0) {
      mRole = "archor";
      //切换trtc角色为主播
      await mTRTCCloud.switchRole(TRTCCloudDef.TRTCRoleAnchor);
      await enableAudioVolumeEvaluation(true);
      mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
      return ActionCallback(code: 0, desc: 'enterMic success');
    } else {
      return ActionCallback(code: codeErr, desc: setRes.desc);
    }
  }

  @override
  Future<ActionCallback> leaveMic() async {
    if (mRoomId == null) {
      return ActionCallback(code: codeErr, desc: 'mRoomId is not valid');
    }

    //删除群属性
    V2TimCallback res = await timManager
        .getGroupManager()
        .deleteGroupAttributes(groupID: mRoomId!, keys: [mUserId]);
    if (res.code == 0) {
      mRole = "audience";
      //切换trtc角色为观众
      await mTRTCCloud.switchRole(TRTCCloudDef.TRTCRoleAudience);
      await enableAudioVolumeEvaluation(false);
      mTRTCCloud.stopLocalAudio();
      return ActionCallback(code: 0, desc: 'leaveMic success');
    } else {
      return ActionCallback(code: codeErr, desc: res.desc);
    }
  }

  @override
  Future<ActionCallback> muteMic(bool mute) async {
    //更新群属性
    V2TimCallback setRes = await timManager
        .getGroupManager()
        .setGroupAttributes(
            groupID: mRoomId!, attributes: {mUserId: mute ? "0" : "1"});
    if (setRes.code == 0) {
      mTRTCCloud.muteLocalAudio(mute);
      return ActionCallback(code: 0, desc: 'muteMic success');
    } else {
      return ActionCallback(code: setRes.code, desc: setRes.desc);
    }
  }

  @override
  Future<ActionCallback> raiseHand() async {
    if (mOwnerUserId == null) {
      return ActionCallback(code: codeErr, desc: 'mOwnerUserId is not valid');
    }
    V2TimValueCallback<V2TimMessage> res = await timManager
        .sendC2CCustomMessage(customData: 'raiseHand', userID: mOwnerUserId!);
    if (res.code == 0) {
      return ActionCallback(code: 0, desc: 'raiseHand success');
    } else {
      return ActionCallback(code: codeErr, desc: res.desc);
    }
  }

  @override
  Future<ActionCallback> refuseToSpeak(String userId) async {
    V2TimValueCallback<V2TimMessage> res = await timManager
        .sendC2CCustomMessage(customData: 'refuseToSpeak', userID: userId);

    if (res.code == 0) {
      return ActionCallback(code: 0, desc: 'refuseToSpeak success');
    } else {
      return ActionCallback(code: codeErr, desc: res.desc);
    }
  }
}
