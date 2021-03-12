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
