import 'package:tencent_im_sdk_plugin/models/v2_tim_event_callback.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';

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

  /*
     * 房间信息改变的通知
     */
  onRoomInfoChange,

  /*
     * 有成员上麦(主动上麦/主播抱人上麦)
     * @param index 上麦的麦位
     * @param user  用户详细信息
     */
  onAnchorEnterSeat,

  /*
     * 有成员下麦(主动下麦/主播踢人下麦)
     * @param index 下麦的麦位
     * @param user  用户详细信息
     */
  onAnchorLeaveSeat,

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
  Set<VoiceListenerFunc> listeners = Set();

  VoiceRoomListener(mTRTCCloud, timManager) {
    mTRTCCloud.registerListener(rtcListener);
    timManager.addSimpleMsgListener(
      listener: simpleMsgListener,
    );
    // timManager.setGroupListener(groupListener);
    print("==addSimpleMsgListener2==2");
  }

  void addListener(VoiceListenerFunc func) {
    listeners.add(func);
  }

  void removeListener(VoiceListenerFunc func, mTRTCCloud, timManager) {
    listeners.remove(func);
    mTRTCCloud.unRegisterListener(rtcListener);
    timManager.removeSimpleMsgListener(simpleMsgListener);
  }

  groupListener(V2TimEventCallback data) {
    print("==groupListener type heh=" + data.type.toString());
  }

  simpleMsgListener(V2TimEventCallback data) {
    print("==simpleMsgListener type heh=" + data.type.toString());
    print("==simpleMsgListener type data=" + data.data.customData.toString());
    print("==simpleMsgListener type sender=" +
        data.data.sender.userID.toString());
    TRTCVoiceRoomListener type;
    if (data.type == "onRecvC2CCustomMessage" &&
        data.data.customData == "raiseHand") {
      type = TRTCVoiceRoomListener.onRaiseHand;
      for (var item in listeners) {
        item(type, data.data.sender.userID);
      }
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
    if (typeStr == "onRemoteUserLeaveRoom") {
      type = TRTCVoiceRoomListener.onRoomDestroy;
      emitEvent(type, param);
    } else if (typeStr == "onEnterRoom") {
      type = TRTCVoiceRoomListener.onEnterRoom;
      emitEvent(type, param);
    } else if (typeStr == "onExitRoom") {
      type = TRTCVoiceRoomListener.onExitRoom;
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
