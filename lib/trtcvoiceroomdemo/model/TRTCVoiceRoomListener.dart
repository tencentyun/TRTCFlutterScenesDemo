import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_event_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_attribute_changed.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_member_enter.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_member_leave.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';

enum TRTCVoiceRoomListener {
  //本地进房
  onEnterRoom,
  //本地退房
  onExitRoom,
  //组件出错信息，请务必监听并处理
  onError,

  //组件告警信息
  onWarning,

  //有观众举手，申请上麦
  onRaiseHand,

  //群主同意举手
  onAgreeToSpeak,

  //群主拒绝举手
  onRefuseToSpeak,

  //房间被销毁，当主播调用destroyRoom后，观众会收到该回调
  onRoomDestroy,

  //主播列表发生变化的通知
  onAnchorListChange,

  /*
  * 有成员上麦(主动上麦/主播抱人上麦)
  * 
  * @param user  用户详细信息
  */
  onAnchorEnter,

  /*
  * 有成员下麦(主动下麦/主播踢人下麦)
  * @param index 下麦的麦位
  * @param user  用户详细信息
  */
  onAnchorLeave,

  // 主播是否禁麦
  onMicMute,

  /*
  * 观众进入房间
  *
  * @param userInfo 观众的详细信息
  */
  onAudienceEnter,

  /*
  * 观众离开房间
  *
  * @param userInfo 观众的详细信息
  */
  onAudienceExit,

  /*
  * 上麦成员的音量变化
  *
  * @param userId 用户 ID
  * @param volume 音量大小 0-100
  */
  onUserVolumeUpdate,

  /*
  * 收到文本消息。
  *
  * @param message 文本消息。
  * @param userInfo 发送者用户信息。
  */
  onRecvRoomTextMsg,

  /*
  * 收到自定义消息。
  *
  * @param cmd 命令字，由开发者自定义，主要用于区分不同消息类型。
  * @param message 文本消息。
  * @param userInfo 发送者用户信息。
  */
  onRecvRoomCustomMsg,
}

/// @nodoc
/// 监听器对象
class VoiceRoomListener {
  Map<String, String> mOldAttributeMap = {};
  Set<VoiceListenerFunc> listeners = Set();

  VoiceRoomListener(TRTCCloud mTRTCCloud, V2TIMManager timManager) {
    mTRTCCloud.registerListener(rtcListener);
    timManager.addSimpleMsgListener(
      listener: simpleMsgListener,
    );
    print("==setGroupListener1==");
    timManager.setGroupListener(listener: groupListener);
    print("==setGroupListener2==");
  }

  void addListener(VoiceListenerFunc func) {
    listeners.add(func);
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
          emitEvent(type, {'userId': key, 'mute': true});
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
      emitEvent(type, data.memberList);
    } else if (event.type == 'onMemberLeave') {
      type = TRTCVoiceRoomListener.onAudienceExit;
      V2TimMemberLeave data = event.data;
      emitEvent(type, data.member);
    } else if (event.type == 'onGroupDismissed') {
      //房间被群主解散
      type = TRTCVoiceRoomListener.onRoomDestroy;
      emitEvent(type, {});
    }
  }

  simpleMsgListener(V2TimEventCallback data) {
    print("==simpleMsgListener type heh=" + data.type.toString());

    TRTCVoiceRoomListener type;
    if (data.type == "onRecvC2CCustomMessage") {
      if (data.data.customData == "raiseHand") {
        type = TRTCVoiceRoomListener.onRaiseHand;
        emitEvent(type, data.data.sender.userID);
      } else if (data.data.customData == "agreeToSpeak") {
        type = TRTCVoiceRoomListener.onAgreeToSpeak;
        emitEvent(type, data.data.sender.userID);
      }
    } else if (data.data.customData == "refuseToSpeak") {
      type = TRTCVoiceRoomListener.onRefuseToSpeak;
      emitEvent(type, data.data.sender.userID);
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
    // print("==typeStr=" + typeStr);
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
    } else if (typeStr == "onUserVolumeUpdate") {
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
