import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'messages_all.dart';

class Languages {
  static Future<Languages> load(Locale locale) {
    final String name;
    var countryCode = locale.countryCode;
    if (countryCode!.isEmpty) {
      name = locale.languageCode;
    } else {
      name = locale.toString();
    }
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((b) {
      Intl.defaultLocale = localeName;
      return new Languages();
    });
  }

  static Languages? of(BuildContext context) {
    return Localizations.of<Languages>(context, Languages);
  }

  /*
   * index.dart start
   */
  String get trtc => Intl.message('TRTC', name: 'trtc');
  String get logout => Intl.message('退出', name: 'logout');
  String get salonTitle => Intl.message('语音沙龙', name: 'salonTitle');
  String get titleTRTC => Intl.message('TRTC', name: 'titleTRTC');
  String get login => Intl.message('登录', name: 'login');
  String get okText => Intl.message('确定', name: 'okText');
  String get cancelText => Intl.message('取消', name: 'cancelText');
  String get tipsText => Intl.message('提示', name: 'tipsText');
  String get settingText => Intl.message('设置', name: 'settingText');
  String get logoutContent => Intl.message('确定退出登录吗?', name: 'logoutContent');

  /*
   * login.dart start
   */
  String get errorUserIDInput =>
      Intl.message('请输入用户ID', name: 'errorUserIDInput');
  String get errorUserIDNumber =>
      Intl.message('用户ID必须为数字', name: 'errorUserIDNumber');
  String get successLogin => Intl.message('登录成功', name: 'successLogin');
  String get tencentTRTC => Intl.message('腾讯云TRTC', name: 'tencentTRTC');
  String get userIDLabel => Intl.message('用户ID', name: 'userIDLabel');
  String get userIDHintText =>
      Intl.message('请输入登录的UserID', name: 'userIDHintText');

  /*
   * VoiceRoomList.dart start
   */
  String get errorOpenUrl => Intl.message('打开地址失败', name: 'errorOpenUrl');
  String get helpTooltip => Intl.message('查看说明文档', name: 'helpTooltip');
  String get refreshText => Intl.message('下拉刷新', name: 'refreshText');
  String get refreshReadyText =>
      Intl.message('准备刷新数据', name: 'refreshReadyText');
  String get refreshingText => Intl.message('正在刷新中...', name: 'refreshingText');
  String get refreshedText => Intl.message('刷新完成', name: 'refreshedText');
  String get noHadSalon => Intl.message('暂无语音沙龙', name: 'noHadSalon');
  String onLineCount(int memberCount) =>
      Intl.message('$memberCount人在线', name: 'onLineCount', args: [memberCount]);

  /*
   * VoiceRoomCreate.dart start
   */
  String defaultChatTitle(String userName) =>
      Intl.message('$userName的主题', name: 'defaultChatTitle', args: [userName]);
  String get errorsdkAppId =>
      Intl.message('请填写SDKAPPID', name: 'errorsdkAppId');
  String get errorSecretKey => Intl.message('请填写密钥', name: 'errorSecretKey');
  String get errorMeetTitle => Intl.message('请输入房间主题', name: 'errorMeetTitle');
  String get errorMeetTitleLength =>
      Intl.message('房间主题过长，请输入合法的房间主题', name: 'errorMeetTitleLength');
  String get errorUserName => Intl.message('请输入用户名', name: 'errorUserName');
  String get errorUserNameLength =>
      Intl.message('用户名过长，请输入合法的用户名', name: 'errorUserNameLength');
  String get errorMicrophonePermission =>
      Intl.message('需要获取音视频权限才能进入', name: 'errorMicrophonePermission');
  String get createSalonTooltip =>
      Intl.message('创建语音沙龙', name: 'createSalonTooltip');
  String get meetTitleLabel => Intl.message('主题', name: 'meetTitleLabel');
  String get meetTitleHintText =>
      Intl.message('请输入房间名称', name: 'meetTitleHintText');
  String get userNameLabel => Intl.message('用户名', name: 'userNameLabel');
  String get userNameHintText =>
      Intl.message('请输入用户名', name: 'userNameHintText');
  String get startSalon => Intl.message('开始交谈', name: 'startSalon');

  /*
   * VoiceRoomPage.dart
   */
  String get failEnterRoom => Intl.message('进房失败', name: 'failEnterRoom');
  String get failKickedOffline =>
      Intl.message('已在其他地方登陆，请重新登录', name: 'failKickedOffline');
  String get failRoomDestroy => Intl.message('沙龙已结束。', name: 'failRoomDestroy');
  String get failRefuseToSpeak =>
      Intl.message('抱歉，管理员没有同意您上麦', name: 'failRefuseToSpeak');
  String userRaiseHand(String userName) =>
      Intl.message('$userName申请成为主播', name: 'userRaiseHand', args: [userName]);
  String get hadKickMic => Intl.message('你已被主播踢下麦', name: 'hadKickMic');
  String get successCreateRoom =>
      Intl.message('房间创建成功。', name: 'successCreateRoom');
  String get successEnterRoom => Intl.message('进房成功', name: 'successEnterRoom');
  String get successAdminEnterRoom =>
      Intl.message('房主占座成功。', name: 'successAdminEnterRoom');
  String get successRaiseHand =>
      Intl.message('举手成功！等待管理员通过~', name: 'successRaiseHand');

  String get adminLeaveRoomTips =>
      Intl.message('离开会解散房间，确定离开吗?', name: 'adminLeaveRoomTips');
  String get leaveRoomTips => Intl.message('确定离开房间吗?', name: 'leaveRoomTips');
  String get waitTips => Intl.message('再等等', name: 'waitTips');
  String get iSure => Intl.message('我确定', name: 'iSure');
  String get welcome => Intl.message('欢迎', name: 'welcome');
  String get ignore => Intl.message('忽略', name: 'ignore');
  String get anchor => Intl.message('主播', name: 'anchor');
  String get audience => Intl.message('听众', name: 'audience');
  String get kickMic => Intl.message('要求下麦', name: 'kickMic');
  String get raiseUpList => Intl.message('举手列表', name: 'raiseUpList');
  String get leaveTips => Intl.message('安静离开~', name: 'leaveTips');

  /*
   * TRTCMeetingIndex.dart
   */
  String get errorMeetingIdInput =>
      Intl.message('请输入合法的会议ID', name: 'errorMeetingIdInput');
  String get errorMeetingIdNumber =>
      Intl.message('会议ID只能为数字，请输入合法的会议ID', name: 'errorMeetingIdNumber');
  String get errorMeetingIdLength =>
      Intl.message('会议ID过长，请输入合法的会议ID', name: 'errorMeetingIdLength');
  String get meetingCallTitle =>
      Intl.message('多人视频会议', name: 'meetingCallTitle');
  String get meetingInputLabel =>
      Intl.message('会议号', name: 'meetingInputLabel');
  String get meetingInputHintText =>
      Intl.message('请输入会议号', name: 'meetingInputHintText');
  String get meetingTurnOnCamera =>
      Intl.message('开启摄像头', name: 'meetingTurnOnCamera');
  String get meetingTurnOnMic =>
      Intl.message('开启麦克风', name: 'meetingTurnOnMic');
  String get meetingEnterLabel =>
      Intl.message('进入会议', name: 'meetingEnterLabel');
  String get meetingLeaveLabel =>
      Intl.message('退出会议', name: 'meetingLeaveLabel');
  String get meetingLeaveTips =>
      Intl.message('确定退出会议?', name: 'meetingLeaveTips');
  String get meetingVideoSetting =>
      Intl.message('视频设置', name: 'meetingVideoSetting');
  String get meetingAudioSetting =>
      Intl.message('音频设置', name: 'meetingAudioSetting');
  String get meetingShareScreen =>
      Intl.message('共享屏幕', name: 'meetingShareScreen');
  String get meetingStopShareScreen =>
      Intl.message('停止共享', name: 'meetingStopShareScreen');
  String get meetingResolution =>
      Intl.message('分辨率', name: 'meetingResolution');
  String get meetingFrameRate => Intl.message('帧率', name: 'meetingFrameRate');
  String get meetingBitRate => Intl.message('码率', name: 'meetingBitRate');
  String get meetingLocalMirror =>
      Intl.message('本地镜像', name: 'meetingLocalMirror');
  String get meetingCaptureVolume =>
      Intl.message('采集音量', name: 'meetingCaptureVolume');
  String get meetingPlayVolume =>
      Intl.message('播放音量', name: 'meetingPlayVolume');
  String get meetingShareScreenStarted =>
      Intl.message('屏幕分享开始', name: 'meetingShareScreenStarted');
  String get meetingShareScreenPaused =>
      Intl.message('屏幕分享暂停', name: 'meetingShareScreenPaused');
  String get meetingShareScreenResumed =>
      Intl.message('屏幕分享恢复', name: 'meetingShareScreenResumed');
  String get meetingShareScreenStoped =>
      Intl.message('屏幕分享停止', name: 'meetingShareScreenStoped');
  String get meetingEnterRoomSuccess =>
      Intl.message('进房成功', name: 'meetingEnterRoomSuccess');
  String get meetingExitRoomSuccess =>
      Intl.message('退房成功', name: 'meetingExitRoomSuccess');
  String get meetingBeautyLevel =>
      Intl.message('强度', name: 'meetingBeautyLevel');
  String get meetingBeautySmooth =>
      Intl.message('光滑', name: 'meetingBeautySmooth');
  String get meetingBeautyNature =>
      Intl.message('自然', name: 'meetingBeautyNature');
  String get meetingBeautyPitu =>
      Intl.message('天天P图', name: 'meetingBeautyPitu');
  String get meetingBeautyWhitening =>
      Intl.message('美白', name: 'meetingBeautyWhitening');
  String get meetingBeautyRuddy =>
      Intl.message('红润', name: 'meetingBeautyRuddy');
  String get meetingMemberList =>
      Intl.message('成员列表', name: 'meetingMemberList');
  String get meetingMuteAllAudio =>
      Intl.message('全体静音', name: 'meetingMuteAllAudio');
  String get meetingUnmuteAllAudio =>
      Intl.message('解除全体静音', name: 'meetingUnmuteAllAudio');
  String get meetingMuteAllVideo =>
      Intl.message('全体禁画', name: 'meetingMuteAllVideo');
  String get meetingUnmuteAllVideo =>
      Intl.message('解除全体禁画', name: 'meetingUnmuteAllVideo');
  String get failShareScreen => Intl.message('播放音量', name: 'failShareScreen');
}

//Locale代理类
class AppLocalizationsDelegate extends LocalizationsDelegate<Languages> {
  const AppLocalizationsDelegate();

  static const AppLocalizationsDelegate delegate = AppLocalizationsDelegate();

  //是否支持某个Local
  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  // Flutter会调用此类加载相应的Locale资源类
  @override
  Future<Languages> load(Locale locale) {
    return Languages.load(locale);
  }

  // 当Localizations Widget重新build时，是否调用load重新加载Locale资源.
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
