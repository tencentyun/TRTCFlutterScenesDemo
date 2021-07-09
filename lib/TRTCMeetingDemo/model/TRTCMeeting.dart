import 'impl/TRTCMeetingImpl.dart';
import './TRTCMeetingDef.dart';

// 多人视频会议组件
abstract class TRTCMeeting {
  /// 获取 TRTCMeeting 单例对象
  ///
  /// @return TRTCMeeting 实例
  /// @note 可以调用 {@link TRTCMeeting.destroySharedInstance()} 销毁单例对象
  static Future<TRTCMeeting> sharedInstance() async {
    return TRTCMeetingImpl.sharedInstance();
  }

  /// 销毁 TRTCMeeting 单例对象
  ///
  /// @note 销毁实例后，外部缓存的 TRTCMeeting 实例不能再使用，需要重新调用 {@link TRTCMeeting.sharedInstance()} 获取新实例
  static void destroySharedInstance() async {
    TRTCMeetingImpl.destroySharedInstance();
  }

  //////////////////////////////////////////////////////////
  ///
  ///                 SDK 基础接口
  ///
  //////////////////////////////////////////////////////////

  /// 设置组件事件监听接口
  ///
  /// 您可以通过 registerListener 获得 TRTCMeeting 的各种状态通知
  ///
  /// @param VoiceListenerFunc func 回调接口
  void registerListener(MeetingListenerFunc func);

  /// 销毁组件事件监听接口
  void unRegisterListener(MeetingListenerFunc func);

  /// 登录
  ///
  /// @param sdkAppId 您可以在实时音视频控制台 >【[应用管理](https://console.cloud.tencent.com/trtc/app)】> 应用信息中查看 SDKAppID
  /// @param userId 当前用户的 ID，字符串类型，只允许包含英文字母（a-z 和 A-Z）、数字（0-9）、连词符（-）和下划线（\_）
  /// @param userSig 腾讯云设计的一种安全保护签名，获取方式请参考 [如何计算 UserSig](https://cloud.tencent.com/document/product/647/17275)
  Future<ActionCallback> login(int sdkAppId, String userId, String userSig);

  /// 登出
  Future<ActionCallback> logout();

  /// 修改个人信息
  ///
  /// @param userName 用户昵称
  /// @param avatarURL 用户头像地址
  Future<ActionCallback> setSelfProfile(String userName, String avatarURL);

  //////////////////////////////////////////////////////////
  ///
  ///                 会议房间相关接口
  ///
  //////////////////////////////////////////////////////////

  /// 创建会议（主持人调用）
  ///
  /// @param roomId 会议房间标识
  Future<ActionCallback> createMeeting(int roomId);

  /// 销毁会议房间（主持人调用）
  ///
  /// @param roomId 会议房间标识
  Future<ActionCallback> destroyMeeting(int roomId);

  /// 进入会议房间（参会成员调用）
  ///
  /// @param roomId 会议房间标识
  Future<ActionCallback> enterMeeting(int roomId);

  /// 离开会议房间（参会成员调用）
  Future<ActionCallback> leaveMeeting();

  /// 获取房间内所有的人员列表
  ///
  /// enterMeeting() 成功后调用才有效
  ///
  /// @param userIdList 需要获取的 userId 列表，如果为null，则获取会议内所有人的信息
  Future<UserListCallback> getUserInfoList(List<String> userIdList);

  /// 获取房间内指定人员的详细信息
  ///
  /// enterMeeting() 成功后调用才有效
  ///
  /// @param userId 指定成员的 userId
  Future<UserListCallback> getUserInfo(String userId);

  //////////////////////////////////////////////////////////
  ///
  ///                 远端用户相关接口
  ///
  //////////////////////////////////////////////////////////

  /// 播放指定成员的远端视频画面
  ///
  /// @param userId 指定成员的 userId
  /// @param streamType 指定要观看 userId 的视频流类型：
  /// - 高清大画面：TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG
  /// - 低清大画面：TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL
  /// - 辅流（屏幕分享）：TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB
  /// @param viewId TRTCCloudVideoView生成的 viewId
  Future<void> startRemoteView(String userId, int streamType, int viewId);

  /// 停止播放指定成员的远端视频画面
  ///
  /// @param userId 指定成员的 userId
  /// @param streamType 指定要观看 userId 的视频流类型：
  /// - 高清大画面：TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG
  /// - 低清大画面：TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL
  /// - 辅流（屏幕分享）：TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB
  Future<void> stopRemoteView(String userId, int streamType);

  /// 更新远端视频画面的窗口，仅仅iOS有效
  ///
  /// @param viewId 承载视频画面的控件
  /// @param streamType 指定要观看 userId 的视频流类型
  /// @param userId 指定成员的 userId
  Future<void> updateRemoteView(int viewId, int streamType, String userId);

  /// 设置指定成员的远端图像渲染参数
  ///
  /// @param userId 指定成员的 userId
  /// @param streamType 视频流类型
  /// @param fillMode 图像渲染模式，填充或适应模式
  /// - 填充：TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL（默认值）
  /// - 适应：TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT
  /// @param rotation 图像顺时针旋转角度
  /// - 不旋转：TRTCCloudDef.TRTC_VIDEO_ROTATION_0（默认值）
  /// - 顺时针旋转90度：TRTCCloudDef.TRTC_VIDEO_ROTATION_90
  /// - 顺时针旋转180度：TRTCCloudDef.TRTC_VIDEO_ROTATION_180
  /// - 顺时针旋转270度：TRTCCloudDef.TRTC_VIDEO_ROTATION_270
  /// @param mirrorType 镜像模式
  /// - TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_AUTO：前置摄像头开启镜像，后置摄像头不开启镜像（默认值）
  /// - TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE：前置摄像头和后置摄像头都开启镜像
  /// - TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_DISABLE：前置摄像头和后置摄像头都不开启其镜像
  Future<void> setRemoteViewParam(String userId, int streamType,
      {int fillMode, int rotation, int mirrorType});

  /// 静音/取消静音指定成员的远端音频
  ///
  /// @param userId 指定成员的 userId
  /// @param mute true：静音；false：关闭静音
  Future<void> muteRemoteAudio(String userId, bool mute);

  /// 静音/取消静音所有成员的远端音频
  ///
  /// @param mute true：静音；false：关闭静音
  Future<void> muteAllRemoteAudio(bool mute);

  /// 暂停/恢复指定成员的远端视频
  ///
  /// @param userId 指定成员的 userId
  /// @param mute true：暂停；false：恢复
  Future<void> muteRemoteVideoStream(String userId, bool mute);

  /// 暂停/恢复所有成员的远端视频流
  ///
  /// @param mute true：暂停；false：恢复
  Future<void> muteAllRemoteVideoStream(bool mute);

  //////////////////////////////////////////////////////////
  ///
  ///                 本地视频操作接口
  ///
  //////////////////////////////////////////////////////////

  /// 开启本地视频的预览画面
  ///
  /// @param isFront true：前置摄像头；false：后置摄像头
  /// @param viewId TRTCCloudVideoView生成的 viewId
  Future<void> startCameraPreview(bool isFront, int viewId);

  /// 停止本地视频采集及预览
  Future<void> stopCameraPreview();

  /// 更新本地视频预览画面的窗口，仅仅iOS有效
  ///
  /// @param viewId 承载视频画面的控件
  Future<void> updateCameraPreview(int viewId);

  /// 切换前后摄像头
  ///
  /// @param isFront true：前置摄像头；false：后置摄像头
  Future<void> switchCamera(bool isFront);

  /// 设置视频编码器相关参数
  ///
  /// @param videoFps 视频采集帧率
  /// @param videoBitrate 码率，SDK 会按照目标码率进行编码，只有在网络不佳的情况下才会主动降低视频码率
  /// @param videoResolution 视频分辨率
  /// @param videoResolutionMode 分辨率模式
  Future<void> setVideoEncoderParam({
    int videoFps,
    int videoBitrate,
    int videoResolution,
    int videoResolutionMode,
  });

  /// 设置本地画面镜像预览模式
  ///
  /// @param isMirror 是否开启镜像预览模式
  Future<void> setLocalViewMirror(bool isMirror);

  //////////////////////////////////////////////////////////
  ///
  ///                 本地音频操作接口
  ///
  //////////////////////////////////////////////////////////

  /// 开启麦克风采集
  ///
  /// @param quality 音频质量
  Future<void> startMicrophone({int quality});

  /// 停止麦克风采集
  Future<void> stopMicrophone();

  /// 开启/关闭本地静音
  ///
  /// @param mute true：静音；false：取消静音
  Future<void> muteLocalAudio(bool mute);

  /// 设置开启扬声器或听筒
  ///
  /// @param useSpeaker true：扬声器；false：听筒
  Future<void> setSpeaker(bool useSpeaker);

  /// 设置麦克风采集音量
  ///
  /// @param volume 采集音量，取值0 - 100，默认值为100
  Future<void> setAudioCaptureVolume(int volume);

  /// 设置播放音量
  ///
  /// @param volumn 播放音量，取值0 - 100，默认值100
  Future<void> setAudioPlayoutVolume(int volume);

  /// 开始录音
  ///
  /// 0：成功；-1：录音已开始；-2：文件或目录创建失败；-3：后缀指定的音频格式不支持； -1001:参数错误
  ///
  /// @param filePath 录音文件的保存路径，该路径需要用户自行指定，请确保路径存在且可写。该路径需精确到文件名及格式后缀，格式后缀决定录音文件的格式，目前支持的格式有 PCM、WAV 和 AAC
  Future<int?> startAudioRecording(String filePath);

  /// 停止录音
  Future<void> stopAudioRecording();

  /// 启用音量大小提示
  ///
  /// 开启后会在 onUserVoiceVolume 中获取到 SDK 对音量大小值的评估。如需打开此功能，请在 startLocalAudio() 之前调用
  ///
  /// @param intervalMs 决定了 onUserVoiceVolume 回调的触发间隔，单位为ms，最小间隔为100ms，如果小于等于0则会关闭回调，建议设置为300ms
  Future<void> enableAudioVolumeEvaluation(int intervalMs);

  //////////////////////////////////////////////////////////
  ///
  ///                 录屏接口
  ///
  //////////////////////////////////////////////////////////

  /// 启动屏幕分享
  ///
  /// @param videoFps 视频采集帧率
  /// @param videoBitrate 码率，SDK 会按照目标码率进行编码，只有在网络不佳的情况下才会主动降低视频码率
  /// @param videoResolution 视频分辨率
  /// @param videoResolutionMode 分辨率模式
  /// @param appGroup 该参数仅仅在ios端有效，Android端不需要关注这个参数。该参数是主 App 与 Broadcast 共享的 Application Group Identifier
  Future<void> startScreenCapture({
    int videoFps,
    int videoBitrate,
    int videoResolution,
    int videoResolutionMode,
    String appGroup,
  });

  /// 停止屏幕采集
  Future<void> stopScreenCapture();

  /// 暂停屏幕采集
  Future<void> pauseScreenCapture();

  /// 恢复屏幕采集
  Future<void> resumeScreenCapture();

  //////////////////////////////////////////////////////////
  ///
  ///                 获取相关管理对象接口
  ///
  //////////////////////////////////////////////////////////

  /// 获取设备管理对象 TXDeviceManager
  getDeviceManager();

  /// 获取美颜管理对象 TXBeautyManager
  getBeautyManager();

  //////////////////////////////////////////////////////////
  ///
  ///                 消息发送相关接口
  ///
  //////////////////////////////////////////////////////////

  /// 在会议中广播文本消息，一般用于聊天
  ///
  /// @param message 文本消息
  Future<ActionCallback> sendRoomTextMsg(String message);

  /// 发送自定义文本消息
  ///
  /// @param cmd 命令字，由开发者自定义，主要用于区分不同消息类型
  /// @param message 文本消息
  Future<ActionCallback> sendRoomCustomMsg(String cmd, String message);
}
