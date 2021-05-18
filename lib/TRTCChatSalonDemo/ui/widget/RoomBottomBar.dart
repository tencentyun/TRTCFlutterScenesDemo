import 'package:flutter/material.dart';
import '../base/UserEnum.dart';
import 'package:trtc_scenes_demo/utils/TxUtils.dart';
import 'package:badges/badges.dart';
import '../../../i10n/localization_intl.dart';

class RaiseHandInfo {
  /// 用户唯一标识
  String userId;

  /// 用户昵称
  String userName;

  /// 用户头像
  String userAvatar;

  //是否可以通过
  bool isCanAgree;

  RaiseHandInfo(
      {this.userId = "",
      this.userName = "",
      this.userAvatar = "",
      this.isCanAgree = false});
}

class RoomBottomBar extends StatefulWidget {
  RoomBottomBar({
    Key? key,
    this.userType = UserType.Audience,
    this.userStatus = UserStatus.Mute,
    this.onLeave,
    this.raiseHandList,
    this.onRaiseHand,
    this.onMuteAudio,
    this.onAnchorLeaveMic,
    this.onAgreeToSpeak,
  }) : super(key: key);
  final UserType userType;
  final UserStatus userStatus;
  final Function? onLeave;
  final List<RaiseHandInfo>? raiseHandList;
  final Function? onRaiseHand;
  final Function? onMuteAudio;
  final Function? onAnchorLeaveMic;
  final Function? onAgreeToSpeak;
  @override
  _RoomBottomBarState createState() => _RoomBottomBarState();
}

class _RoomBottomBarState extends State<RoomBottomBar> {
  bool hadHandUp = false;
  Map<String, bool> hadAgreeMap = {};
  @override
  void initState() {
    super.initState();
  }

  onHandUp() {
    setState(() {
      hadHandUp = true;
    });
    widget.onRaiseHand?.call();
  }

  onMuteAudioClick(bool isMute) {
    widget.onMuteAudio?.call(isMute);
  }

  onShowHandList(raiseHandList) {
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
                  backgroundColor: Color.fromRGBO(19, 35, 63, 1),
                  shadowColor: Color.fromRGBO(19, 35, 63, 1),
                  title: Text(
                    Languages.of(context)!.raiseUpList,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SliverFixedExtentList(
                  itemExtent: 75.0,
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      //创建列表项
                      RaiseHandInfo userInfo = raiseHandList[index];
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
                                  Navigator.pop(context);
                                  if (userInfo.isCanAgree) {
                                    widget.onAgreeToSpeak
                                        ?.call(userInfo.userId);
                                    this.setState(() {
                                      hadAgreeMap[userInfo.userId] = true;
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Image.asset(
                                    hadAgreeMap.containsKey(userInfo.userId)
                                        ? "assets/images/after-HandUp.png"
                                        : userInfo.isCanAgree
                                            ? "assets/images/before-HandUp.png"
                                            : "assets/images/after-HandUp.png",
                                    height: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: raiseHandList.length,
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
    widget.onAnchorLeaveMic?.call();
  }

  onLeave() {
    widget.onLeave?.call();
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
    int validRaiseHandCount = 0;
    if (widget.raiseHandList != null) {
      widget.raiseHandList?.forEach((element) {
        if (element.isCanAgree) validRaiseHandCount = validRaiseHandCount + 1;
      });
    }
    var lastRighttBtn = Positioned(
      right: 10,
      child: Container(
        child: InkWell(
          onTap: () {
            if (UserType.Audience == widget.userType) {
              this.onHandUp();
            } else {
              this.onMuteAudioClick(
                  widget.userStatus == UserStatus.Mute ? false : true);
            }
          },
          child: Image.asset(
            lastBtnUrl,
            width: 48.0,
          ),
        ),
      ),
    );
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
                // ignore: deprecated_member_use
                child: FlatButton(
                  minWidth: 144,
                  color: Color.fromRGBO(0, 98, 227, 1),
                  child: Text(
                    Languages.of(context)!.leaveTips,
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
            lastRighttBtn,
            secondBtnUrl != ""
                ? Positioned(
                    right: 80,
                    child: Container(
                      child: InkWell(
                        onTap: () {
                          if (UserType.Administrator == widget.userType)
                            this.onShowHandList(widget.raiseHandList);
                          else
                            this.anchorLeaveMic();
                        },
                        child: validRaiseHandCount > 0
                            ? Badge(
                                position: BadgePosition.topStart(),
                                badgeContent: Text(
                                  validRaiseHandCount.toString(),
                                ),
                                child: Image.asset(
                                  secondBtnUrl,
                                  width: 48.0,
                                ),
                              )
                            : Image.asset(
                                secondBtnUrl,
                                width: 48.0,
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
