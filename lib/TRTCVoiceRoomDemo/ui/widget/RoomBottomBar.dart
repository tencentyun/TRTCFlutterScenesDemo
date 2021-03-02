import 'package:flutter/material.dart';
import '../base/UserEnum.dart';

enum BootomEvenType {
  LeavingAction,
  SpeakingAction,
  NoSpeakingAction,
}

class RoomBottomBar extends StatefulWidget {
  RoomBottomBar({
    Key key,
    this.userType,
    this.userStatus,
    this.onLeave,
    this.onHandUp,
    this.onShowHandList,
    this.onSoundClick,
    this.onDownWheat,
  }) : super(key: key);
  final UserType userType;
  final UserStatus userStatus;
  final Function onLeave;
  final Function onHandUp;
  final Function onShowHandList;
  final Function onSoundClick;
  final Function onDownWheat;
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
    widget.onHandUp();
  }

  onSoundClick(bool isSpeaking) {
    widget.onSoundClick(isSpeaking);
  }

  onShowHandList() {
    widget.onShowHandList();
  }

  onDownWheat() {
    widget.onDownWheat();
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
      lastBtnUrl = widget.userStatus == UserStatus.NoSpeaking
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
                          widget.userStatus == UserStatus.NoSpeaking
                              ? false
                              : true);
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
                            this.onDownWheat();
                        },
                        child: Image.asset(
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
