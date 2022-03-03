import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trtc_scenes_demo/TRTCChatSalonDemo/model/TRTCChatSalonDelegate.dart';
import 'package:trtc_scenes_demo/base/YunApiHelper.dart';
import '../../../utils/TxUtils.dart';
import '../widget/RoomBottomBar.dart';
import '../widget/AnchorItem.dart';
import '../widget/AudienceItem.dart';
import '../widget/RoomTopMsg.dart';
import '../widget/DescriptionTitle.dart';
import '../base/UserEnum.dart';
import '../../model/TRTCChatSalon.dart';
import '../../model/TRTCChatSalonDef.dart';
import '../../../i10n/localization_intl.dart';

/*
 *  房间界面
 */
class VoiceRoomPage extends StatefulWidget {
  VoiceRoomPage(this.userType, {Key? key}) : super(key: key);
  final UserType userType;
  @override
  State<StatefulWidget> createState() => VoiceRoomPageState();
}

class VoiceRoomPageState extends State<VoiceRoomPage>
    with TickerProviderStateMixin {
  int currentRoomId = -1;
  late int currentRoomOwnerId;
  late int currentLoginUserId;

  late TRTCChatSalon trtcVoiceRoom;
  UserStatus userStatus = UserStatus.Mute;
  String title = "";
  UserType userType = UserType.Administrator;
  bool topMsgVisible = false;
  bool isShowTopMsgAction = false;
  String topMsg = "";

  //主播列表
  Map<int, UserInfo> _anchorList = {};
  //听众列表
  Map<int, UserInfo> _audienceList = {};
  int _audienceNextSeq = 0;
  //举手列表
  Map<int, RaiseHandInfo> _raiseHandList = {};
  RaiseHandInfo? _lastRaiseHandUser;

  //大声列表
  Map<int, bool> _volumeUpdateList = {};

  @override
  void initState() {
    super.initState();
    this.initSDK();
  }

  @override
  dispose() {
    trtcVoiceRoom.unRegisterListener(onVoiceListener);
    super.dispose();
  }

  initSDK() async {
    trtcVoiceRoom = await TRTCChatSalon.sharedInstance();
    this.initUserInfo();
  }

  UserInfo? _finUserInfo(int userId) {
    if (_anchorList.containsKey(userId)) return _anchorList[userId];
    if (_audienceList.containsKey(userId)) return _audienceList[userId];
    return null;
  }

  //trtc的所有事件监听
  onVoiceListener(type, param) async {
    switch (type) {
      case TRTCChatSalonDelegate.onError:
        {
          TxUtils.showErrorToast(type.toString(), context);
        }
        break;
      case TRTCChatSalonDelegate.onEnterRoom:
        {
          //进房
          int result = param as int;
          if (result < 0) {
            TxUtils.showErrorToast(
                Languages.of(context)!.failEnterRoom, context);
            Navigator.pushReplacementNamed(
              context,
              "/chatSalon/list",
            );
            return;
          }
        }
        break;
      case TRTCChatSalonDelegate.onAgreeToSpeak:
        this.doOnAgreeToSpeak(param);
        break;
      case TRTCChatSalonDelegate.onRefuseToSpeak:
        this.doOnRefuseToSpeak(param);
        break;
      case TRTCChatSalonDelegate.onRaiseHand:
        this.doOnRaiseHand(param);
        break;
      case TRTCChatSalonDelegate.onKickMic:
        this.doOnKickMic(param);
        break;
      case TRTCChatSalonDelegate.onAudienceEnter:
        this.doOnAudienceEnter(param);
        break;
      case TRTCChatSalonDelegate.onExitRoom:
        {}
        break;
      case TRTCChatSalonDelegate.onAudienceExit:
        this.doOnAudienceExit(param);
        break;
      case TRTCChatSalonDelegate.onAnchorLeaveMic:
        {
          //主播离开房间
          this.doOnAnchorLeave(param);
        }
        break;
      case TRTCChatSalonDelegate.onAnchorEnterMic:
        {
          //主播进入房间
          this.doOnAnchorEnter(param);
        }
        break;
      case TRTCChatSalonDelegate.onMicMute:
        {
          //主播是否禁麦
          this.getAnchorList();
        }
        break;
      case TRTCChatSalonDelegate.onUserVolumeUpdate:
        {
          //上麦成员的音量变化
          this.doOnUserVolumeUpdate(param);
        }
        break;
      case TRTCChatSalonDelegate.onKickedOffline:
        {
          TxUtils.showErrorToast(
              Languages.of(context)!.failKickedOffline, context);
          Navigator.pushReplacementNamed(
            context,
            "/login",
          );
        }
        break;
      case TRTCChatSalonDelegate.onRoomDestroy:
        {
          //房间被销毁，当主播调用destroyRoom后，观众会收到该回调
          TxUtils.showErrorToast(
              Languages.of(context)!.failRoomDestroy, context);
          Navigator.pushReplacementNamed(
            context,
            "/chatSalon/list",
          );
        }
        break;
    }
  }

  //事件处理
  //群主同意举手
  doOnAgreeToSpeak(param) {
    this._closeTopMessage();
    trtcVoiceRoom.enterMic();
    setState(() {
      userType = UserType.Anchor;
      userStatus = UserStatus.Speaking;
    });
  }

  //群主拒绝举手
  doOnRefuseToSpeak(param) {
    this._showTopMessage(Languages.of(context)!.failRefuseToSpeak, false, true);
    setState(() {
      userType = UserType.Audience;
      userStatus = UserStatus.Mute;
    });
  }

  //有观众举手，申请上麦
  doOnRaiseHand(param) {
    int userId = int.parse(param);
    UserInfo? raiseUser = this._finUserInfo(userId);
    if (raiseUser != null) {
      this._showTopMessage(
          Languages.of(context)!.userRaiseHand(raiseUser.userName!),
          true,
          false);
      RaiseHandInfo tem = new RaiseHandInfo(
          isCanAgree: true,
          userAvatar: raiseUser.userAvatar!,
          userId: raiseUser.userId!,
          userName: raiseUser.userName!);
      Map<int, RaiseHandInfo> _newRaiseHandList = Map.from(_raiseHandList);
      _newRaiseHandList[userId] = tem;
      setState(() {
        _raiseHandList = _newRaiseHandList;
        _lastRaiseHandUser = tem;
      });
    }
  }

  ////被群主踢下麦
  doOnKickMic(param) async {
    this._showTopMessage(Languages.of(context)!.hadKickMic, false, true);
    trtcVoiceRoom.leaveMic();
    await this.getAnchorList();
    this.setState(() {
      userStatus = UserStatus.Mute;
      userType = UserType.Audience;
    });
  }

  //主播进入房间
  doOnAnchorEnter(param) {
    Map ps = param as Map;
    int userId = int.tryParse(ps['userId'])!;

    Map<int, UserInfo> _newAnchorList = Map.from(_anchorList);

    String userName = ps['userName'] as String;
    String userAvatar = ps['userAvatar'] as String;
    bool mute = ps['mute'] as bool;
    _newAnchorList[userId] = new UserInfo(
      userId: userId.toString(),
      mute: mute,
      userAvatar: userAvatar,
      userName: userName,
    );
    setState(() {
      _anchorList = _newAnchorList;
    });
    //更新观众
    if (_audienceList.containsKey(userId)) {
      Map<int, UserInfo> _newAudienceList = Map.from(_audienceList);
      _newAudienceList.remove(userId);
      setState(() {
        setState(() {
          _audienceList = _newAudienceList;
        });
      });
    }
  }

  //主播离开房间
  doOnAnchorLeave(param) {
    Map ps = param as Map;
    int userId = int.tryParse(ps['userId'])!;
    Map<int, UserInfo> _newAnchorList = Map.from(_anchorList);
    if (_newAnchorList.containsKey(userId)) {
      _newAnchorList.remove(userId);
    }
    setState(() {
      _anchorList = _newAnchorList;
    });
    //主播离开变为普通的听众
    Map<int, UserInfo> _newAudienceList = Map.from(_audienceList);
    String userName = ps['userName'] as String;
    String userAvatar = ps['userAvatar'] as String;
    bool mute = ps['mute'] as bool;
    _newAudienceList[userId] = new UserInfo(
      userId: userId.toString(),
      mute: mute,
      userAvatar: userAvatar,
      userName: userName,
    );
    setState(() {
      _audienceList = _newAudienceList;
    });
  }

  //观众进入房间
  doOnAudienceEnter(param) {
    print("==doOnAudienceEnter=" + param.toString());
    List<dynamic> list = param as List<dynamic>;
    Map<int, UserInfo> _newAudienceList = Map.from(_audienceList);
    list.forEach((element) {
      int userId = int.tryParse(element['userId'])!;
      String userName = element['userName'] as String;
      String userAvatar = element['userAvatar'] as String;
      _newAudienceList[userId] = new UserInfo(
          userId: userId.toString(),
          userAvatar: userAvatar,
          userName: userName);
    });
    setState(() {
      _audienceList = _newAudienceList;
    });
  }

  //观众离开房间
  doOnAudienceExit(param) {
    int userId = int.tryParse(param["userId"])!;
    if (_audienceList.containsKey(userId)) {
      Map<int, UserInfo> _newAudienceList = Map.from(_audienceList);
      _newAudienceList.remove(userId);
      setState(() {
        setState(() {
          _audienceList = _newAudienceList;
        });
      });
    }
    //把主播也一起踢了
    if (_anchorList.containsKey(userId)) {
      Map<int, UserInfo> _newAnchorListList = Map.from(_anchorList);
      _newAnchorListList.remove(userId);
      setState(() {
        setState(() {
          _anchorList = _newAnchorListList;
        });
      });
    }
  }

  //上麦成员的音量变化
  doOnUserVolumeUpdate(param) async {
    List<dynamic> list = param["userVolumes"] as List<dynamic>;
    Map<int, bool> _newVolumeUpdateList = Map.from(_volumeUpdateList);
    list.forEach((item) {
      int userId = currentLoginUserId;
      int volme = int.tryParse(item["volume"].toString())!;
      if (item['userId'] != null && item['userId'] != "") {
        userId = int.tryParse(item['userId'])!;
      }
      if (_anchorList.containsKey(userId)) {
        _newVolumeUpdateList[userId] = volme > 20 ? true : false;
      }
    });
    setState(() {
      _volumeUpdateList = _newVolumeUpdateList;
    });
  }

  initUserInfo() async {
    String loginUserId = await TxUtils.getLoginUserId();
    currentLoginUserId = int.tryParse(loginUserId)!;
    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    int _currentRoomId = int.tryParse(arguments['roomId'].toString())!;
    int _currentRoomOwnerId = int.tryParse(arguments['ownerId'].toString())!;
    String roomName =
        arguments["roomName"] == null ? '--' : arguments["roomName"];
    final bool isAdmin =
        _currentRoomOwnerId == currentLoginUserId ? true : false;
    bool isNeedCreateRoom = false;
    if (arguments.containsKey('isNeedCreateRoom')) {
      isNeedCreateRoom = arguments['isNeedCreateRoom'] as bool;
    }
    setState(() {
      currentRoomId = _currentRoomId;
      currentRoomOwnerId = _currentRoomOwnerId;
      userType = isAdmin ? UserType.Administrator : UserType.Audience;
      title = roomName;
    });
    if (isNeedCreateRoom) {
      String coverUrl = arguments['coverUrl'] as String;
      await this.createRoom(_currentRoomId, roomName, coverUrl);
      TxUtils.showToast(Languages.of(context)!.successCreateRoom, context);
    } else {
      ActionCallback enterRoomResp =
          await trtcVoiceRoom.enterRoom(_currentRoomId);
      if (enterRoomResp.code == 0) {
        if (isAdmin) {
          setState(() {
            userStatus = UserStatus.Speaking;
          });
          TxUtils.showToast(
              Languages.of(context)!.successAdminEnterRoom, context);
        } else {
          TxUtils.showToast(Languages.of(context)!.successEnterRoom, context);
        }
      } else {
        TxUtils.showErrorToast('enterRoom:' + enterRoomResp.desc, context);
      }
    }
    trtcVoiceRoom.registerListener(onVoiceListener);
    await this.getAnchorList();
    await this.getAudienceList();
  }

  createRoom(roomId, roomName, coverUrl) async {
    ActionCallback resp = await trtcVoiceRoom.createRoom(
      roomId,
      RoomParam(
        coverUrl: coverUrl,
        roomName: roomName,
      ),
    );
    if (resp.code == 0) {
      await YunApiHelper.createRoom(roomId.toString());
    } else {
      TxUtils.showErrorToast('createRoom:' + resp.desc, context);
    }
  }

  //获取主播列表
  getAnchorList() async {
    try {
      UserListCallback _archorResp = await trtcVoiceRoom.getArchorInfoList();
      if (_archorResp.code == 0) {
        Map<int, UserInfo> _newArchorList = {};
        _archorResp.list!.forEach((item) {
          if (item.userId != null && item.userId != '') {
            _newArchorList[int.tryParse(item.userId!)!] = item;
          }
        });
        setState(() {
          userType = !_newArchorList.containsKey(currentLoginUserId)
              ? UserType.Audience
              : userType == UserType.Administrator
                  ? UserType.Administrator
                  : UserType.Anchor;
          userStatus = _newArchorList.containsKey(currentLoginUserId)
              ? _newArchorList[currentLoginUserId]!.mute!
                  ? UserStatus.Mute
                  : UserStatus.Speaking
              : UserStatus.Mute;
        });

        setState(() {
          _anchorList = _newArchorList;
        });
      } else {
        TxUtils.showErrorToast(
            'getArchorInfoList:' + _archorResp.desc, context);
      }
    } catch (ex) {
      TxUtils.showErrorToast(ex.toString(), context);
    }
  }

  // 获取听众列表
  getAudienceList() async {
    try {
      MemberListCallback _memberResp = await trtcVoiceRoom.getRoomMemberList(0);
      if (_memberResp.code == 0) {
        Map<int, UserInfo> userList = {};
        _memberResp.list!.forEach((item) {
          if (item.userId != null && item.userId != '') {
            int userId = int.tryParse(item.userId!)!;
            //非主播
            if (!_anchorList.containsKey(userId)) {
              userList[userId] = item;
            }
          }
        });
        setState(() {
          _audienceList = userList;
          _audienceNextSeq = _memberResp.nextSeq;
        });
      } else {
        TxUtils.showErrorToast(
            "getRoomMemberList:" + _memberResp.desc, context);
      }
    } catch (ex) {
      TxUtils.showErrorToast(ex.toString(), context);
    }
  }

  getMoreAudienceList() async {
    try {
      if (_audienceNextSeq == 0) {
        return;
      }
      MemberListCallback _memberResp =
          await trtcVoiceRoom.getRoomMemberList(_audienceNextSeq);
      if (_memberResp.code == 0) {
        Map<int, UserInfo> userList = {};
        _memberResp.list!.forEach((item) {
          if (item.userId != null && item.userId != '') {
            int userId = int.tryParse(item.userId!)!;
            //非主播
            if (!_anchorList.containsKey(userId)) {
              userList[userId] = item;
            }
          }
        });
        setState(() {
          _audienceList.addAll(userList);
          _audienceNextSeq = _memberResp.nextSeq;
        });
      } else {
        TxUtils.showErrorToast(
            "getRoomMemberList:" + _memberResp.desc, context);
      }
    } catch (ex) {
      TxUtils.showErrorToast(ex.toString(), context);
    }
  }

  //管理员同意其成为主播
  agreeToSpeackClick({userId}) {
    String tmpUserId = '';
    if (userId != null) {
      tmpUserId = userId;
    } else {
      if (_lastRaiseHandUser != null) {
        tmpUserId = _lastRaiseHandUser!.userId;
      }
    }
    if (tmpUserId != '') {
      trtcVoiceRoom.agreeToSpeak(tmpUserId);
      this._closeTopMessage();
      if (_raiseHandList.containsKey(int.parse(tmpUserId))) {
        //同意后也移除
        // this.setState(() {
        //   _raiseHandList[int.parse(tmpUserId)].isCanAgree = false;
        // });
        if (_raiseHandList.containsKey(int.parse(tmpUserId))) {
          _raiseHandList.remove(int.parse(tmpUserId));
        }
      }
    }
  }

  //管理员拒绝其成为主播
  handleAdminRefuseToSpeak({userId}) {
    String tmpUserId = '';
    if (userId != null) {
      tmpUserId = userId;
    } else {
      if (_lastRaiseHandUser != null) {
        tmpUserId = _lastRaiseHandUser!.userId;
      }
    }
    if (tmpUserId != '') {
      trtcVoiceRoom.refuseToSpeak(tmpUserId);
      this._closeTopMessage();
      if (_raiseHandList.containsKey(int.parse(tmpUserId))) {
        _raiseHandList.remove(int.parse(tmpUserId));
        //_raiseHandList[int.parse(userId)].isCanAgree = false;
      }
    }
  }

  //主播下麦
  handleAnchorLeaveMic() {
    trtcVoiceRoom.leaveMic();
    //变为听众
    this.setState(() {
      userType = UserType.Audience;
    });
  }

  //音频开关
  handleMuteAudio(bool mute) {
    //设置
    trtcVoiceRoom.muteMic(mute);
    setState(() {
      //状态图标切换
      userStatus = mute ? UserStatus.Mute : UserStatus.Speaking;
    });
  }

  //听众举手
  handleRaiseHandClick() {
    trtcVoiceRoom.raiseHand();
    this._showTopMessage(Languages.of(context)!.successRaiseHand, false, true);
  }

  _showTopMessage(String message, bool showActionBtn, bool autoClose) {
    setState(() {
      topMsgVisible = true;
      topMsg = message;
      isShowTopMsgAction = showActionBtn;
    });
    if (autoClose) {
      Future.delayed(Duration(seconds: 5), () {
        this._closeTopMessage();
      });
    }
  }

  _closeTopMessage() {
    setState(() {
      topMsgVisible = false;
      isShowTopMsgAction = false;
      topMsg = "";
    });
  }

  // 弹出退房确认对话框
  Future<bool?>? showExitConfirmDialog() {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return Theme(
            data: ThemeData.dark(),
            child: CupertinoAlertDialog(
              content: Container(
                child: Text(
                  userType == UserType.Administrator
                      ? Languages.of(context)!.adminLeaveRoomTips
                      : Languages.of(context)!.leaveRoomTips,
                  textAlign: TextAlign.center,
                ),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(
                    Languages.of(context)!.waitTips,
                    style: TextStyle(color: Color.fromRGBO(235, 244, 255, 1)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                CupertinoDialogAction(
                  child: Text(
                    Languages.of(context)!.iSure,
                    style: TextStyle(color: Color.fromRGBO(0, 98, 227, 1)),
                  ),
                  onPressed: () {
                    if (userType == UserType.Administrator) {
                      YunApiHelper.destroyRoom(currentRoomId.toString())
                          .then((value) {
                        trtcVoiceRoom.destroyRoom().then((value) {
                          Navigator.of(context).pop(true);
                        });
                      });
                    } else {
                      trtcVoiceRoom.exitRoom().then((value) {
                        Navigator.of(context).pop(true);
                      });
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  Widget getAnchorListWidget(BuildContext context) {
    return Container(
      height: _anchorList.length == 0 ? 30 : 140,
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      constraints: BoxConstraints(
        minHeight: _anchorList.length == 0 ? 30 : 140,
      ),
      width: MediaQuery.of(context).size.width,
      child: GridView(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 135.0,
          mainAxisSpacing: 20,
          crossAxisSpacing: 15, //水平间隔
          childAspectRatio: 1.0,
        ),
        children: _anchorList.values.map((UserInfo _anchorItem) {
          int thisUserId = int.tryParse(_anchorItem.userId!)!;
          bool isVolumeUpdate = (_volumeUpdateList.containsKey(thisUserId)
              ? _volumeUpdateList[thisUserId]
              : false)!;
          return AnchorItem(
            roomOwnerId: currentRoomOwnerId,
            isVolumeUpdate: isVolumeUpdate,
            userName:
                _anchorItem.userName != null && _anchorItem.userAvatar != ''
                    ? _anchorItem.userName!
                    : '--',
            userImgUrl:
                _anchorItem.userAvatar != null && _anchorItem.userAvatar != ''
                    ? _anchorItem.userAvatar
                    : TxUtils.getRandoAvatarUrl(),
            isAdministrator: thisUserId == currentRoomOwnerId ? true : false,
            isMute: _anchorItem.mute!,
            userId: _anchorItem.userId,
            onKickOutUser: () {
              //踢人
              trtcVoiceRoom.kickMic(_anchorItem.userId!);
            },
          );
        }).toList()
          ..sort((left, right) {
            if (left.isAdministrator) return -1;
            return 1;
          }),
      ),
    );
  }

  Widget getAudienceListWidget(BuildContext context) {
    List<UserInfo> list = _audienceList.values.toList();
    return Expanded(
      flex: 2,
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 100.0,
          mainAxisSpacing: 10,
          crossAxisSpacing: 15,
          childAspectRatio: 0.9,
        ),
        itemCount: list.length,
        itemBuilder: (context, int index) {
          if (index == (list.length - 1)) {
            this.getMoreAudienceList();
          }
          var _audienceItem = list[index];
          var buildItem = AudienceItem(
            userImgUrl: _audienceItem.userAvatar != null &&
                    _audienceItem.userAvatar != ''
                ? _audienceItem.userAvatar
                : TxUtils.getRandoAvatarUrl(),
            userName:
                _audienceItem.userName != null && _audienceItem.userName != ''
                    ? _audienceItem.userName!
                    : '--',
          );
          return buildItem;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title + '($currentRoomId)'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios), //color: Colors.black
          onPressed: () async {
            bool isOk = (await this.showExitConfirmDialog())!;
            if (isOk) {
              Navigator.pushReplacementNamed(context, '/chatSalon/list');
            }
          },
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromRGBO(19, 41, 75, 1),
      ),
      body: WillPopScope(
        onWillPop: () async {
          bool isOk = (await this.showExitConfirmDialog())!;
          if (isOk) {
            Navigator.pushReplacementNamed(context, '/chatSalon/list');
          }
          return isOk;
        },
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Stack(
            alignment: Alignment.topLeft,
            fit: StackFit.expand,
            children: <Widget>[
              Container(
                alignment: Alignment.topLeft,
                child: Flex(
                  direction: Axis.vertical,
                  children: <Widget>[
                    RoomTopMessage(
                      message: topMsg,
                      visible: topMsgVisible,
                      isShowBtn: isShowTopMsgAction,
                      okTitle: Languages.of(context)!.welcome,
                      cancelTitle: Languages.of(context)!.ignore,
                      onCancelTab: () {
                        this.handleAdminRefuseToSpeak();
                      },
                      onOkTab: () {
                        this.agreeToSpeackClick();
                      },
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: DescriptionTitle("assets/images/Anchor_ICON.png",
                          Languages.of(context)!.anchor),
                    ),
                    this.getAnchorListWidget(context),
                    DescriptionTitle("assets/images/Audience_ICON.png",
                        Languages.of(context)!.audience),
                    this.getAudienceListWidget(context),
                    Expanded(
                      flex: 0,
                      child: Container(
                        height: 60,
                      ),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    stops: [0.0, 1.0],
                    colors: [
                      Color.fromRGBO(19, 41, 75, 1),
                      Color.fromRGBO(0, 0, 0, 1),
                    ],
                  ),
                ),
              ),
              RoomBottomBar(
                userStatus: userStatus,
                userType: userType,
                raiseHandList: _raiseHandList.values.toList(),
                onMuteAudio: (mute) {
                  this.handleMuteAudio(mute);
                },
                onAgreeToSpeak: (String userId) {
                  this.agreeToSpeackClick(userId: userId);
                },
                onRaiseHand: () {
                  this.handleRaiseHandClick();
                },
                onAnchorLeaveMic: () {
                  //主播下麦
                  this.handleAnchorLeaveMic();
                },
                onLeave: () async {
                  bool isOk = (await this.showExitConfirmDialog())!;
                  if (isOk) {
                    Navigator.pushReplacementNamed(context, '/chatSalon/list');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
