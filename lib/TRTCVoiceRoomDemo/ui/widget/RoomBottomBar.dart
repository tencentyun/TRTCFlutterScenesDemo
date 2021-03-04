import 'package:flutter/material.dart';
import '../base/UserEnum.dart';
import 'package:trtc_scenes_demo/TRTCVoiceRoomDemo/model/TRTCChatSalonDef.dart';
import 'package:trtc_scenes_demo/utils/TxUtils.dart';
import 'package:badges/badges.dart';

class RoomBottomBar extends StatefulWidget {
  RoomBottomBar({
    Key key,
    this.userType,
    this.userStatus,
    this.onLeave,
    this.raiseHandList,
    this.onRaiseHand,
    this.onMuteAudio,
    this.onAnchorLeaveMic,
  }) : super(key: key);
  final UserType userType;
  final UserStatus userStatus;
  final Function onLeave;
  final List<UserInfo> raiseHandList;
  final Function onRaiseHand;
  final Function onMuteAudio;
  final Function onAnchorLeaveMic;
  @override
  _RoomBottomBarState createState() => _RoomBottomBarState();
}

class _RoomBottomBarState extends State<RoomBottomBar> {
  bool hadHandUp = false;
  @override
  void initState() {
    super.initState();
  }

  onHandUp() {
    setState(() {
      hadHandUp = true;
    });
    widget.onRaiseHand();
  }

  onSoundClick(bool isSpeaking) {
    widget.onMuteAudio(isSpeaking);
  }

  onShowHandList() {
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
                      UserInfo userInfo = widget.raiseHandList[index];
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
                                          : TxUtils.getRandoAvatarUrl(),
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
                    childCount: widget.raiseHandList.length,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  anchorLeaveMic() {
    widget.onAnchorLeaveMic();
  }

  onLeave() {
    widget.onLeave();
  }

  @override
  Widget build(BuildContext context) {
    String lastBtnUrl = "assets/images/no-speaking.png";
    if (UserType.Audience == widget.userType) {
      lastBtnUrl = hadHandUp
          ? "assets/images/raiseHand.png"
          : "assets/images/noRaiseHand.png";
    } else {
      lastBtnUrl = widget.userStatus == UserStatus.Mute
          ? "assets/images/no-speaking.png"
          : "assets/images/speaking.png";
    }

    String secondBtnUrl = widget.userType == UserType.Administrator
        ? "assets/images/raiseHandList.png"
        : widget.userType == UserType.Anchor
            ? "assets/images/DownWheat.png"
            : "";
    return Positioned(
        bottom: 10,
        left: 0,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.topLeft,
          children: <Widget>[
            Container(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: FlatButton(
                  minWidth: 144,
                  color: Color.fromRGBO(0, 98, 227, 1),
                  child: Text(
                    "安静离开~",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    this.onLeave();
                  },
                ),
              ),
            ),
            Positioned(
              right: 10,
              child: Container(
                child: InkWell(
                  onTap: () {
                    if (UserType.Audience == widget.userType) {
                      this.onHandUp();
                    } else {
                      this.onSoundClick(
                          widget.userStatus == UserStatus.Mute ? false : true);
                    }
                  },
                  child: Image.asset(
                    lastBtnUrl,
                    width: 48.0,
                  ),
                ),
              ),
            ),
            secondBtnUrl != ""
                ? Positioned(
                    right: 80,
                    child: Container(
                      child: InkWell(
                        onTap: () {
                          if (UserType.Administrator == widget.userType)
                            this.onShowHandList();
                          else
                            this.anchorLeaveMic();
                        },
                        child: Badge(
                          position: BadgePosition.topStart(),
                          badgeContent: Text(widget.raiseHandList.length > 0
                              ? widget.raiseHandList.length.toString()
                              : ""),
                          child: Image.asset(
                            secondBtnUrl,
                            width: 48.0,
                          ),
                        ),
                      ),
                    ),
                  )
                : Positioned(
                    right: 80,
                    child: Container(),
                  ),
          ],
        ));
  }
}
