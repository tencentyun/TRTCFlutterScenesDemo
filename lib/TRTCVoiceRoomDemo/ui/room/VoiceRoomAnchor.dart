import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trtc_scenes_demo/TRTCVoiceRoomDemo/model/TRTCVoiceRoomListener.dart';
import 'package:trtc_scenes_demo/base/YunApiHelper.dart';
import '../../../utils/TxUtils.dart';
import '../widget/RoomBottomBar.dart';
import '../widget/AnchorItem.dart';
import '../widget/AudienceItem.dart';
import '../widget/RoomTopMsg.dart';
import '../widget/DescriptionTitle.dart';
import '../base/UserEnum.dart';
import '../../../TRTCVoiceRoomDemo/model/TRTCVoiceRoom.dart';
import '../../../TRTCVoiceRoomDemo/model/TRTCVoiceRoomDef.dart';

/*
 *  主播界面
 */
class VoiceRoomAnchorPage extends StatefulWidget {
  VoiceRoomAnchorPage(this.userType, {Key key}) : super(key: key);
  final UserType userType;
  @override
  State<StatefulWidget> createState() => VoiceRoomAnchorPageState();
}

class VoiceRoomAnchorPageState extends State<VoiceRoomAnchorPage> {
  int currentRoomId;
  int currentOwnerId;

  TRTCVoiceRoom trtcVoiceRoom;
  UserStatus userStatus = UserStatus.NoSpeaking;
  String title = "";
  UserType userType = UserType.Administrator;
  bool topMsgVisible = false;
  bool isShowTopMsgAction = false;
  String topMsg = "";
  //主播列表
  List<UserInfo> _anchorList = [];
  //听众列表
  List<UserInfo> _audienceList = [];
  //举手列表
  List<UserInfo> _raiseHandListList = [];

  @override
  void initState() {
    super.initState();
    this.initSDK();
  }

  initSDK() async {
    trtcVoiceRoom = await TRTCVoiceRoom.sharedInstance();

    this.initUserInfo();
  }

  initUserInfo() async {
    Map arguments = ModalRoute.of(context).settings.arguments;
    currentRoomId = int.parse(arguments['roomId'].toString());
    currentOwnerId = int.parse(arguments['ownerId'].toString());
    final bool isAdmin =
        currentOwnerId.toString() == TxUtils.getLoginUserId() ? true : false;
    setState(() {
      userType = isAdmin ? UserType.Administrator : UserType.Audience;
      title = arguments["roomName"] == null ? '--' : arguments["roomName"];
    });
    if (isAdmin) {
      this.getRaiseHandList();
    }
    ActionCallback enterRoomResp = await trtcVoiceRoom.enterRoom(currentRoomId);
    if (enterRoomResp.code == 0) {
      if (currentOwnerId.toString() == TxUtils.getLoginUserId()) {
        TxUtils.showToast('该房间是您创建，重新进入中...', context);
      } else {
        TxUtils.showToast('进房成功', context);
      }
    } else {
      TxUtils.showErrorToast(enterRoomResp.desc, context);
    }
    trtcVoiceRoom.registerListener(onVoiceListener);
    //sleep(Duration(seconds: 1));
    await this.getAnchorList();
    await this.getAudienceList();
  }

  onVoiceListener(type, param) {
    TxUtils.showToast(type.toString(), context);
    print("=======type====:" + type.toString());
    print("=======param======:" + param.toString());
    switch (type) {
      case TRTCVoiceRoomListener.onError:
        break;
      case TRTCVoiceRoomListener.onAgreeToSpeak:
        //群主同意举手
        break;
      case TRTCVoiceRoomListener.onRefuseToSpeak:
        //群主拒绝举手
        break;
      case TRTCVoiceRoomListener.onRaiseHand:
        //有观众举手，申请上麦
        this._showTopMessage(param.toString() + "申请成为主播", true);
        break;
      case TRTCVoiceRoomListener.onAudienceEnter:
        //观众进入房间
        break;
      case TRTCVoiceRoomListener.onAnchorLeave:
        {
          //有成员下麦
        }
        break;
      case TRTCVoiceRoomListener.onAgreeToSpeak:
        break;
      case TRTCVoiceRoomListener.onEnterRoom:
        break;
      case TRTCVoiceRoomListener.onExitRoom:
        break;
      case TRTCVoiceRoomListener.onRoomDestroy:
        //房间被销毁，当主播调用destroyRoom后，观众会收到该回调
        break;
    }
  }

  //获取主播列表
  getAnchorList() async {
    try {
      UserListCallback _archorResp = await trtcVoiceRoom.getArchorInfoList();
      if (_archorResp.code == 0) {
        setState(() {
          _anchorList = _archorResp.list;
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
      MemberListCallback _memberList = await trtcVoiceRoom.getRoomMemberList(0);
      if (_memberList.code == 0) {
        setState(() {
          _audienceList = _memberList.list;
        });
      } else {
        TxUtils.showErrorToast(_memberList.desc, context);
      }
    } catch (ex) {
      TxUtils.showErrorToast(ex.toString(), context);
    }
  }

  //获取举手列表
  getRaiseHandList() {}

  //管理员同意其成为主播
  onAdminAgree() {}

  //申请为主播
  applyToBeAnchor() {}

  //主播下麦
  handleAnchorLeaveMic() {
    trtcVoiceRoom.leaveMic();
  }

  //音频开关
  handleMuteAudio(bool isSpeaking) {
    setState(() {
      userStatus = isSpeaking ? UserStatus.NoSpeaking : UserStatus.Speaking;
      trtcVoiceRoom.muteLocalAudio(!isSpeaking);
    });
  }

  //听众举手
  handleRaiseHandClick() {
    trtcVoiceRoom.raiseHand();
    this._showTopMessage("举手成功！等待管理员通过~", false);
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
  Future<bool> showExitConfirmDialog() {
    return showDialog<bool>(
        context: context,
        builder: (context) {
          return Theme(
            data: ThemeData.dark(),
            child: CupertinoAlertDialog(
              content: Expanded(
                child: Container(
                  child: Text(
                    userType == UserType.Administrator
                        ? "离开会解散房间，确定离开吗?"
                        : "确定离开房间吗？",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(
                    "再等等",
                    style: TextStyle(color: Color.fromRGBO(235, 244, 255, 1)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
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
                    Navigator.of(context).pop(true);
                    TxUtils.showToast('退房成功', context);
                  },
                ),
              ],
            ),
          );
        });
  }

  // 显示举手列表
  handleShowRaiseHandList(content) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => Container(
            color: Color.fromRGBO(19, 35, 63, 1),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  leading: Text(''),
                  pinned: true,
                  //expandedHeight: 40.0,
                  backgroundColor: Color.fromRGBO(19, 35, 63, 1),
                  shadowColor: Color.fromRGBO(19, 35, 63, 1),
                  title: Text(
                    '举手列表',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SliverFixedExtentList(
                  itemExtent: 75.0,
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      //创建列表项
                      UserInfo userInfo = _raiseHandListList[index];
                      return Container(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 0,
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(44),
                                    child: Image.network(
                                      userInfo.userAvatar != null &&
                                              userInfo.userAvatar != ''
                                          ? userInfo.userAvatar
                                          : 'https://imgcache.qq.com/operation/dianshi/other/1.724142271f4e811457eee00763e63f454af52d13.png',
                                      height: 44,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  )),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                child: Text(
                                  userInfo.userName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: InkWell(
                                onTap: () {
                                  //同意or拒绝
                                  //userInfo
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Image.asset(
                                    index % 2 == 0
                                        ? "assets/images/after-HandUp.png"
                                        : "assets/images/before-HandUp.png",
                                    height: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: _raiseHandListList.length,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
            bool isOk = await this.showExitConfirmDialog();
            if (isOk != null) {
              Navigator.pop(context);
            }
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
                      this._closeTopMessage();
                    },
                    onOkTab: () {
                      this.onAdminAgree();
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
                      children: _anchorList
                          .map((UserInfo _anchorItem) => AnchorItem(
                                userName: _anchorItem.userName != null &&
                                        _anchorItem.userAvatar != ''
                                    ? _anchorItem.userName
                                    : '--',
                                userImgUrl: _anchorItem.userAvatar != null &&
                                        _anchorItem.userAvatar != ''
                                    ? _anchorItem.userAvatar
                                    : 'https://imgcache.qq.com/operation/dianshi/other/7.157d962fa53be4107d6258af6e6d83f33d45fba4.png',
                                isAdministrator: _anchorItem.userId ==
                                        TxUtils.getLoginUserId()
                                    ? true
                                    : false,
                                isMute: _anchorItem.mute,
                                onKickOutUser: () {
                                  //踢人
                                },
                              ))
                          .toList(),
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
                      children: _audienceList
                          .map((UserInfo _audienceItem) => AudienceItem(
                                userImgUrl: _audienceItem.userAvatar != null &&
                                        _audienceItem.userAvatar != ''
                                    ? _audienceItem.userAvatar
                                    : 'https://imgcache.qq.com/operation/dianshi/other/6.1b984e741cc2275cda3451fa44515e018cc49cb5.png',
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
              onMuteAudio: (value) {
                this.handleMuteAudio(value);
              },
              onRaiseHand: () {
                this.handleRaiseHandClick();
              },
              onShowHandList: () {
                this.handleShowRaiseHandList(context);
              },
              onAnchorLeaveMic: () {
                //主播下麦
                this.handleAnchorLeaveMic();
              },
              onLeave: () async {
                bool isOk = await this.showExitConfirmDialog();
                if (isOk != null) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
