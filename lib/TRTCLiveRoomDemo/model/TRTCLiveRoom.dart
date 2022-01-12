import 'impl/TRTCLiveRoomImpl.dart';
import './TRTCLiveRoomDef.dart';

// 视频互动直播组件
abstract class TRTCLiveRoom {
  /*
  * 获取 TRTCLiveRoom 单例对象
  *
  * @return TRTCLiveRoom 实例
  * @note 可以调用 {@link TRTCLiveRoom.destroySharedInstance()} 销毁单例对象
  */
  static Future<TRTCLiveRoom> sharedInstance() async {
    return TRTCLiveRoomImpl.sharedInstance();
  }

  /*
  * 销毁 TRTCLiveRoom 单例对象
  *
  * @note 销毁实例后，外部缓存的 TRTCLiveRoom 实例不能再使用，需要重新调用 {@link TRTCLiveRoom.sharedInstance()} 获取新实例
  */
  static void destroySharedInstance() async {
    TRTCLiveRoomImpl.destroySharedInstance();
  }

  //////////////////////////////////////////////////////////
  //
  //                 基础接口
  //
  //////////////////////////////////////////////////////////
  /*
  * 设置组件事件监听接口
  *
  * 您可以通过 registerListener 获得 TRTCCalling 的各种状态通知
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
  Future<ActionCallback> login(
      int sdkAppId, String userId, String userSig, TRTCLiveRoomConfig config);

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
  Future<RoomInfoCallback> getRoomInfos(List<String> roomIdList);

  // 获取房间内所有的主播列表，enterRoom() 成功后调用才有效。
  Future<UserListCallback> getAnchorList();

  // 获取群成员列表。
  Future<UserListCallback> getRoomMemberList(int nextSeq);

  // 开启本地视频的预览画面。
  Future<void> startCameraPreview(bool isFrontCamera, int viewId);

  //更新本地视频预览画面的窗口,仅仅ios有效
  Future<void> updateLocalView(int viewId);

  // 停止本地视频采集及预览。
  Future<void> stopCameraPreview();

  // 开始直播（推流），适用于以下场景：
  // 主播开播的时候调用
  // 观众开始连麦时调用
  Future<void> startPublish(String? streamId);

  // 停止直播（推流）。
  Future<void> stopPublish();

  // 播放远端视频画面，可以在普通观看和连麦场景中调用。
  Future<void> startPlay(String userId, int viewId);

  //更新远端视频画面的窗口,仅仅ios有效
  Future<void> updateRemoteView(String userId, int viewId);

  // 停止渲染远端视频画面。
  Future<void> stopPlay(String userId);

  // 观众请求连麦。
  Future<ActionCallback> requestJoinAnchor();

  // 主播处理连麦请求。
  Future<ActionCallback> responseJoinAnchor(
      String userId, bool agreee, String callId);

  // 主播踢除连麦观众。
  Future<ActionCallback> kickoutJoinAnchor(String userId);

  // 主播请求跨房 PK。
  Future<ActionCallback> requestRoomPK(int roomId, String userId);

  // 主播响应跨房 PK 请求。
  Future<ActionCallback> responseRoomPK(String userId, bool agree);

  // 退出跨房 PK。
  Future<ActionCallback> quitRoomPK();

  /*
  * 切换前后摄像头。
  *
  * @param isFrontCamera true:切换前置摄像头 false:切换后置摄像头
  */
  Future<void> switchCamera(bool isFrontCamera);

  // 设置是否镜像展示。
  Future<void> setMirror(bool isMirror);

  /*
  * 开启本地静音。
  * @param mute 是否静音
  */
  Future<void> muteLocalAudio(bool mute);

  /*
  * 静音远端音频。
  * @param userId 远端用户id
  * @param mute 是否静音
  */
  Future<void> muteRemoteAudio(String userId, bool mute);

  /*
  * 静音所有远端音频。
  * @param mute 是否静音
  */
  Future<void> muteAllRemoteAudio(bool mute);

  // 获取背景音乐音效管理对象 TXAudioEffectManager。
  getAudioEffectManager();

  // 获取美颜管理对象 TXBeautyManager。
  getBeautyManager();

  /*
  * 在房间中广播文本消息，一般用于弹幕聊天
  * @param message 文本消息
  */
  Future<ActionCallback> sendRoomTextMsg(String message);

  /*
  * 发送自定义文本消息。
  * @param cmd 命令字，由开发者自定义，主要用于区分不同消息类型。
  * @param message 文本消息
  */
  Future<ActionCallback> sendRoomCustomMsg(String cmd, String message);
}
