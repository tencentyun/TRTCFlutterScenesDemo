import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'messages_all.dart'; //1

class Languages {
  static Future<Languages> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    //2
    return initializeMessages(localeName).then((b) {
      Intl.defaultLocale = localeName;
      return new Languages();
    });
  }

  static Languages of(BuildContext context) {
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
