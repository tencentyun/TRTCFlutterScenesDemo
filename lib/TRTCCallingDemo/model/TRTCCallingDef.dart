// 关键类定义

class ActionCallback {
  /// 错误码
  int code;

  /// 信息描述
  String desc;

  ActionCallback({this.code = 0, this.desc = ''});
}

class RoomInfo {
  /// 【字段含义】房间唯一标识
  int roomId;

  /// 【字段含义】房间名称
  String? roomName;

  /// 【字段含义】房间封面图
  String? coverUrl;

  /// 【字段含义】房主id
  String ownerId;

  /// 【字段含义】房主昵称
  String? ownerName;

  /// 【字段含义】房间人数
  int? memberCount;

  RoomInfo(
      {required this.roomId,
      this.roomName,
      this.coverUrl,
      this.memberCount,
      required this.ownerId,
      this.ownerName});
}

class RoomInfoCallback {
  /// 错误码
  int code;

  /// 信息描述
  String desc;

  List<RoomInfo>? list;

  RoomInfoCallback({required this.code, required this.desc, this.list});
}

class RoomParam {
  /// 房间名称
  String? roomName;

  /// 房间封面图
  String? coverUrl;

  RoomParam({this.roomName, this.coverUrl});
}

class MemberListCallback {
  /// 错误码
  int code;

  /// 信息描述
  String desc;

  /// nextSeq	分页拉取标志，第一次拉取填0，回调成功如果 nextSeq 不为零，需要分页，传入再次拉取，直至为0。
  int nextSeq;

  List<UserInfo>? list;

  MemberListCallback(
      {this.code = 0, this.desc = '', this.nextSeq = 0, this.list});
}

class UserListCallback {
  /// 错误码
  int code;

  /// 信息描述
  String desc;

  /// 用户信息列表
  List<UserInfo>? list;

  UserListCallback({this.code = 0, this.desc = '', this.list});
}

class UserInfo {
  /// 用户唯一标识
  String userId;

  /// 用户昵称
  String userName;

  /// 用户头像
  String userAvatar;

  /// 主播是否开麦
  bool mute;

  UserInfo(
      {required this.userId,
      required this.userName,
      required this.userAvatar,
      required this.mute});
}
