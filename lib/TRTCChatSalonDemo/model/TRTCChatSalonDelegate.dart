import 'package:tencent_im_sdk_plugin/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';

/// TRTCChatSalonDelegate回调事件
enum TRTCChatSalonDelegate {
  /// 错误回调，表示 SDK 不可恢复的错误，一定要监听并分情况给用户适当的界面提示
  ///
  /// 参数param：
  ///
  /// errCode	错误码
  ///
  /// errMsg	错误信息
  ///
  /// extraInfo	扩展信息字段，个别错误码可能会带额外的信息帮助定位问题
  onError,

  /// 警告回调，用于告知您一些非严重性问题，例如出现卡顿或者可恢复的解码失败。
  ///
  /// 参数param：
  ///
  /// warningCode	错误码
  ///
  /// warningMsg	警告信息
  ///
  /// extraInfo	扩展信息字段，个别警告码可能会带额外的信息帮助定位问题
  onWarning,

  ///本地进房
  ///
  /// 如果加入成功，result 会是一个正数（result > 0），代表加入房间的时间消耗，单位是毫秒（ms）。
  ///
  /// 如果加入失败，result 会是一个负数（result < 0），代表进房失败的错误码。
  ///
  /// 参数param：
  ///
  /// result > 0 时为进房耗时（ms），result < 0 时为进房错误码
  onEnterRoom,

  //离开房间的事件回调
  onExitRoom,

  /// 有观众举手，申请上麦
  ///
  /// 参数param：
  ///
  /// userId 申请举手的用户id
  onRaiseHand,

  /// 观众申请举手后，收到群主同意举手的回调
  onAgreeToSpeak,

  /// 观众申请举手后，群主拒绝举手的回调
  onRefuseToSpeak,

  /// 收到被群主踢下麦的回调
  onKickMic,

  /// 房间被销毁，当主播调用destroyRoom后，成员会收到该回调
  onRoomDestroy,

  /// 主播列表发生变化的通知
  ///
  /// 参数：
  ///
  /// userId：用户id
  ///
  /// mute：静音状态
  onAnchorListChange,

  /// 有成员上麦(主动申请上麦，群主同意)
  ///
  /// 参数：
  ///
  /// userId  上麦的用户id
  ///
  /// userName 用户昵称
  ///
  /// userAvatar 用户头像
  ///
  /// mute 麦位状态
  onAnchorEnterMic,

  /// 有成员下麦(主动下麦/主播踢人下麦)
  ///
  /// 参数：
  /// userId  下麦的用户id
  onAnchorLeaveMic,

  /// 主播是否禁麦
  ///
  /// 参数：
  /// userId  用户id
  /// mute 是否禁麦
  onMicMute,

  /// 观众进入房间
  ///
  /// 参数：
  ///
  /// userId：用户id
  ///
  /// userName：用户昵称
  ///
  /// userAvatar：用户头像地址
  onAudienceEnter,

  /// 观众离开房间
  ///
  /// 参数：
  ///
  /// userId: 用户id
  onAudienceExit,

  /// 用于提示音量大小的回调，包括每个 userId 的音量和远端总音量。
  ///
  /// 您可以通过调用 TRTCCloud 中的 enableAudioVolumeEvaluation 接口来开关这个回调或者设置它的触发间隔。 需要注意的是，调用 enableAudioVolumeEvaluation 开启音量回调后，无论频道内是否有人说话，都会按设置的时间间隔调用这个回调; 如果没有人说话，则 userVolumes 为空，totalVolume 为0。
  ///
  /// 注意：userId 为本地用户 ID 时表示自己的音量，userVolumes 内仅包含正在说话（音量不为0）的用户音量信息。
  ///
  /// 参数param：
  ///
  /// userVolumes	所有正在说话的房间成员的音量，取值范围0 - 100。
  ///
  /// totalVolume	所有远端成员的总音量, 取值范围0 - 100。
  onUserVolumeUpdate,

  /// 收到群文本消息，可以用作文本聊天室
  ///
  /// 参数：
  ///
  /// message：文本消息
  ///
  /// sendId：发送者id
  ///
  /// userAvatar：发送者头像
  ///
  /// userName：发送者用户昵称
  onRecvRoomTextMsg,

  //其他用户登录了同一账号，被踢下线
  onKickedOffline
}

/// @nodoc
/// 监听器对象
class VoiceRoomListener {
  Map<String, String> mOldAttributeMap = {};
  // Set<VoiceListenerFunc> listeners = Set();
  VoiceListenerFunc? listenersSet;
  late TRTCCloud mTRTCCloud;
  late V2TIMManager timManager;
  String? mUserId;

  VoiceRoomListener(TRTCCloud _mTRTCCloud, V2TIMManager _timManager) {
    mTRTCCloud = _mTRTCCloud;
    timManager = _timManager;
  }

  initImLisener() {
    return new V2TimSDKListener(onKickedOffline: () {
      TRTCChatSalonDelegate type = TRTCChatSalonDelegate.onKickedOffline;
      emitEvent(type, {});
    });
  }

  void initData(String userId, attr) {
    mUserId = userId;
    mOldAttributeMap = attr;
  }

  void addListener(VoiceListenerFunc func) {
    // listeners.add(func);
    if (listenersSet == null) {
      listenersSet = func;
      //监听trtc事件
      mTRTCCloud.registerListener(rtcListener);
      //监听im事件
      timManager.addSimpleMsgListener(
        listener: simpleMsgListener(),
      );
      timManager.setGroupListener(listener: groupListener());
    }
  }

  void removeListener(
      VoiceListenerFunc func, TRTCCloud mTRTCCloud, V2TIMManager timManager) {
    // listeners.remove(func);
    listenersSet = null;
    mTRTCCloud.unRegisterListener(rtcListener);
    timManager.removeSimpleMsgListener();
    // timManager.unInitSDK();
  }

  groupAttriChange(Map<String, String> data) {
    Map<String, String> groupAttributeMap = data;
    TRTCChatSalonDelegate type;

    List newGroupList = [];
    groupAttributeMap.forEach((key, value) async {
      newGroupList.add({'userId': key, 'mute': value == "1" ? false : true});
      if (mOldAttributeMap.containsKey(key) && mOldAttributeMap[key] != value) {
        //有成员改变了麦的状态
        type = TRTCChatSalonDelegate.onMicMute;
        emitEvent(type, {'userId': key, 'mute': value == "1" ? false : true});
      } else if (!mOldAttributeMap.containsKey(key)) {
        //有成员上麦
        type = TRTCChatSalonDelegate.onAnchorEnterMic;
        V2TimValueCallback<List<V2TimUserFullInfo>> res =
            await timManager.getUsersInfo(userIDList: [key]);
        if (res.code == 0) {
          List<V2TimUserFullInfo> userInfo = res.data!;
          if (userInfo.length > 0) {
            emitEvent(type, {
              'userId': key,
              'userName': userInfo[0].nickName,
              'userAvatar': userInfo[0].faceUrl,
              'mute': false // 默认开麦
            });
          } else {
            emitEvent(type, {'userId': key});
          }
        } else {
          emitEvent(type, {'userId': key});
        }
      }
    });
    //每次有变化必定触发更新
    emitEvent(TRTCChatSalonDelegate.onAnchorListChange, newGroupList);

    mOldAttributeMap.forEach((key, value) async {
      if (!groupAttributeMap.containsKey(key)) {
        //有成员下麦
        type = TRTCChatSalonDelegate.onAnchorLeaveMic;

        V2TimValueCallback<List<V2TimUserFullInfo>> res =
            await timManager.getUsersInfo(userIDList: [key]);
        if (res.code == 0) {
          List<V2TimUserFullInfo> userInfo = res.data!;
          if (userInfo.length > 0) {
            emitEvent(type, {
              'userId': key,
              'userName': userInfo[0].nickName,
              'userAvatar': userInfo[0].faceUrl,
              'mute': false // 默认开麦
            });
          } else {
            emitEvent(type, {'userId': key});
          }
        } else {
          emitEvent(type, {'userId': key});
        }
      }
    });

    mOldAttributeMap = groupAttributeMap;
  }

  groupListener() {
    TRTCChatSalonDelegate type;
    return new V2TimGroupListener(
      onGroupAttributeChanged:
          (String groupId, Map<String, String> groupAttributeMap) {
        //群属性发生变更
        groupAttriChange(groupAttributeMap);
      },
      onMemberEnter: (String groupId, List<V2TimGroupMemberInfo> list) {
        type = TRTCChatSalonDelegate.onAudienceEnter;
        List<V2TimGroupMemberInfo> memberList = list;
        List newList = [];
        for (var i = 0; i < memberList.length; i++) {
          if (!mOldAttributeMap.containsKey(memberList[i].userID)) {
            newList.add({
              'userId': memberList[i].userID,
              'userName': memberList[i].nickName,
              'userAvatar': memberList[i].faceUrl
            });
          }
        }
        if (newList.length > 0) {
          emitEvent(type, newList);
        }
      },
      onMemberLeave: (String groupId, V2TimGroupMemberInfo member) {
        type = TRTCChatSalonDelegate.onAudienceExit;
        emitEvent(type, {'userId': member.userID});
      },
      onGroupDismissed: (groupID, opUser) {
        //房间被群主解散
        type = TRTCChatSalonDelegate.onRoomDestroy;
        emitEvent(type, {});
      },
    );
  }

  simpleMsgListener() {
    TRTCChatSalonDelegate type;
    return new V2TimSimpleMsgListener(
      onRecvC2CCustomMessage: (msgID, sender, customData) {
        // C2C自定义消息
        if (customData == "raiseHand") {
          type = TRTCChatSalonDelegate.onRaiseHand;
          emitEvent(type, sender.userID);
        } else if (customData == "agreeToSpeak") {
          type = TRTCChatSalonDelegate.onAgreeToSpeak;
          emitEvent(type, sender.userID);
        } else if (customData == "refuseToSpeak") {
          type = TRTCChatSalonDelegate.onRefuseToSpeak;
          emitEvent(type, sender.userID);
        } else if (customData == "kickMic") {
          type = TRTCChatSalonDelegate.onKickMic;
          emitEvent(type, sender.userID);
        }
      },
      onRecvGroupTextMessage: (msgID, groupID, sender, customData) {
        //群文本消息
        type = TRTCChatSalonDelegate.onRecvRoomTextMsg;
        emitEvent(type, {
          "message": customData,
          "sendId": sender.userID,
          "userAvatar": sender.faceUrl,
          "userName": sender.nickName
        });
      },
    );
  }

  rtcListener(rtcType, param) {
    String typeStr = rtcType.toString();
    TRTCChatSalonDelegate type;
    typeStr = typeStr.replaceFirst("TRTCCloudListener.", "");
    if (typeStr == "onEnterRoom") {
      type = TRTCChatSalonDelegate.onEnterRoom;
      emitEvent(type, param);
    } else if (typeStr == "onExitRoom") {
      type = TRTCChatSalonDelegate.onExitRoom;
      emitEvent(type, param);
    } else if (typeStr == "onError") {
      type = TRTCChatSalonDelegate.onError;
      emitEvent(type, param);
    } else if (typeStr == "onWarning") {
      type = TRTCChatSalonDelegate.onWarning;
      emitEvent(type, param);
    } else if (typeStr == "onUserVoiceVolume") {
      type = TRTCChatSalonDelegate.onUserVolumeUpdate;
      emitEvent(type, param);
    }
  }

  emitEvent(type, param) {
    listenersSet!(type, param);
    // for (var item in listeners) {
    //   item(type, param);
    // }
  }
}

/// @nodoc
typedef VoiceListenerFunc<P> = void Function(
    TRTCChatSalonDelegate type, P params);
