import '../utils/TxUtils.dart';

class UserModel {
  String phone;
  String name;
  String avatar;
  String userId;
  UserModel(
      {this.phone = '', this.name = '', this.avatar = '', this.userId = ''});
}

class ProfileManager {
  static ProfileManager? _instance;

  static getInstance() {
    if (_instance == null) {
      _instance = new ProfileManager();
    }
    return _instance;
  }

  Future<List<UserModel>> queryUserInfo(String userId) {
    return Future.value([
      UserModel(
          phone: userId,
          name: userId,
          avatar: TxUtils.getDefaltAvatarUrl(),
          userId: userId)
    ]);
  }

  Future<UserModel> querySingleUserInfo(String userId) {
    return Future.value(UserModel(
        phone: userId,
        name: userId,
        avatar: TxUtils.getDefaltAvatarUrl(),
        userId: userId));
  }
}
