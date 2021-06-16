/// TRTCLiveRoomDelegate回调事件
enum TRTCLiveRoomDelegate {
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

  /// 远端用户是否存在可播放的主路画面（一般用于摄像头）
  ///
  /// 参数param：
  ///
  /// userId：用户标识
  ///
  /// available：画面是否开启
  onUserVideoAvailable,

  /// 收到新主播进房通知。连麦观众和跨房 PK 主播进房后观众会收到新主播的进房事件，您可以调用 TRTCLiveRoom 的 startPlay() 显示该主播的视频画面。
  ///
  /// 参数param：
  ///
  /// userId 进房用户ID
  onAnchorEnter,

  /// 收到主播退房通知。房间内的主播（和连麦中的观众）会收到新主播的退房事件，您可以调用 TRTCLiveRoom 的 stopPlay() 关闭该主播的视频画面。
  /// 参数param：
  /// userId 退房用户ID
  onAnchorExit,

  /// 主播收到观众连麦请求时的回调。
  ///
  /// 参数param：
  ///
  /// userId：请求连麦的观众用户id
  /// userName：用户昵称
  /// userAvatar：用户头像
  onRequestJoinAnchor,

  /// 连麦观众收到被踢出连麦的通知。连麦观众收到被主播踢除连麦的消息，您需要调用 TRTCLiveRoom 的 stopPublish() 退出连麦。
  ///
  /// 参数param：
  ///
  /// userId：主播的用户id
  /// userName：用户昵称
  /// userAvatar：用户头像
  onKickoutJoinAnchor,

  /// 主播同意观众的连麦请求
  ///
  /// 参数param：
  ///
  /// userId：主播的用户id
  onAnchorAccepted,

  // 主播拒绝观众的连麦请求
  ///
  /// 参数param：
  ///
  /// userId：主播的用户id
  onAnchorRejected,

  // 邀请超时，未响应
  onInvitationTimeout,

  ///收到请求跨房 PK 通知
  ///
  /// 参数param：
  ///
  /// userId：请求跨房PK主播的用户id
  /// userName：用户昵称
  /// userAvatar：用户头像
  onRequestRoomPK,

  ///主播接受跨房Pk请求
  ///
  /// 参数param：
  ///
  /// userId：接收跨房PK的用户id
  onRoomPKAccepted,

  ///主播拒绝跨房Pk请求
  ///
  /// 参数param：
  ///
  /// userId：拒绝跨房PK的用户id
  onRoomPKRejected,

  ///收到断开跨房 PK 通知
  ///
  /// 参数param：
  ///
  /// userId：接收跨房PK的用户id
  onQuitRoomPK,

  /// 房间被销毁，当主播调用destroyRoom后，成员会收到该回调
  onRoomDestroy,

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

  /// 收到自定义消息。
  ///
  /// 参数：
  ///
  /// cmd：
  ///
  /// sendId：发送者id
  ///
  /// userAvatar：发送者头像
  ///
  /// userName：发送者用户昵称
  onRecvRoomCustomMsg,

  //其他用户登录了同一账号，被踢下线
  onKickedOffline
}
