import 'dart:convert';

import 'package:tencent_im_sdk_plugin/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/group_add_opt_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_type.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/model/TRTCLiveRoomDef.dart';

import '../TRTCLiveRoom.dart';
import '../TRTCLiveRoomDelegate.dart';
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
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSignalingListener.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';

class TRTCLiveRoomImpl extends TRTCLiveRoom {
  String logTag = "TRTCLiveRoomImpl";
  String requestAnchorCMD = "requestJoinAnchor"; //请求成为主播信令
  String kickoutAnchorCMD = "kickoutJoinAnchor"; //踢出主播信令
  String requestRoomPKCMD = "requestRoomPK"; //请求跨房信令
  String quitRoomPKCMD = "quitRoomPK"; //退出跨房PK信令
  int liveCustomCmd = 301;
  static TRTCLiveRoomImpl? sInstance;
  late V2TIMManager timManager;
  late TRTCCloud mTRTCCloud;
  late TXAudioEffectManager txAudioManager;
  late TXDeviceManager txDeviceManager;
  Set<VoiceListenerFunc> listeners = Set();

  late int mSdkAppId;
  late String mUserId;
  late String mUserSig;
  late String mOwnerUserId; //群主用户id
  bool mIsInitIMSDK = false;
  bool mIsLogin = false;
  bool mIsEnterRoom = false;
  int codeErr = -1;
  int timeOutCount = 30; //超时时间，默认30s
  String? mRoomIdPK;
  String? mUserIdPK;
  String? mRoomId;
  String? mSelfUserName;
  String? mSelfAvatar;
  String? mStreamId;
  String mCurCallID = "";
  String mCurPKCallID = "";
  bool isPk = false;
  late int mOriginRole;
  TRTCLiveRoomConfig? mRoomConfig;
  // List<IMAnchorInfo> mAnchorList = [];
  List<String> mAnchorList = [];
  List<String> mAudienceList = [];

  TRTCLiveRoomImpl() {
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
      sInstance = new TRTCLiveRoomImpl();
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
    if (mIsEnterRoom) {
      return ActionCallback(
          code: codeErr,
          desc: "you have been in room:" +
              mRoomId! +
              " can't create another room:" +
              roomId.toString());
    }
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
      mIsEnterRoom = true;
      mOriginRole = TRTCCloudDef.TRTCRoleAnchor;
      mTRTCCloud.enterRoom(
          TRTCParams(
              sdkAppId: mSdkAppId, //应用Id
              userId: mUserId, // 用户Id
              userSig: mUserSig, // 用户签名
              role: TRTCCloudDef.TRTCRoleAnchor,
              roomId: roomId),
          TRTCCloudDef.TRTC_APP_SCENE_LIVE);
      // 默认打开麦克风
      // await enableAudioVolumeEvaluation(true);
      if (roomParam.quality != null) {
        mTRTCCloud.startLocalAudio(roomParam.quality!);
      } else {
        mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);
      }

      // mAnchorList.add(IMAnchorInfo(
      //     userId: mUserId, name: mSelfUserName, streamId: mStreamId));
      mAnchorList.add(mUserId);
      timManager.getGroupManager().setGroupInfo(
          info: V2TimGroupInfo(
              groupAddOpt: GroupAddOptType.V2TIM_GROUP_ADD_ANY,
              groupID: roomId.toString(),
              groupName: roomParam.roomName,
              faceUrl: roomParam.coverUrl,
              introduction: mSelfUserName,
              groupType: "AVChatRoom"));
    }
    return ActionCallback(code: code, desc: msg);
  }

  @override
  Future<ActionCallback> destroyRoom() async {
    V2TimCallback dismissRes = await timManager.dismissGroup(groupID: mRoomId!);
    if (dismissRes.code == 0) {
      _destroyData();
      await mTRTCCloud.exitRoom();
      return ActionCallback(code: 0, desc: "dismiss room success.");
    } else {
      return ActionCallback(code: codeErr, desc: "dismiss room fail.");
    }
  }

  _destroyData() {
    mIsEnterRoom = false;
    isPk = false;
    mCurCallID = "";
    mCurPKCallID = "";
    mAnchorList = [];
  }

  @override
  Future<ActionCallback> enterRoom(int roomId) async {
    if (mIsEnterRoom) {
      return ActionCallback(
          code: codeErr,
          desc: "you have been in room:" +
              mRoomId! +
              " can't create another room:" +
              roomId.toString());
    }
    V2TimCallback joinRes =
        await timManager.joinGroup(groupID: roomId.toString(), message: '');
    if (joinRes.code == 0 || joinRes.code == 10013) {
      mRoomId = roomId.toString();
      mIsEnterRoom = true;
      mOriginRole = TRTCCloudDef.TRTCRoleAudience;
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
    }

    return ActionCallback(code: joinRes.code, desc: joinRes.desc);
  }

  @override
  Future<ActionCallback> exitRoom() async {
    if (mRoomId == null) {
      return ActionCallback(code: codeErr, desc: "not enter room yet");
    }
    _destroyData();
    await mTRTCCloud.exitRoom();

    V2TimCallback quitRes = await timManager.quitGroup(groupID: mRoomId!);
    if (quitRes.code != 0) {
      return ActionCallback(code: codeErr, desc: quitRes.desc);
    }

    return ActionCallback(code: 0, desc: "quit room success.");
  }

  @override
  Future<UserListCallback> getAnchorList() async {
    V2TimValueCallback<List<V2TimUserFullInfo>> res =
        await timManager.getUsersInfo(userIDList: mAnchorList);

    if (res.code == 0) {
      List<V2TimUserFullInfo> userInfo = res.data!;
      List<UserInfo> newInfo = [];
      for (var i = 0; i < userInfo.length; i++) {
        newInfo.add(UserInfo(
            userId: userInfo[i].userID!,
            userName: userInfo[i].nickName!,
            userAvatar: userInfo[i].faceUrl!));
      }
      return UserListCallback(
          code: 0, desc: 'get archorInfo success.', list: newInfo);
    } else {
      return UserListCallback(code: res.code, desc: res.desc);
    }
  }

  @override
  Future<UserListCallback> getRoomMemberList(int nextSeq) async {
    print("==nextSeq=" + nextSeq.toString());
    print("==mRoomId=" + mRoomId.toString());
    V2TimValueCallback<V2TimGroupMemberInfoResult> memberRes = await timManager
        .getGroupManager()
        .getGroupMemberList(
            groupID: mRoomId!,
            filter: GroupMemberFilterType.V2TIM_GROUP_MEMBER_FILTER_ALL,
            nextSeq: nextSeq);
    if (memberRes.code != 0) {
      return UserListCallback(code: memberRes.code, desc: memberRes.desc);
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
    return UserListCallback(
        code: 0,
        desc: 'get member list success',
        nextSeq: memberRes.data!.nextSeq!,
        list: newInfo);
  }

  @override
  getAudioEffectManager() {
    return mTRTCCloud.getAudioEffectManager();
  }

  @override
  getBeautyManager() {
    return mTRTCCloud.getBeautyManager();
  }

  @override
  Future<RoomInfoCallback> getRoomInfos(List<String> roomIdList) async {
    print("==roomIdList=" + roomIdList.toString());

    V2TimValueCallback<List<V2TimGroupInfoResult>> res = await timManager
        .getGroupManager()
        .getGroupsInfo(groupIDList: roomIdList);
    if (res.code != 0) {
      return RoomInfoCallback(code: res.code, desc: res.desc);
    }

    List<V2TimGroupInfoResult> listInfo = res.data!;

    List<RoomInfo> newInfo = [];
    for (var i = 0; i < listInfo.length; i++) {
      print(listInfo[i].toJson());
      if (listInfo[i].resultCode == 0) {
        //兼容获取不到群id信息的情况
        V2TimGroupInfo groupInfo = listInfo[i].groupInfo!;
        newInfo.add(RoomInfo(
            roomId: int.parse(groupInfo.groupID),
            roomName: groupInfo.groupName,
            coverUrl: groupInfo.faceUrl,
            ownerId: groupInfo.owner!,
            ownerName: groupInfo.introduction,
            memberCount: groupInfo.memberCount));
      }
    }

    return RoomInfoCallback(
        code: 0, desc: 'getRoomInfoList success', list: newInfo);
  }

  @override
  Future<ActionCallback> kickoutJoinAnchor(String userId) async {
    V2TimValueCallback res = await timManager.getSignalingManager().invite(
        invitee: userId,
        data: jsonEncode(_getCustomMap(kickoutAnchorCMD)),
        timeout: 0,
        onlineUserOnly: false);
    return ActionCallback(code: res.code, desc: res.desc);
  }

  @override
  Future<ActionCallback> login(int sdkAppId, String userId, String userSig,
      TRTCLiveRoomConfig config) async {
    mSdkAppId = sdkAppId;
    mUserId = userId;
    mUserSig = userSig;
    mRoomConfig = config;

    if (!mIsInitIMSDK) {
      //初始化SDK
      V2TimValueCallback<bool> initRes = await timManager.initSDK(
          sdkAppID: sdkAppId, //填入在控制台上申请的sdkappid
          loglevel: LogLevel.V2TIM_LOG_ERROR,
          listener: new V2TimSDKListener(onKickedOffline: () {
            TRTCLiveRoomDelegate type = TRTCLiveRoomDelegate.onKickedOffline;
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
    mSdkAppId = 0;
    mUserId = "";
    mUserSig = "";
    mIsLogin = false;
    V2TimCallback loginRes = await timManager.logout();
    return ActionCallback(code: loginRes.code, desc: loginRes.desc);
  }

  emitEvent(type, params) {
    for (var item in listeners) {
      item(type, params);
    }
  }

  @override
  Future<void> muteAllRemoteAudio(bool mute) {
    return mTRTCCloud.muteAllRemoteAudio(mute);
  }

  @override
  Future<void> muteLocalAudio(bool mute) {
    return mTRTCCloud.muteLocalAudio(mute);
  }

  @override
  Future<void> muteRemoteAudio(String userId, bool mute) {
    return mTRTCCloud.muteRemoteAudio(userId, mute);
  }

  @override
  Future<ActionCallback> quitRoomPK() async {
    V2TimValueCallback res = await timManager.getSignalingManager().invite(
        invitee: mUserIdPK!,
        data: jsonEncode(_getCustomMap(quitRoomPKCMD)),
        timeout: 0,
        onlineUserOnly: false);
    if (res.code == 0) {
      isPk = false;
      //退出跨房通话
      mTRTCCloud.disconnectOtherRoom();
    }
    return ActionCallback(code: res.code, desc: res.desc);
  }

  @override
  void registerListener(VoiceListenerFunc func) {
    if (listeners.isEmpty) {
      //监听im事件
      timManager
          .getSignalingManager()
          .addSignalingListener(listener: signalingListener());
      timManager.setGroupListener(listener: groupListener());
      timManager.addSimpleMsgListener(
        listener: simpleMsgListener(),
      );
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
      timManager.removeSimpleMsgListener();
      timManager
          .getSignalingManager()
          .removeSignalingListener(listener: signalingListener);
    }
  }

  // im 相关事件绑定
  simpleMsgListener() {
    TRTCLiveRoomDelegate type;
    return new V2TimSimpleMsgListener(
      onRecvGroupCustomMessage: (msgID, groupID, sender, customData) {
        try {
          Map<String, dynamic>? customMap = jsonDecode(customData);
          if (customMap == null) {
            print(logTag + "onRecvGroupCustomMessage extraMap is null, ignore");
            return;
          }
          if (customMap.containsKey('action') &&
              customMap.containsKey('command') &&
              customMap['action'] == liveCustomCmd) {
            //群自定义消息
            type = TRTCLiveRoomDelegate.onRecvRoomCustomMsg;
            emitEvent(type, {
              "message": customMap['message'],
              "command": customMap['command'],
              "user": {
                "userID": sender.userID,
                "userAvatar": sender.faceUrl,
                "userName": sender.nickName
              }
            });
          }
        } catch (e) {
          print(logTag + " onRecvGroupCustomMessage error log." + e.toString());
        }
      },
      onRecvGroupTextMessage: (msgID, groupID, sender, text) {
        //群文本消息
        type = TRTCLiveRoomDelegate.onRecvRoomTextMsg;
        emitEvent(type, {
          "message": text,
          "userID": sender.userID,
          "userAvatar": sender.faceUrl,
          "userName": sender.nickName
        });
      },
    );
  }

  // trtc相关事件
  rtcListener(rtcType, param) {
    String typeStr = rtcType.toString();
    TRTCLiveRoomDelegate type;
    typeStr = typeStr.replaceFirst("TRTCCloudListener.", "");
    if (typeStr == "onEnterRoom") {
      if (param < 0) {
        mIsEnterRoom = false;
      } else {
        mIsEnterRoom = true;
      }
    } else if (typeStr == "onUserVideoAvailable") {
      type = TRTCLiveRoomDelegate.onUserVideoAvailable;
      emitEvent(type, param);
    } else if (typeStr == "onError") {
      type = TRTCLiveRoomDelegate.onError;
      emitEvent(type, param);
    } else if (typeStr == "onWarning") {
      type = TRTCLiveRoomDelegate.onWarning;
      emitEvent(type, param);
    } else if (typeStr == "onUserVoiceVolume") {
      // type = TRTCLiveRoomDelegate.onUserVoiceVolume;
      // emitEvent(type, param);
    } else if (typeStr == "onRemoteUserEnterRoom") {
      // updateMixConfig();
      mAnchorList.add(param);
      type = TRTCLiveRoomDelegate.onAnchorEnter;
      emitEvent(type, param);
    } else if (typeStr == "onRemoteUserLeaveRoom") {
      // updateMixConfig();
      mAnchorList.remove(param['userId']);
      type = TRTCLiveRoomDelegate.onAnchorExit;
      emitEvent(type, param['userId']);
    } else if (typeStr == "onDisconnectOtherRoom") {
      print("==onDisconnectOtherRoom=" + param.toString());
    } else if (typeStr == "onStartPublishing") {
      print("==onStartPublishing=" + param.toString());
    }
  }

  // im群事件绑定
  groupListener() {
    TRTCLiveRoomDelegate type;
    return new V2TimGroupListener(
      onMemberEnter: (String groupId, List<V2TimGroupMemberInfo> list) {
        type = TRTCLiveRoomDelegate.onAudienceEnter;
        List<V2TimGroupMemberInfo> memberList = list;
        for (var i = 0; i < memberList.length; i++) {
          if (mAudienceList.contains(memberList[i].userID)) {
            return;
          }
          mAudienceList.add(memberList[i].userID!);
          emitEvent(type, {
            'userId': memberList[i].userID,
            'userName': memberList[i].nickName,
            'userAvatar': memberList[i].faceUrl
          });
        }
      },
      onMemberLeave: (String groupId, V2TimGroupMemberInfo member) {
        type = TRTCLiveRoomDelegate.onAudienceExit;
        emitEvent(type, {
          'userId': member.userID,
          'userName': member.nickName,
          'userAvatar': member.faceUrl
        });
      },
      onGroupDismissed: (groupID, opUser) {
        //房间被群主解散
        type = TRTCLiveRoomDelegate.onRoomDestroy;
        emitEvent(type, {});
      },
    );
  }

  //im信令事件绑定
  signalingListener() {
    return new V2TimSignalingListener(
      onInvitationCancelled: (inviteID, inviter, data) {},
      onInvitationTimeout: (inviteID, inviteeList) {
        if (inviteID == mCurCallID || inviteID == mCurPKCallID) {
          emitEvent(TRTCLiveRoomDelegate.onInvitationTimeout, {
            "inviteeList": inviteeList,
          });
        }
      },
      onInviteeAccepted: (inviteID, invitee, data) {
        if (mUserId == invitee) {
          return;
        }
        try {
          Map<String, dynamic>? customMap = jsonDecode(data);
          print("==customMap onInviteeRejected=" + customMap.toString());
          if (customMap == null) {
            print(logTag + "onReceiveNewInvitation extraMap is null, ignore");
            return;
          }
          if (customMap.containsKey('data') &&
              customMap['data']['cmd'] == requestAnchorCMD) {
            emitEvent(TRTCLiveRoomDelegate.onAnchorAccepted, {
              "userId": invitee,
            });
          } else if (customMap.containsKey('data') &&
              customMap['data']['cmd'] == requestRoomPKCMD) {
            isPk = true;
            emitEvent(TRTCLiveRoomDelegate.onRoomPKAccepted, {
              "userId": invitee,
            });
          }
        } catch (e) {
          print(logTag + " signalingListener error log.");
        }
      },
      onInviteeRejected: (inviteID, invitee, data) {
        if (mUserId == invitee) {
          return;
        }
        try {
          Map<String, dynamic>? customMap = jsonDecode(data);
          print("==customMap onInviteeRejected=" + customMap.toString());
          if (customMap == null) {
            print(logTag + "onReceiveNewInvitation extraMap is null, ignore");
            return;
          }
          if (customMap.containsKey('data') &&
              customMap['data']['cmd'] == requestAnchorCMD) {
            emitEvent(TRTCLiveRoomDelegate.onAnchorRejected, {
              "userId": invitee,
            });
          } else if (customMap.containsKey('data') &&
              customMap['data']['cmd'] == requestRoomPKCMD) {
            emitEvent(TRTCLiveRoomDelegate.onRoomPKRejected, {
              "userId": invitee,
            });
          }
        } catch (e) {
          print(logTag + " signalingListener error log.");
        }
      },
      onReceiveNewInvitation:
          (inviteID, inviter, groupID, inviteeList, data) async {
        try {
          Map<String, dynamic>? customMap = jsonDecode(data);
          print("==customMap=" + customMap.toString());

          if (customMap == null) {
            print(logTag + "onReceiveNewInvitation extraMap is null, ignore");
            return;
          }

          if (customMap.containsKey('data') &&
              customMap['data']['cmd'] == requestAnchorCMD) {
            if (isPk) {
              //在pk通话中，直接拒绝观众的主播请求
              timManager.getSignalingManager().reject(
                  inviteID: inviteID,
                  data: jsonEncode(_getCustomMap(requestAnchorCMD)));
            } else {
              mCurCallID = inviteID;
              emitEvent(TRTCLiveRoomDelegate.onRequestJoinAnchor, {
                "userId": inviter,
                "userName": customMap['data']['cmdInfo']['userName'],
                "userAvatar": customMap['data']['cmdInfo']['userAvatar'],
              });
            }
          } else if (customMap.containsKey('data') &&
              customMap['data']['cmd'] == kickoutAnchorCMD) {
            mCurCallID = inviteID;
            emitEvent(TRTCLiveRoomDelegate.onKickoutJoinAnchor, {
              "userId": inviter,
              "userName": customMap['data']['cmdInfo']['userName'],
              "userAvatar": customMap['data']['cmdInfo']['userAvatar'],
            });
          } else if (customMap.containsKey('data') &&
              customMap['data']['cmd'] == requestRoomPKCMD) {
            // 当前有两个主播直接拒绝跨房通话
            if (mAnchorList.length >= 2) {
              timManager.getSignalingManager().reject(
                  inviteID: inviteID,
                  data: jsonEncode(_getCustomMap(requestRoomPKCMD)));
            } else {
              mCurPKCallID = inviteID;
              mUserIdPK = inviter;
              mRoomIdPK = customMap['data']['cmdInfo']['roomId'];
              emitEvent(TRTCLiveRoomDelegate.onRequestRoomPK, {
                "userId": inviter,
                "userName": customMap['data']['cmdInfo']['userName'],
                "userAvatar": customMap['data']['cmdInfo']['userAvatar'],
              });
            }
          } else if (customMap.containsKey('data') &&
              customMap['data']['cmd'] == quitRoomPKCMD) {
            isPk = false;
            emitEvent(TRTCLiveRoomDelegate.onQuitRoomPK, {
              "userId": inviter,
            });
          }
        } catch (e) {
          print(logTag + " signalingListener error log.");
        }
      },
    );
  }

  @override
  Future<ActionCallback> requestJoinAnchor() async {
    V2TimValueCallback res = await timManager.getSignalingManager().invite(
        invitee: mOwnerUserId,
        data: jsonEncode(_getCustomMap(requestAnchorCMD)),
        timeout: timeOutCount,
        onlineUserOnly: false);
    mCurCallID = res.data;
    return ActionCallback(code: res.code, desc: res.desc);
  }

  _getCustomMap(cmd) {
    Map<String, dynamic> customMap = new Map<String, dynamic>();
    customMap['version'] = 1;
    customMap['businessID'] = "Live";
    customMap['platform'] = "flutter";
    customMap['extInfo'] = "";
    customMap['data'] = {
      "roomId": mRoomId,
      "cmd": cmd,
      "cmdInfo": {
        "userId": mUserId,
        "userName": mSelfUserName,
        "userAvatar": mSelfAvatar,
        "roomId": mRoomId
      },
      "message": ""
    };
    return customMap;
  }

  @override
  Future<ActionCallback> requestRoomPK(int roomId, String userId) async {
    if (mAnchorList.length >= 2) {
      return ActionCallback(
          code: codeErr,
          desc:
              'There are two anchors in the room. Cross room calls are not allowed');
    }
    mRoomIdPK = roomId.toString();
    mUserIdPK = userId;
    V2TimValueCallback res = await timManager.getSignalingManager().invite(
        invitee: userId,
        data: jsonEncode(_getCustomMap(requestRoomPKCMD)),
        timeout: timeOutCount,
        onlineUserOnly: false);
    mCurPKCallID = res.data;
    return ActionCallback(code: res.code, desc: res.desc);
  }

  @override
  Future<ActionCallback> responseJoinAnchor(String userId, bool agree) async {
    V2TimCallback res;
    if (agree) {
      res = await timManager.getSignalingManager().accept(
          inviteID: mCurCallID,
          data: jsonEncode(_getCustomMap(requestAnchorCMD)));
    } else {
      res = await timManager.getSignalingManager().reject(
          inviteID: mCurCallID,
          data: jsonEncode(_getCustomMap(requestAnchorCMD)));
    }

    return ActionCallback(code: res.code, desc: res.desc);
  }

  @override
  Future<ActionCallback> responseRoomPK(String userId, bool agree) async {
    V2TimCallback res;
    if (agree) {
      res = await timManager.getSignalingManager().accept(
          inviteID: mCurPKCallID,
          data: jsonEncode(_getCustomMap(requestRoomPKCMD)));
      if (res.code == 0 && mRoomIdPK != null) {
        isPk = true;
        mTRTCCloud.connectOtherRoom(
            jsonEncode({"roomId": int.parse(mRoomIdPK!), "userId": userId}));
      }
    } else {
      res = await timManager.getSignalingManager().reject(
          inviteID: mCurPKCallID,
          data: jsonEncode(_getCustomMap(requestRoomPKCMD)));
    }

    return ActionCallback(code: res.code, desc: res.desc);
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
  Future<ActionCallback> sendRoomCustomMsg(String cmd, String message) async {
    V2TimValueCallback<V2TimMessage> res =
        await timManager.sendGroupCustomMessage(
            customData: jsonEncode({
              "command": cmd,
              "message": message,
              "version": "1.0.0",
              "action": liveCustomCmd
            }),
            groupID: mRoomId.toString(),
            priority: MessagePriority.V2TIM_PRIORITY_LOW);
    if (res.code == 0) {
      return ActionCallback(code: 0, desc: "send group message success.");
    } else {
      return ActionCallback(
          code: res.code,
          desc: "send room custom msg fail, not enter room yet.");
    }
  }

  @override
  Future<void> setMirror(bool isMirror) {
    if (isMirror) {
      return mTRTCCloud.setLocalRenderParams(TRTCRenderParams(
          mirrorType: TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE));
    } else {
      return mTRTCCloud.setLocalRenderParams(TRTCRenderParams(
          mirrorType: TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_DISABLE));
    }
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
      return ActionCallback(code: 0, desc: "set profile success.");
    } else {
      return ActionCallback(code: res.code, desc: "set profile fail.");
    }
  }

  @override
  Future<void> startCameraPreview(bool isFrontCamera, int viewId) {
    return mTRTCCloud.startLocalPreview(isFrontCamera, viewId);
  }

  @override
  Future<void> updateLocalView(int viewId) {
    return mTRTCCloud.updateLocalView(viewId);
  }

  @override
  Future<void> startPlay(String userId, int viewId) {
    return mTRTCCloud.startRemoteView(
        userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, viewId);
  }

  @override
  Future<void> updateRemoteView(String userId, int viewId) {
    return mTRTCCloud.updateRemoteView(
        viewId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, userId);
  }

  @override
  Future<ActionCallback> startPublish(String? streamId) async {
    if (!mIsEnterRoom) {
      return ActionCallback(code: codeErr, desc: "not enter room yet.");
    }
    // 如果是观众，那么则切换到主播
    if (mOriginRole == TRTCCloudDef.TRTCRoleAudience) {
      mTRTCCloud.switchRole(TRTCCloudDef.TRTCRoleAnchor);
      // 观众切换到主播是小主播，小主播设置一下分辨率
      TRTCVideoEncParam param = new TRTCVideoEncParam();
      param.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_480_270;
      param.videoBitrate = 400;
      param.videoFps = 15;
      param.videoResolutionMode =
          TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT;
      mTRTCCloud.setVideoEncoderParam(param);
    } else if (mOriginRole == TRTCCloudDef.TRTCRoleAnchor) {
      // 大主播的时候切换分辨率
      TRTCVideoEncParam param = new TRTCVideoEncParam();
      param.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720;
      param.videoBitrate = 1800;
      param.videoFps = 15;
      param.enableAdjustRes = true;
      param.videoResolutionMode =
          TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT;
      mTRTCCloud.setVideoEncoderParam(param);
    }
    if (!_isEmpty(streamId)) {
      mStreamId = streamId;
      mTRTCCloud.startPublishing(
          streamId!, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
    }
    mTRTCCloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);

    return ActionCallback(code: 0, desc: "startPublish success");
  }

  _isEmpty(String? data) {
    return data == null || data == "";
  }

  @override
  Future<void> stopCameraPreview() {
    return mTRTCCloud.stopLocalPreview();
  }

  @override
  Future<void> stopPlay(String userId) {
    return mTRTCCloud.stopRemoteView(
        userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
  }

  @override
  Future<void> stopPublish() async {
    print("==stopPublish1=");
    mTRTCCloud.stopLocalAudio();
    if (mOriginRole == TRTCCloudDef.TRTCRoleAudience) {
      mTRTCCloud.switchRole(TRTCCloudDef.TRTCRoleAudience);
    } else if (mOriginRole == TRTCCloudDef.TRTCRoleAnchor) {
      mTRTCCloud.exitRoom();
    }

    if (!_isEmpty(mStreamId)) {
      mTRTCCloud.stopPublishing();
    }
  }

  @override
  Future<void> switchCamera(bool isFrontCamera) {
    return txDeviceManager.switchCamera(isFrontCamera);
  }
}

/// @nodoc
typedef VoiceListenerFunc<P> = void Function(
    TRTCLiveRoomDelegate type, P params);
