// 关键类型定义

class ActionCallback {
  /// 错误码
  int code;

  /// 信息描述
  String desc;

  ActionCallback({this.code = 0, this.desc = ''});
}

class TRTCLiveRoomConfig {
  /// 【字段含义】观众端使用CDN播放
  /// 【特殊说明】true: 默认进房使用CDN播放 false: 使用低延时播放
  bool useCDNFirst;

  /// 【字段含义】CDN播放的域名地址
  String? cdnPlayDomain;
  TRTCLiveRoomConfig({required this.useCDNFirst, this.cdnPlayDomain});
}

class IMAnchorInfo {
  String? userId;
  String? streamId;
  String? name;

  IMAnchorInfo({this.userId, this.streamId, this.name});
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
  String roomName;

  /// 房间封面图
  String? coverUrl;

  /// 音质
  int? quality;

  RoomParam({required this.roomName, this.coverUrl, this.quality});
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

  /// nextSeq	分页拉取标志，第一次拉取填0，回调成功如果 nextSeq 不为零，需要分页，传入再次拉取，直至为0。
  int nextSeq;

  UserListCallback(
      {this.code = 0, this.desc = '', this.list, this.nextSeq = 0});
}

class UserInfo {
  /// 用户唯一标识
  String userId;

  /// 用户昵称
  String? userName;

  /// 用户头像
  String? userAvatar;

  UserInfo({
    required this.userId,
    this.userName,
    this.userAvatar,
  });
}
