// 关键类型定义

class ActionCallback {
  /// 错误码
  int code;

  /// 信息描述
  String desc;

  ActionCallback({this.code = 0, this.desc = ''});
}

class UserListCallback {
  /// 错误码
  int code;

  /// 信息描述
  String desc;

  /// 用户信息列表
  List<UserInfo>? list;

  UserListCallback({
    this.code = 0,
    this.desc = '',
    this.list,
  });
}

class UserInfo {
  /// 用户唯一标识
  String? userId;

  /// 用户昵称
  String? userName;

  /// 用户头像
  String? userAvatar;

  UserInfo({
    this.userId,
    this.userName,
    this.userAvatar,
  });
}
