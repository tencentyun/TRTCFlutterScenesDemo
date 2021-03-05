import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trtc_scenes_demo/TRTCVoiceRoomDemo/model/TRTCChatSalonDelegate.dart';
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

/*
 *  主播界面
 */
class VoiceRoomPage extends StatefulWidget {
  VoiceRoomPage(this.userType, {Key key}) : super(key: key);
  final UserType userType;
  @override
  State<StatefulWidget> createState() => VoiceRoomPageState();
}

class VoiceRoomPageState extends State<VoiceRoomPage>
    with TickerProviderStateMixin {
  int currentRoomId;
  int currentRoomOwnerId;

  TRTCChatSalon trtcVoiceRoom;
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
  //举手列表
  Map<int, RaiseHandInfo> _raiseHandList = {};
  RaiseHandInfo _lastRaiseHandUser;

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
    //销毁房间todo
    TRTCChatSalon.destroySharedInstance();
    super.dispose();
  }

  initSDK() async {
    trtcVoiceRoom = await TRTCChatSalon.sharedInstance();
    this.initUserInfo();
  }

  UserInfo _finUserInfo(int userId) {
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
          TxUtils.uploadException(
            "onVoiceListener-error",
            param.toString(),
          );
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
      case TRTCChatSalonDelegate.onAudienceExit:
        {
          //观众进入房间
          ////观众离开房间
          await this.getAnchorList();
          this.getAudienceList();
        }
        break;
      case TRTCChatSalonDelegate.onAnchorListChange:
      case TRTCChatSalonDelegate.onAnchorLeave:
      case TRTCChatSalonDelegate.onAnchorEnter:
        {
          //onAnchorListChange
          //有成员上麦(主动上麦/主播抱人上麦)
          await this.getAnchorList();
          this.getAudienceList();
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
          //_volumeUpdateList
          List<dynamic> list = param["userVolumes"] as List<dynamic>;
          list.forEach((item) {
            int userId = int.tryParse(item['userId']);
            int volme = int.tryParse(item["volume"].toString());
            if (_anchorList.containsKey(userId)) {
              setState(() {
                _volumeUpdateList[userId] = volme > 20 ? true : false;
              });
            }
          });
        }
        break;
      case TRTCChatSalonDelegate.onKickedOffline:
        {
          TxUtils.showErrorToast('已在其他地方登陆，请重新登录', context);
          Navigator.pushReplacementNamed(
            context,
            "/login",
          );
        }
        break;
      case TRTCChatSalonDelegate.onRoomDestroy:
        {
          TxUtils.showErrorToast('沙龙已结束。', context);
          Navigator.pushReplacementNamed(
            context,
            "/voiceRoom/list",
          );
          //房间被销毁，当主播调用destroyRoom后，观众会收到该回调
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
    this._closeTopMessage();
    setState(() {
      userType = UserType.Audience;
      userStatus = UserStatus.Mute;
    });
  }

  //有观众举手，申请上麦
  doOnRaiseHand(param) {
    int userId = int.parse(param);
    UserInfo raiseUser = this._finUserInfo(userId);
    if (raiseUser != null) {
      this._showTopMessage(raiseUser.userName + "申请成为主播", true);
      RaiseHandInfo tem = new RaiseHandInfo(
          isCanAgree: true,
          userAvatar: raiseUser.userAvatar,
          userId: raiseUser.userId,
          userName: raiseUser.userName);
      setState(() {
        _raiseHandList[userId] = tem;
        _lastRaiseHandUser = tem;
      });
    }
  }

  ////被群主踢下麦
  doOnKickMic(param) async {
    this._showTopMessage("你已被主播踢下麦", false);
    Future.delayed(Duration(seconds: 5), () {
      this._closeTopMessage();
    });
    trtcVoiceRoom.leaveMic();
    await this.getAnchorList();
    this.setState(() {
      userStatus = UserStatus.Mute;
      userType = UserType.Audience;
    });
  }

  initUserInfo() async {
    String loginUserId = await TxUtils.getLoginUserId();
    Map arguments = ModalRoute.of(context).settings.arguments;
    int _currentRoomId = int.tryParse(arguments['roomId'].toString());
    int _currentRoomOwnerId = int.tryParse(arguments['ownerId'].toString());

    final bool isAdmin =
        _currentRoomOwnerId.toString() == loginUserId ? true : false;
    setState(() {
      currentRoomId = _currentRoomId;
      currentRoomOwnerId = _currentRoomOwnerId;
      userType = isAdmin ? UserType.Administrator : UserType.Audience;
      title = arguments["roomName"] == null ? '--' : arguments["roomName"];
    });

    ActionCallback enterRoomResp =
        await trtcVoiceRoom.enterRoom(_currentRoomId);
    if (enterRoomResp.code == 0) {
      if (isAdmin) {
        setState(() {
          userStatus = UserStatus.Speaking;
        });
        TxUtils.showToast('房主占座成功。', context);
      } else {
        TxUtils.showToast('进房成功', context);
      }
    } else {
      TxUtils.showErrorToast(enterRoomResp.desc, context);
    }
    trtcVoiceRoom.registerListener(onVoiceListener);
    await this.getAnchorList();
    await this.getAudienceList();
  }

  //获取主播列表
  getAnchorList() async {
    try {
      String loginUserId = await TxUtils.getLoginUserId();
      UserListCallback _archorResp = await trtcVoiceRoom.getArchorInfoList();
      if (_archorResp.code == 0) {
        Map<int, UserInfo> _archorList = {};
        _archorResp.list.forEach((item) {
          if (item.userId != null && item.userId != '')
            _archorList[int.tryParse(item.userId)] = item;
        });
        if (userType != UserType.Administrator) {
          setState(() {
            userType = _archorList.containsKey(int.parse(loginUserId))
                ? UserType.Anchor
                : UserType.Audience;
            userStatus = _archorList.containsKey(int.parse(loginUserId))
                ? UserStatus.Speaking
                : UserStatus.Mute;
          });
        }
        setState(() {
          _anchorList = _archorList;
        });
      } else {
        TxUtils.showErrorToast(_archorResp.desc, context);
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
        _memberResp.list.forEach((item) {
          if (item.userId != null && item.userId != '') {
            int userId = int.tryParse(item.userId);
            //非主播
            if (!_anchorList.containsKey(userId)) {
              userList[userId] = item;
            }
          }
        });
        setState(() {
          _audienceList = userList;
        });
      } else {
        TxUtils.showErrorToast(_memberResp.desc, context);
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
        tmpUserId = _lastRaiseHandUser.userId;
      }
    }
    if (tmpUserId != null && tmpUserId != '') {
      trtcVoiceRoom.agreeToSpeak(tmpUserId);
      this._closeTopMessage();
      if (_raiseHandList.containsKey(int.parse(tmpUserId))) {
        this.setState(() {
          _raiseHandList[int.parse(tmpUserId)].isCanAgree = false;
        });
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
        tmpUserId = _lastRaiseHandUser.userId;
      }
    }
    if (tmpUserId != null && tmpUserId != '') {
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
  }

  //音频开关
  handleMuteAudio(bool mute) {
    setState(() {
      userStatus = mute ? UserStatus.Mute : UserStatus.Speaking;
      trtcVoiceRoom.muteLocalAudio(mute);
      trtcVoiceRoom.muteMic(mute);
    });
  }

  //听众举手
  handleRaiseHandClick() {
    trtcVoiceRoom.raiseHand();
    this._showTopMessage("举手成功！等待管理员通过~", false);
    Future.delayed(Duration(seconds: 5), () {
      this._closeTopMessage();
    });
  }

  _showTopMessage(String message, bool showAction) {
    setState(() {
      topMsgVisible = true;
      topMsg = message;
      isShowTopMsgAction = showAction;
    });
  }

  _closeTopMessage() {
    setState(() {
      topMsgVisible = false;
      isShowTopMsgAction = false;
      topMsg = "";
    });
  }

  // 弹出退房确认对话框
  Future<bool> showExitConfirmDialog(fatherContext) {
    return showDialog<bool>(
        context: fatherContext,
        builder: (context) {
          return Theme(
            data: ThemeData.dark(),
            child: CupertinoAlertDialog(
              content: Container(
                child: Text(
                  userType == UserType.Administrator
                      ? "离开会解散房间，确定离开吗?"
                      : "确定离开房间吗？",
                  textAlign: TextAlign.center,
                ),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(
                    "再等等",
                    style: TextStyle(color: Color.fromRGBO(235, 244, 255, 1)),
                  ),
                  onPressed: () {
                    Navigator.of(fatherContext).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: Text(
                    "我确定",
                    style: TextStyle(color: Color.fromRGBO(0, 98, 227, 1)),
                  ),
                  onPressed: () async {
                    if (userType == UserType.Administrator) {
                      await YunApiHelper.destroyRoom(currentRoomId.toString());
                      trtcVoiceRoom.destroyRoom();
                    } else {
                      trtcVoiceRoom.exitRoom();
                    }
                    Navigator.of(fatherContext)
                        .pushReplacementNamed('/voiceRoom/list');
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(title + '的沙龙($currentRoomId)'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios), //color: Colors.black
          onPressed: () async {
            await this.showExitConfirmDialog(context);
          },
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromRGBO(19, 41, 75, 1),
      ),
      body: ConstrainedBox(
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
                    okTitle: '欢迎',
                    cancelTitle: '拒绝',
                    onCancelTab: () {
                      this.handleAdminRefuseToSpeak();
                    },
                    onOkTab: () {
                      this.agreeToSpeackClick();
                    },
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                    child:
                        DescriptionTitle("assets/images/Anchor_ICON.png", "主播"),
                  ),
                  Container(
                    height: _anchorList.length == 0 ? 30 : 140,
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    width: MediaQuery.of(context).size.width,
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 135.0,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 15, //水平间隔
                        childAspectRatio: 1.0,
                      ),
                      children: _anchorList.values.map((UserInfo _anchorItem) {
                        int thisUserId = int.tryParse(_anchorItem.userId);
                        bool isVolumeUpdate =
                            _volumeUpdateList.containsKey(thisUserId)
                                ? _volumeUpdateList[thisUserId]
                                : false;
                        return AnchorItem(
                          roomOwnerId: currentRoomOwnerId,
                          isVolumeUpdate: isVolumeUpdate,
                          userName: _anchorItem.userName != null &&
                                  _anchorItem.userAvatar != ''
                              ? _anchorItem.userName
                              : '--',
                          userImgUrl: _anchorItem.userAvatar != null &&
                                  _anchorItem.userAvatar != ''
                              ? _anchorItem.userAvatar
                              : TxUtils.getRandoAvatarUrl(),
                          isAdministrator:
                              thisUserId == currentRoomOwnerId ? true : false,
                          isMute: _anchorItem.mute,
                          userId: _anchorItem.userId,
                          onKickOutUser: () {
                            //踢人
                            trtcVoiceRoom.kickMic(_anchorItem.userId);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  DescriptionTitle("assets/images/Audience_ICON.png", "听众"),
                  Expanded(
                    flex: 2,
                    child: GridView(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 100.0,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 15,
                        childAspectRatio: 0.9,
                      ),
                      children: _audienceList.values
                          .map((UserInfo _audienceItem) => AudienceItem(
                                userImgUrl: _audienceItem.userAvatar != null &&
                                        _audienceItem.userAvatar != ''
                                    ? _audienceItem.userAvatar
                                    : TxUtils.getRandoAvatarUrl(),
                                userName: _audienceItem.userName != null &&
                                        _audienceItem.userName != ''
                                    ? _audienceItem.userName
                                    : '--',
                              ))
                          .toList(),
                    ),
                  ),
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
                await this.showExitConfirmDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
