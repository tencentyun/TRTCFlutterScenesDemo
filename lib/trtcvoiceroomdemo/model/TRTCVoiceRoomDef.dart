library my_app;

class ActionCallback {
  /// 错误码
  int code;

  /// 信息描述
  String desc;

  ActionCallback({this.code = 0, this.desc = ''});

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['code'] = this.code;
  //   data['msg'] = this.msg;
  //   return data;
  // }
}

class RoomInfo {
  /// 【字段含义】房间唯一标识
  int roomId;

  /// 【字段含义】房间名称
  String roomName;

  /// 【字段含义】房间封面图
  String coverUrl;

  /// 【字段含义】房主id
  String ownerId;

  /// 【字段含义】房主昵称
  String ownerName;

  /// 【字段含义】房间人数
  int memberCount;

  RoomInfo(
      {this.roomId,
      this.roomName,
      this.coverUrl,
      this.memberCount,
      this.ownerId,
      this.ownerName});
}

class RoomInfoCallback {
  /// 错误码
  int code;

  /// 信息描述
  String desc;

  List<RoomInfo> list;

  RoomInfoCallback({this.code, this.desc, this.list});
}

class RoomParam {
  /// 【字段含义】房间名称
  String roomName;

  /// 【字段含义】房间封面图
  String coverUrl;

  RoomParam({this.roomName, this.coverUrl});
}

class MemberListCallback {
  /// 错误码
  int code;

  /// 信息描述
  String desc;

  int nextSeq;

  List<UserInfo> list;

  MemberListCallback(
      {this.code = 0, this.desc = '', this.nextSeq = 0, this.list});
}

class UserListCallback {
  /// 错误码
  int code;

  /// 信息描述
  String desc;

  List<UserInfo> list;

  UserListCallback({this.code = 0, this.desc = '', this.list});
}

class UserInfo {
  /// 【字段含义】用户唯一标识
  String userId;

  /// 【字段含义】用户昵称
  String userName;

  /// 【字段含义】用户头像
  String userAvatar;

  UserInfo({this.userId, this.userName, this.userAvatar});
}
