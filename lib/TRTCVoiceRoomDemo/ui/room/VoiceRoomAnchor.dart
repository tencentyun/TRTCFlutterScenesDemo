import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  TRTCVoiceRoom trtcVoiceRoom;
  UserStatus userStatus = UserStatus.NoSpeaking;
  String title = "";
  UserType userType = UserType.Administrator;
  bool topMsgVisible = false;
  bool isShowTopMsgAction = false;
  String topMsg = "";

  List<UserInfo> _AnchorList = [];
  List<UserInfo> _AudienceList = [];

  List<String> _HandUpList = [
    '4',
    '5',
    '6',
    '7',
  ];

  @override
  void initState() {
    this.initSDK();
    super.initState();
  }

  initSDK() async {
    trtcVoiceRoom = await TRTCVoiceRoom.sharedInstance();
    this.initUserInfo();
  }

  initUserInfo() async {
    Map arguments = ModalRoute.of(context).settings.arguments;
    setState(() {
      userType = widget.userType;
      title = arguments["roomName"] == null ? '无主题' : arguments["roomName"];
    });
    ActionCallback enterRoomResp =
        await trtcVoiceRoom.enterRoom(arguments['roomId']);
    if (enterRoomResp.code == 0) {
      TxUtils.showToast('进房成功', context);
    } else {
      TxUtils.showToast('进房失败。' + enterRoomResp.desc, context);
    }
    await this.getAnchorList();
    await this.getAudienceList();
  }

  getAnchorList() async {
    try {
      UserListCallback _archorResp = await trtcVoiceRoom.getArchorInfoList();
      if (_archorResp.code == 0) {
        setState(() {
          _AnchorList = _archorResp.list;
        });
      }
    } catch (ex) {
      print(ex);
    }
  }

  getAudienceList() async {
    try {
      MemberListCallback _memberList = await trtcVoiceRoom.getRoomMemberList(0);
      if (_memberList.code == 0) {
        setState(() {
          _AudienceList = _memberList.list;
        });
      }
    } catch (ex) {
      print(ex);
    }
  }

  //管理员同意其成为主播
  onAdminAgree() {}

  //申请为主播
  applyToBeAnchor() {}
  //主播下麦
  anchorDownWheat() {
    print('anchorDownWheat');
  }

  //音频开关
  handleSoundOff(bool isSpeaking) {
    setState(() {
      userStatus = isSpeaking ? UserStatus.NoSpeaking : UserStatus.Speaking;
      //
    });
  }

  //听众举手
  handleHandUpClick() {
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
        return AlertDialog(
          title: Text("提示"),
          content: Text("离开会解散房间，确定离开吗?"),
          actions: <Widget>[
            FlatButton(
              child: Text("再等等"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            FlatButton(
              child: Text("我确定"),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  // 显示举手列表
  handleShowHandList(content) {
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
                                    child: Image.asset(
                                      'assets/images/headPortrait/1.png',
                                      height: 44,
                                    ),
                                  )),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                child: Text(
                                  "name---" + index.toString(),
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
                    childCount: _HandUpList.length,
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
        title: Text(title),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromRGBO(19, 41, 75, 1),
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.topLeft, //指定未定位或部分定位widget的对齐方式
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
                    height: _AnchorList.length == 0 ? 30 : 140,
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    width: MediaQuery.of(context).size.width,
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 135.0,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 15, //水平间隔
                        childAspectRatio: 1.0,
                      ),
                      children:
                          _AnchorList.map((UserInfo _anchorItem) => AnchorItem(
                                userName: _anchorItem.userName != null &&
                                        _anchorItem.userAvatar != ''
                                    ? _anchorItem.userName
                                    : '--',
                                userImgUrl: _anchorItem.userAvatar != null &&
                                        _anchorItem.userAvatar != ''
                                    ? _anchorItem.userAvatar
                                    : 'https://imgcache.qq.com/operation/dianshi/other/7.157d962fa53be4107d6258af6e6d83f33d45fba4.png',
                                isAdministrator:
                                    _anchorItem.userName == '1' ? true : false,
                                isSoundOff: _anchorItem.userAvatar == '1'
                                    ? false
                                    : true,
                                onKickOutUser: () {
                                  //踢人
                                },
                              )).toList(),
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
                      children: _AudienceList.map(
                          (UserInfo _audienceItem) => AudienceItem(
                                userImgUrl: _audienceItem.userAvatar != null &&
                                        _audienceItem.userAvatar != ''
                                    ? _audienceItem.userAvatar
                                    : 'https://imgcache.qq.com/operation/dianshi/other/6.1b984e741cc2275cda3451fa44515e018cc49cb5.png',
                                userName: _audienceItem.userName != null &&
                                        _audienceItem.userName != ''
                                    ? _audienceItem.userName
                                    : '--',
                              )).toList(),
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
              onSoundClick: (value) {
                this.handleSoundOff(value);
              },
              onHandUp: () {
                this.handleHandUpClick();
              },
              onShowHandList: () {
                this.handleShowHandList(context);
              },
              onDownWheat: () {
                //主播下麦
                this.anchorDownWheat();
              },
              onLeave: () async {
                if (userType == UserType.Administrator) {
                  bool isOk = await this.showExitConfirmDialog();
                  if (isOk != null) {
                    Navigator.pop(context);
                  }
                } else {
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
