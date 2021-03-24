import 'TRTCCallingDef.dart';
import 'impl/TRTCCallingImpl.dart';
import 'TRTCCallingDelegate.dart';

abstract class TRTCCalling {
  static int TYPE_UNKNOWN = 0;
  static int TYPE_AUDIO_CALL = 1;
  static int TYPE_VIDEO_CALL = 2;

  /*
  * 获取 TRTCChatSalon 单例对象
  *
  * @return TRTCChatSalon 实例
  * @note 可以调用 {@link TRTCChatSalon.destroySharedInstance()} 销毁单例对象
  */
  static Future<TRTCCalling> sharedInstance() async {
    return TRTCCallingImpl.sharedInstance();
  }

  /*
  * 销毁 TRTCChatSalon 单例对象
  *
  * @note 销毁实例后，外部缓存的 TRTCChatSalon 实例不能再使用，需要重新调用 {@link TRTCChatSalon.sharedInstance()} 获取新实例
  */
  static void destroySharedInstance() async {
    TRTCCallingImpl.destroySharedInstance();
  }

  /// 销毁函数，如果不需要再运行该实例，请调用该接口
  void destroy();

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
  * C2C邀请通话，被邀请方会收到 {@link TRTCCallingDelegate#onInvited } 的回调
  * 如果当前处于通话中，可以调用该函数以邀请第三方进入通话
  *
  * @param userId 被邀请方
  * @param type   1-语音通话，2-视频通话
  */
  Future<ActionCallback> call(String userId, int type);

  /*
  * IM群组邀请通话，被邀请方会收到 {@link TRTCCallingDelegate#onInvited } 的回调
  * 如果当前处于通话中，可以继续调用该函数继续邀请他人进入通话，同时正在通话的用户会收到 {@link TRTCCallingDelegate#onGroupCallInviteeListUpdate(List)} 的回调
  *
  * @param userIdList 邀请列表
  * @param type       1-语音通话，2-视频通话
  * @param groupId    IM群组ID
  */
  Future<ActionCallback> groupCall(
      List<String> userIdList, int type, String groupId);

  /*
  * 当您作为被邀请方收到 {@link TRTCCallingDelegate#onInvited } 的回调时，可以调用该函数接听来电
  */
  Future<ActionCallback> accept();

  /*
  * 当您作为被邀请方收到 {@link TRTCCallingDelegate#onInvited } 的回调时，可以调用该函数拒绝来电
  */
  Future<ActionCallback> reject();

  /*
  * 当您处于通话中，可以调用该函数结束通话
  */
  void hangup();

  /*
  * 当您收到 onUserVideoAvailable 回调时，可以调用该函数将远端用户的摄像头数据渲染到指定的TXCloudVideoView中
  *
  * @param userId           远端用户id
  * @param viewId 远端用户数据将渲染到该view中
  */
  void startRemoteView(String userId, int streamType, int viewId);

  /*
  * 当您收到 onUserVideoAvailable 回调为false时，可以停止渲染数据
  *
  * @param userId 远端用户id
  */
  void stopRemoteView(String userId, int streamType);

  /*
  * 您可以调用该函数开启摄像头，并渲染在指定的TXCloudVideoView中
  * 处于通话中的用户会收到 {@link TRTCCallingDelegate#onUserVideoAvailable(java.lang.String, boolean)} 回调
  *
  * @param isFrontCamera    是否开启前置摄像头
  * @param viewId TRTCCloudVideoView生成的viewId
  */
  void openCamera(bool isFrontCamera, int viewId);

  /*
  * 您可以调用该函数关闭摄像头
  * 处于通话中的用户会收到 {@link TRTCCallingDelegate#onUserVideoAvailable(java.lang.String, boolean)} 回调
  */
  void closeCamera();

  /*
  * 您可以调用该函数切换前后摄像头
  *
  * @param isFrontCamera true:切换前置摄像头 false:切换后置摄像头
  */
  void switchCamera(bool isFrontCamera);

  /*
  * 是否静音mic
  *
  * @param isMute true:麦克风关闭 false:麦克风打开
  */
  void setMicMute(bool isMute);

  /*
  * 是否开启免提
  *
  * @param isHandsFree true:开启免提 false:关闭免提
  */
  void setHandsFree(bool isHandsFree);
}
