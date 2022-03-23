import 'package:tencent_trtc_cloud/tx_audio_effect_manager.dart';
import 'impl/TRTCChatSalonImpl.dart';
import 'TRTCChatSalonDef.dart';

abstract class TRTCChatSalon {
  /*
  * 获取 TRTCChatSalon 单例对象
  *
  * @return TRTCChatSalon 实例
  * @note 可以调用 {@link TRTCChatSalon.destroySharedInstance()} 销毁单例对象
  */
  static Future<TRTCChatSalon> sharedInstance() async {
    return TRTCChatSalonImpl.sharedInstance();
  }

  /*
  * 销毁 TRTCChatSalon 单例对象
  *
  * @note 销毁实例后，外部缓存的 TRTCChatSalon 实例不能再使用，需要重新调用 {@link TRTCChatSalon.sharedInstance()} 获取新实例
  */
  static void destroySharedInstance() async {
    TRTCChatSalonImpl.destroySharedInstance();
  }

  //////////////////////////////////////////////////////////
  //
  //                 基础接口
  //
  //////////////////////////////////////////////////////////
  /*
  * 设置组件事件监听接口
  *
  * 您可以通过 registerListener 获得 TRTCChatSalon 的各种状态通知
  *
  * @param VoiceListenerFunc func 回调接口
  */
  void registerListener(VoiceListenerFunc func);

  /*
  * 移除组件事件监听接口
  */
  void unRegisterListener(VoiceListenerFunc func);

  /*
  * 登录
  *
  * @param sdkAppId 您可以在实时音视频控制台 >【[应用管理](https://console.cloud.tencent.com/trtc/app)】> 应用信息中查看 SDKAppID
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
  */
  Future<ActionCallback> setSelfProfile(String userName, String avatarURL);

  //////////////////////////////////////////////////////////
  //
  //                 房间管理接口
  //
  //////////////////////////////////////////////////////////

  /*
  * 创建房间（房间创建者调用）
  *
  * @param roomId 房间标识，需要由您分配并进行统一管理。
  * @param roomParam 房间信息，用于房间描述的信息，例如房间名称，封面信息等。如果房间列表和房间信息都由您的服务器自行管理，可忽略该参数。
  * @param callback 创建房间的结果回调，成功时 code 为0.
  */
  Future<ActionCallback> createRoom(int roomId, RoomParam roomParam);

  /*
  * 销毁房间（房间创建者调用）
  *
  * 主播在创建房间后，可以调用这个函数来销毁房间。
  */
  Future<ActionCallback> destroyRoom();

  /*
  * 进入房间（观众调用）
  *
  * @param roomId 房间标识
  */
  Future<ActionCallback> enterRoom(int roomId);

  /*
  * 退出房间（观众调用）
  *
  */
  Future<ActionCallback> exitRoom();

  /*
  * 获取房间列表的详细信息
  *
  * 其中的信息是主播在创建 createRoom() 时通过 roomInfo 设置进来的，如果房间列表和房间信息都由您的服务器自行管理，此函数您可以不用关心。
  *
  * @param roomIdList 房间id列表
  */
  Future<RoomInfoCallback> getRoomInfoList(List<String> roomIdList);

  /*
  * 获取指定userId的用户信息
  * @param userIdList 用户id列表
  */
  Future<UserListCallback> getUserInfoList(List<String> userIdList);

  // 获取房间内主播列表
  Future<UserListCallback> getArchorInfoList();

  /*
  * 拉取房间内所有成员列表
  * @param nextSeq	分页拉取标志，第一次拉取填0，回调成功如果 nextSeq 不为零，需要分页，传入再次拉取，直至为0。
  */
  Future<MemberListCallback> getRoomMemberList(int nextSeq);

  /*
  * 拉取房间内所有在线成员总数
  */
  Future<int> getRoomOnlineMemberCount();

  //////////////////////////////////////////////////////////
  //
  //                 麦位管理接口
  //
  //////////////////////////////////////////////////////////

  /*
  * 观众申请上麦
  *
  * 上麦成功后，房间内所有成员会收到`onAnchorListChange`和`onAnchorEnterMic`的事件通知。
  */
  void raiseHand();

  /*
  * 群主同意上麦
  *
  * @param userId
  */
  Future<ActionCallback> agreeToSpeak(String userId);

  /*
  * 群主拒绝上麦
  *
  * @param userId
  */
  Future<ActionCallback> refuseToSpeak(String userId);

  /*
  * 上麦
  *
  * 上麦成功后，房间内所有成员会收到`onAnchorListChange`和`onAnchorEnterMic`的事件通知。
  */
  Future<ActionCallback> enterMic();

  /*
  * 主动下麦
  *
  * 下麦成功后，房间内所有成员会收到`onAnchorListChange`和`onAnchorLeaveMic`的事件通知。
  */
  Future<ActionCallback> leaveMic();

  /*
  * 静音/解除静音某个麦位（主播调用）。
  *
  * 改变麦位的状态后，房间内所有成员会收到`onAnchorListChange`和`onMicMute`的事件通知。
  *
  * @param mute: true：静音；false：取消静音
  */
  Future<ActionCallback> muteMic(bool mute);

  /*
  * 踢人下麦(群主调用)
  *
  * 群主踢人下麦，房间内所有成员会收到`onAnchorListChange`和`onAnchorLeaveMic`的事件通知。
  *
  * @param userId 需要踢下麦的用户id
  */
  Future<ActionCallback> kickMic(String userId);

  //////////////////////////////////////////////////////////
  //
  //                 本地音频操作接口
  //
  //////////////////////////////////////////////////////////
  /*
  * 开启麦克风采集
  * 
  * @param quality	声音音质
  *
  * TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH， 流畅：采样率：16k；单声道；音频裸码率：16kbps；适合语音通话为主的场景，比如在线会议，语音通话。
  * TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT，默认：采样率：48k；单声道；音频裸码率：50kbps；SDK 默认的音频质量，如无特殊需求推荐选择之。
  * TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC，高音质：采样率：48k；双声道 + 全频带；音频裸码率：128kbps；适合需要高保真传输音乐的场景，比如K歌、音乐直播等。
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

  //////////////////////////////////////////////////////////
  //
  //                 背景音乐音效相关接口函数
  //
  //////////////////////////////////////////////////////////

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
  */
  Future<ActionCallback> sendRoomTextMsg(String message);
}
