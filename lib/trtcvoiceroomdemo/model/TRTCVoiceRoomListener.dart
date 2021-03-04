import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_event_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_attribute_changed.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_member_enter.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_member_leave.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_recv_group_text_message.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';

enum TRTCVoiceRoomListener {
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
  onAnchorListChange,

  /// 有成员上麦(主动上麦/主播抱人上麦)
  ///
  /// 参数：
  ///
  /// userId  上麦的用户id
  onAnchorEnter,

  /// 有成员下麦(主动下麦/主播踢人下麦)
  ///
  /// 参数：
  /// userId  下麦的用户id
  onAnchorLeave,

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
  /// text：文本消息
  ///
  /// sendId：发送者id
  ///
  /// userAvatar：发送者头像
  ///
  /// userName：发送者用户昵称
  onRecvRoomTextMsg,
}

/// @nodoc
/// 监听器对象
class VoiceRoomListener {
  Map<String, String> mOldAttributeMap = {};
  Set<VoiceListenerFunc> listeners = Set();
  TRTCCloud mTRTCCloud;
  V2TIMManager timManager;

  VoiceRoomListener(TRTCCloud _mTRTCCloud, V2TIMManager _timManager) {
    mTRTCCloud = _mTRTCCloud;
    timManager = _timManager;
  }

  void addListener(VoiceListenerFunc func) {
    listeners.add(func);
    mTRTCCloud.registerListener(rtcListener);
    timManager.addSimpleMsgListener(
      listener: simpleMsgListener,
    );
    print("==setGroupListener1==");
    timManager.setGroupListener(listener: groupListener);
    print("==setGroupListener2==");
  }

  void removeListener(VoiceListenerFunc func, mTRTCCloud, timManager) {
    listeners.remove(func);
    mTRTCCloud.unRegisterListener(rtcListener);
    timManager.removeSimpleMsgListener(simpleMsgListener);
  }

  groupListener(V2TimEventCallback event) {
    print("==groupListener type heh=" + event.type.toString());
    TRTCVoiceRoomListener type;
    if (event.type == 'onGroupAttributeChanged') {
      V2TimGroupAttributeChanged data = event.data;
      Map<String, String> groupAttributeMap = data.groupAttributeMap;
      print("==groupListener type data=" + groupAttributeMap.toString());
      type = TRTCVoiceRoomListener.onAnchorListChange;
      emitEvent(type, data.groupAttributeMap);

      groupAttributeMap.forEach((key, value) {
        if (mOldAttributeMap.containsKey(key) &&
            mOldAttributeMap[key] != value) {
          //有成员改变了麦的状态
          type = TRTCVoiceRoomListener.onMicMute;
          emitEvent(type, {'userId': key, 'mute': value == "1" ? true : false});
        } else if (!mOldAttributeMap.containsKey(key)) {
          //有成员上麦
          type = TRTCVoiceRoomListener.onAnchorEnter;
          emitEvent(type, {'userId': key});
        }
      });

      mOldAttributeMap.forEach((key, value) {
        if (!groupAttributeMap.containsKey(key)) {
          //有成员下麦
          type = TRTCVoiceRoomListener.onAnchorLeave;
          emitEvent(type, {'userId': key});
        }
      });

      mOldAttributeMap = groupAttributeMap;
    } else if (event.type == 'onMemberEnter') {
      type = TRTCVoiceRoomListener.onAudienceEnter;
      V2TimMemberEnter data = event.data;
      List<V2TimGroupMemberInfo> memberList = data.memberList;
      List newList = [];
      for (var i = 0; i < memberList.length; i++) {
        newList.add({
          'userId': memberList[i].userID,
          'userName': memberList[i].nickName,
          'userAvatar': memberList[i].faceUrl
        });
      }
      emitEvent(type, newList);
    } else if (event.type == 'onMemberLeave') {
      type = TRTCVoiceRoomListener.onAudienceExit;
      V2TimMemberLeave data = event.data;
      emitEvent(type, {'userId': data.member.userID});
    } else if (event.type == 'onGroupDismissed') {
      //房间被群主解散
      type = TRTCVoiceRoomListener.onRoomDestroy;
      emitEvent(type, {});
    }
  }

  simpleMsgListener(V2TimEventCallback data) {
    print("==simpleMsgListener type heh=" + data.type.toString());
    print("==simpleMsgListener data=" + data.data.toString());

    TRTCVoiceRoomListener type;
    if (data.type == "onRecvC2CCustomMessage") {
      print("==simpleMsgListener data customData=" +
          data.data.customData.toString());
      if (data.data.customData == "raiseHand") {
        type = TRTCVoiceRoomListener.onRaiseHand;
        emitEvent(type, data.data.sender.userID);
      } else if (data.data.customData == "agreeToSpeak") {
        type = TRTCVoiceRoomListener.onAgreeToSpeak;
        emitEvent(type, data.data.sender.userID);
      } else if (data.data.customData == "refuseToSpeak") {
        type = TRTCVoiceRoomListener.onRefuseToSpeak;
        emitEvent(type, data.data.sender.userID);
      } else if (data.data.customData == "kickMic") {
        type = TRTCVoiceRoomListener.onKickMic;
        emitEvent(type, data.data.sender.userID);
      }
    } else if (data.type == "onRecvGroupTextMessage") {
      V2TimRecvGroupTextMessage message = data.data;
      type = TRTCVoiceRoomListener.onRecvRoomTextMsg;
      emitEvent(type, {
        "text": message.text,
        "sendId": message.sender.userID,
        "userAvatar": message.sender.faceUrl,
        "userName": message.sender.nickName
      });
    }
  }

  rtcListener(rtcType, param) {
    String typeStr = rtcType.toString();
    TRTCVoiceRoomListener type;
    // for (var item in TRTCVoiceRoomListener.values) {
    //   String newItem =
    //       item.toString().replaceFirst("TRTCVoiceRoomListener.", "");
    //   if (newItem == typeStr.replaceFirst("TRTCCloudListener.", "")) {
    //     type = item;
    //     break;
    //   }
    // }
    typeStr = typeStr.replaceFirst("TRTCCloudListener.", "");
    if (typeStr == "onEnterRoom") {
      type = TRTCVoiceRoomListener.onEnterRoom;
      emitEvent(type, param);
    } else if (typeStr == "onExitRoom") {
      type = TRTCVoiceRoomListener.onExitRoom;
      emitEvent(type, param);
    } else if (typeStr == "onError") {
      type = TRTCVoiceRoomListener.onError;
      emitEvent(type, param);
    } else if (typeStr == "onWarning") {
      type = TRTCVoiceRoomListener.onWarning;
      emitEvent(type, param);
    } else if (typeStr == "onUserVoiceVolume") {
      type = TRTCVoiceRoomListener.onUserVolumeUpdate;
      emitEvent(type, param);
    }
  }

  emitEvent(type, param) {
    for (var item in listeners) {
      item(type, param);
    }
  }
}

/// @nodoc
typedef VoiceListenerFunc<P> = void Function(
    TRTCVoiceRoomListener type, P params);
