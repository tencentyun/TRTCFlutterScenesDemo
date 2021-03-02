import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/tx_audio_effect_manager.dart';
import './impl/TRTCVoiceRoomImpl.dart';
import 'TRTCVoiceRoomDef.dart';
import 'TRTCVoiceRoomListener.dart';

abstract class TRTCVoiceRoom {
  /*
  * 获取 TRTCVoiceRoom 单例对象
  *
  * @param context Android 上下文，内部会转为 ApplicationContext 用于系统 API 调用
  * @return TRTCVoiceRoom 实例
  * @note 可以调用 {@link TRTCVoiceRoom#destroySharedInstance()} 销毁单例对象
  */
  static Future<TRTCVoiceRoom> sharedInstance() async {
    // if (_trtcVoiceRoom == null) {
    //   _trtcVoiceRoom = new TRTCVoiceRoom();
    //   await TRTCCloud.sharedInstance();
    // }
    // return _trtcVoiceRoom;
    return TRTCVoiceRoomImpl.sharedInstance();
  }

  /*
  * 销毁 TRTCVoiceRoom 单例对象
  *
  * @note 销毁实例后，外部缓存的 TRTCVoiceRoom 实例不能再使用，需要重新调用 {@link TRTCVoiceRoom#sharedInstance(Context)} 获取新实例
  */
  static void destroySharedInstance() async {
    await TRTCCloud.destroySharedInstance();
  }

  //////////////////////////////////////////////////////////
  //
  //                 基础接口
  //
  //////////////////////////////////////////////////////////
  /*
  * 设置组件回调接口
  * <p>
  * 您可以通过 TRTCVoiceRoomDelegate 获得 TRTCVoiceRoom 的各种状态通知
  *
  * @param delegate 回调接口
  * @note TRTCVoiceRoom 中的事件，默认是在 Main Thread 中回调给您；如果您需要指定事件回调所在的线程，可使用 {@link TRTCVoiceRoom#setDelegateHandler(Handler)}
  */
  void registerListener(VoiceListenerFunc func);

  void unRegisterListener(VoiceListenerFunc func);

  /*
  * 登录
  *
  * @param sdkAppId 您可以在s实时音视频控制台 >【[应用管理](https://console.cloud.tencent.com/trtc/app)】> 应用信息中查看 SDKAppID
  * @param userId 当前用户的 ID，字符串类型，只允许包含英文字母（a-z 和 A-Z）、数字（0-9）、连词符（-）和下划线（\_）
  * @param userSig 腾讯云设计的一种安全保护签名，获取方式请参考 [如何计算 UserSig](https://cloud.tencent.com/document/product/647/17275)。
  * @param 返回值：成功时 code 为0
  */
  Future<ActionCallback> login(int sdkAppId, String userId, String userSig);

  /*
  * 退出登录
  */
  Future<ActionCallback> logout();

  /*
  * 设置用户信息，您设置的用户信息会被存储于腾讯云 IM 云服务中。
  *
  * @param userName 用户昵称
  * @param avatarURL 用户头像
  * @param callback 是否设置成功的结果回调
  */
  Future<ActionCallback> setSelfProfile(String userName, String avatarURL);

  //////////////////////////////////////////////////////////
  //
  //                 房间管理接口
  //
  //////////////////////////////////////////////////////////

  /*
  * 创建房间（主播调用）
  *
  * 主播正常的调用流程是：
  * 1. 主播调用`createRoom`创建新的语音聊天室，此时传入房间 ID、上麦是否需要房主确认、麦位数等房间属性信息。
  * 2. 主播创建房间成功后，调用`enterSeat`进入座位。
  * 3. 主播收到组件的`onSeatListChange`麦位表变化事件通知，此时可以将麦位表变化刷新到 UI 界面上。
  * 4. 主播还会收到麦位表有成员进入的`onAnchorEnterSeat`的事件通知，此时会自动打开麦克风采集。
  *
  * @param roomId 房间标识，需要由您分配并进行统一管理。
  * @param roomParam 房间信息，用于房间描述的信息，例如房间名称，封面信息等。如果房间列表和房间信息都由您的服务器自行管理，可忽略该参数。
  * @param callback 创建房间的结果回调，成功时 code 为0.
  */
  Future<ActionCallback> createRoom(int roomId, RoomParam roomParam);

  /*
  * 销毁房间（主播调用）
  *
  * 主播在创建房间后，可以调用这个函数来销毁房间。
  */
  Future<ActionCallback> destroyRoom();

  /*
  * 进入房间（观众调用）
  *
  * 观众进房收听的正常调用流程如下：
  * 1.【观众】向您的服务端获取最新的语音聊天室列表，可能包含多个直播间的 roomId 和房间信息。
  * 2. 观众选择一个语音聊天室，调用`enterRoom`并传入房间号即可进入该房间。
  * 3. 进房后会收到组件的`onRoomInfoChange`房间属性变化事件通知，此时可以记录房间属性并做相应改变，例如 UI 展示房间名、记录上麦是否需要请求主播同意等。
  * 4. 进房后会收到组件的`onSeatListChange`麦位表变化事件通知，此时可以将麦位表变化刷新到 UI 界面上。
  * 5. 进房后还会收到麦位表有主播进入的`onAnchorEnterSeat`的事件通知。
  *
  * @param roomId 房间标识
  * @param callback 进入房间是否成功的结果回调
  */
  Future<ActionCallback> enterRoom(int roomId);

  /*
  * 退出房间
  *
  * @param callback 退出房间是否成功的结果回调
  */
  Future<ActionCallback> exitRoom();

  /*
  * 获取房间列表的详细信息
  *
  * 其中的信息是主播在创建 createRoom() 时通过 roomInfo 设置进来的，如果房间列表和房间信息都由您的服务器自行管理，此函数您可以不用关心。
  *
  * @param roomIdList 房间号列表
  * @param callback 房间详细信息回调
  */
  Future<RoomInfoCallback> getRoomInfoList(List<String> roomIdList);

  /*
  * 获取指定userId的用户信息，如果为null，则获取房间内所有人的信息
  * @param userIdList 用户id列表
  * 
  */
  Future<UserListCallback> getUserInfoList(List<String> userIdList);

  // 获取房间内主播列表
  Future<UserListCallback> getArchorInfoList();

  /*
  * 拉取房间内所有成员列表
  * @param nextSeq	分页拉取标志，第一次拉取填0，回调成功如果 nextSeq 不为零，需要分页，传入再次拉取，直至为0。
  * 
  */
  Future<MemberListCallback> getRoomMemberList(double nextSeq);

  //////////////////////////////////////////////////////////
  //
  //                 麦位管理接口
  //
  //////////////////////////////////////////////////////////

  /*
  * 观众申请上麦
  *
  * 上麦成功后，房间内所有成员会收到`onSeatListChange`和`onAnchorEnterSeat`的事件通知。
  *
  * @param seatIndex 需要上麦的麦位序号
  * @param callback 操作回调
  */
  void raiseHand();

  /// 管理员同意上麦
  Future<ActionCallback> agreeToSpeak(String userId);

  /// 管理员拒绝上麦
  Future<ActionCallback> refuseToSpeak(String userId);

  /*
  * 主动下麦
  *
  * 下麦成功后，房间内所有成员会收到`onSeatListChange`和`onAnchorLeaveSeat`的事件通知。
  *
  * @param callback 操作回调
  */
  void leaveMic();

  /*
  * 踢人下麦(主播调用)
  *
  * 主播踢人下麦，房间内所有成员会收到`onSeatListChange`和`onAnchorLeaveSeat`的事件通知。
  *
  * @param seatIndex 需要踢下麦的麦位序号
  * @param callback 操作回调
  */
  Future<ActionCallback> kickMic(String userId);

  //////////////////////////////////////////////////////////
  //
  //                 本地音频操作接口
  //
  //////////////////////////////////////////////////////////
  /*
  * 开启麦克风采集
  */
  void startMicrophone(int quality);

  /*
  * 停止麦克风采集
  */
  void stopMicrophone();

  /*
  * 开启本地静音
  * @param mute 是否静音
  */
  void muteLocalAudio(bool mute);

  /*
  * 设置开启扬声器
  * @param useSpeaker true:扬声器 false:听筒
  */
  void setSpeaker(bool useSpeaker);

  /*
  * 设置麦克风采集音量
  * @param volume 采集音量 0-100
  */
  void setAudioCaptureVolume(int volume);

  /*
  * 设置播放音量
  * @param volume 播放音量 0-100
  */
  void setAudioPlayoutVolume(int volume);

  //////////////////////////////////////////////////////////
  //
  //                 远端用户接口
  //
  //////////////////////////////////////////////////////////
  /*
  * 静音某一个用户的声音
  *
  * @param userId 用户id
  * @param mute true:静音 false：解除静音
  */
  void muteRemoteAudio(String userId, bool mute);

  /*
  * 静音所有用户的声音
  *
  * @param mute true:静音 false：解除静音
  */
  void muteAllRemoteAudio(bool mute);

  /*
  * 音效控制相关
  */
  TXAudioEffectManager getAudioEffectManager();

  //////////////////////////////////////////////////////////
  //
  //                 消息发送接口
  //
  //////////////////////////////////////////////////////////

  /*
  * 在房间中广播文本消息，一般用于弹幕聊天
  * @param message 文本消息
  * @param callback 发送结果回调
  */
  Future<ActionCallback> sendRoomTextMsg(String message);

  /*
  * 在房间中广播自定义（信令）消息，一般用于广播点赞和礼物消息
  *
  * @param cmd 命令字，由开发者自定义，主要用于区分不同消息类型
  * @param message 文本消息
  * @param callback 发送结果回调
  */
  Future<ActionCallback> sendRoomCustomMsg(String customData);
}

/// @nodoc
// typedef ListenerValue<P> = void Function(TRTCVoiceRoomListener type, P params);
