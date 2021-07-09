/// TRTCMeetingDelegate回调事件
enum TRTCMeetingDelegate {
  /// 错误回调，表示 SDK 不可恢复的错误，一定要监听，并分情况给用户适当的界面提示
  ///
  /// 参数param：
  ///
  /// errCode：错误码
  ///
  /// errMsg：错误信息
  ///
  /// extraInfo：扩展信息字段，个别错误码可能会带额外的信息帮助定位问题
  onError,

  /// 警告回调，用于告知您一些非严重性问题，例如出现卡顿或者可恢复的解码失败
  ///
  /// 参数param：
  ///
  /// warningCode：错误码
  ///
  /// warningMsg：警告信息
  ///
  /// extraInfo：扩展信息字段，个别警告码可能会带额外的信息帮助定位问题
  onWarning,

  /// 其他用户登录了同一账号，被踢下线
  onKickedOffline,

  /// 会议房间被销毁的回调。主持人退房时，房间内的所有用户都会收到此通知
  ///
  /// 参数param：
  ///
  /// roomId：会议房间ID
  onRoomDestroy,

  /// 网络状态回调
  ///
  /// 参数param：
  ///
  /// localQuality：上行网络质量
  ///
  /// remoteQuality：下行网络质量
  onNetworkQuality,

  /// 用户通话音量回调
  ///
  /// 参数param：
  ///
  /// userVolumes：所有正在说话的房间成员的音量，取值范围0 - 100
  ///
  /// totalVolume：所有远端成员的总音量, 取值范围0 - 100
  onUserVolumeUpdate,

  /// 本地进会回调
  ///
  /// 调用 TRTCCloud 中的 enterRoom() 接口执行进房操作后，会收到来自 SDK 的 onEnterRoom(result) 回调
  ///
  /// 如果加入成功，result 会是一个正数（result > 0），代表加入会议的时间消耗，单位是毫秒（ms）
  ///
  /// 如果加入失败，result 会是一个负数（result < 0），代表进会失败的错误码
  ///
  /// 参数param：
  ///
  /// result：大于0时为进会耗时（ms），小于0时为进会错误码
  onEnterRoom,

  /// 本地退会回调
  ///
  /// 调用 TRTCCloud 中的 exitRoom() 接口会执行退出房间的相关逻辑，例如释放音视频设备资源和编解码器资源等。 待资源释放完毕，SDK 会通过 onExitRoom() 回调通知到您
  ///
  /// 如果您要再次调用 enterRoom() 或者切换到其他的音视频 SDK，请等待 onExitRoom() 回调到来之后再执行相关操作。 否则可能会遇到音频设备被占用等各种异常问题
  ///
  /// 参数param：
  ///
  /// reason：离开会议原因，0：主动调用 leaveMeeting 退会；1：被服务器踢出当前会议；2：当前会议整个被解散
  onLeaveRoom,

  /// 新成员进会回调
  ///
  /// 参数param：
  ///
  /// userId：新进会成员的用户ID
  onUserEnterRoom,

  /// 成员退会回调
  ///
  /// 参数param：
  ///
  /// userId：退会成员的用户ID
  onUserLeaveRoom,

  /// 成员开启/关闭麦克风的回调
  ///
  /// 参数param：
  ///
  /// userId：用户ID
  ///
  /// available：true：用户打开麦克风；false：用户关闭麦克风
  onUserAudioAvailable,

  /// 成员开启/关闭摄像头的回调
  ///
  /// 参数param：
  ///
  /// userId：用户ID
  ///
  /// available：true：用户打开摄像头；false：用户关闭摄像头
  onUserVideoAvailable,

  /// 成员开启/关闭辅路画面（一般用于屏幕分享）的回调
  ///
  /// 参数param：
  ///
  /// userId：用户ID
  ///
  /// available：true：用户打开屏幕分享；false：用户关闭屏幕分享
  onUserSubStreamAvailable,

  /// 收到文本消息的回调
  ///
  /// 参数param：
  ///
  /// message：文本消息
  ///
  /// sendId：发送者用户Id
  ///
  /// userAvatar：发送者用户头像
  ///
  /// userName：发送者用户昵称
  onRecvRoomTextMsg,

  /// 收到自定义消息的回调
  ///
  /// 参数param：
  ///
  /// command：命令字，由开发者自定义，主要用于区分不同消息类型
  ///
  /// message：文本消息
  ///
  /// sendId：发送者用户Id
  ///
  /// userAvatar：发送者用户头像
  ///
  /// userName：发送者用户昵称
  onRecvRoomCustomMsg,

  /// 录屏开始回调
  onScreenCaptureStarted,

  /// 录屏暂停回调
  onScreenCapturePaused,

  /// 录屏恢复回调
  onScreenCaptureResumed,

  /// 录屏停止回调
  ///
  /// 参数param：
  ///
  /// reason：停止原因，0：用户主动停止；1：屏幕窗口关闭导致停止
  onScreenCaptureStoped,
}
