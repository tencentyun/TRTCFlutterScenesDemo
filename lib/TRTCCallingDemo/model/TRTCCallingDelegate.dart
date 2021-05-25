/// TRTCCallingDelegate回调事件
enum TRTCCallingDelegate {
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

  /// 有用户加入当前房间。
  ///
  /// 参数param：
  ///
  /// userId	用户标识
  onUserEnter,

  /// 有用户离开当前房间。
  ///
  /// 参数param：
  ///
  /// userId	用户标识
  ///
  /// reason	离开原因，0表示用户主动退出房间，1表示用户超时退出，2表示被踢出房间。
  onUserLeave,

  /*
  * 正在IM群组通话时，如果其他与会者邀请他人，会收到此回调
  * 例如 A-B-C 正在IM群组中，A邀请[D、E]进入通话，B、C会收到[D、E]的回调
  * 如果此时 A 再邀请 F 进入群聊，那么B、C会收到[D、E、F]的回调
  * @param userIdList 邀请群组
  */
  onGroupCallInviteeListUpdate,

  /*
  * 被邀请通话回调
  * @param sponsor 邀请者
  * @param userIdList 同时还被邀请的人
  * @param isFromGroup 是否IM群组邀请
  * @param callType 邀请类型 1-语音通话，2-视频通话
  */
  onInvited,

  /*
   * 1. 在C2C通话中，只有发起方会收到拒绝回调
   * 例如 A 邀请 B、C 进入通话，B拒绝，A可以收到该回调，但C不行
   *
   * 2. 在IM群组通话中，所有被邀请人均能收到该回调
   * 例如 A 邀请 B、C 进入通话，B拒绝，A、C均能收到该回调
   * @param userId 拒绝通话的用户
   */
  onReject,

  /*
    * 1. 在C2C通话中，只有发起方会收到无人应答的回调
    * 例如 A 邀请 B、C 进入通话，B不应答，A可以收到该回调，但C不行
    *
    * 2. 在IM群组通话中，所有被邀请人均能收到该回调
    * 例如 A 邀请 B、C 进入通话，B不应答，A、C均能收到该回调
    * @param userId
    */
  onNoResp,

  /*
   * 邀请方忙线
   * @param userId 忙线用户
   */
  onLineBusy,

  /*
   * 作为被邀请方会收到，收到该回调说明本次通话被取消了
   */
  onCallingCancel,

  /*
  * 作为被邀请方会收到，收到该回调说明本次通话超时未应答
  */
  onCallingTimeout,

  /*
  * 收到该回调说明本次通话结束了
  */
  onCallEnd,

  /// 远端用户是否存在可播放的主路画面（一般用于摄像头）
  ///
  /// 当您收到 onUserVideoAvailable(userId, true) 通知时，表示该路画面已经有可用的视频数据帧到达。 此时，您需要调用 startRemoteView(userid) 接口加载该用户的远程画面。 然后，您会收到名为 onFirstVideoFrame(userid) 的首帧画面渲染回调。
  ///
  /// 当您收到 onUserVideoAvailable(userId, false) 通知时，表示该路远程画面已经被关闭，可能由于该用户调用了 muteLocalVideo() 或 stopLocalPreview()。
  ///
  /// 参数param：
  ///
  /// userId	用户标识
  ///
  /// available	画面是否开启
  onUserVideoAvailable,

  /// 远端用户是否存在可播放的主路画面（一般用于摄像头）
  ///
  /// 当您收到 onUserVideoAvailable(userId, true) 通知时，表示该路画面已经有可用的视频数据帧到达。 此时，您需要调用 startRemoteView(userid) 接口加载该用户的远程画面。 然后，您会收到名为 onFirstVideoFrame(userid) 的首帧画面渲染回调。
  ///
  /// 当您收到 onUserVideoAvailable(userId, false) 通知时，表示该路远程画面已经被关闭，可能由于该用户调用了 muteLocalVideo() 或 stopLocalPreview()。
  ///
  /// 参数param：
  ///
  /// userId	用户标识
  ///
  /// available	画面是否开启
  onUserAudioAvailable,

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
  onUserVoiceVolume,

  //其他用户登录了同一账号，被踢下线
  onKickedOffline
}
