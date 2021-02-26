import 'package:flutter/material.dart';

enum UserType {
  Anchor, //主播
  Administrator, //管理员
  Audience, //听众
}
enum UserStatus {
  Speaking, //讲话中
  NoSpeaking, //静音中
}
enum BootomEvenType {
  LeavingAction,
  SpeakingAction,
  NoSpeakingAction,
}

class RoomBottomBar extends StatefulWidget {
  RoomBottomBar({Key key, this.userType, this.userStatus, this.onTab})
      : super(key: key);
  final UserType userType;
  final UserStatus userStatus;
  final Function onTab;
  @override
  _RoomBottomBarState createState() => _RoomBottomBarState();
}

class _RoomBottomBarState extends State<RoomBottomBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String lastBtnUrl = widget.userStatus == UserStatus.NoSpeaking
        ? "assets/images/no-speaking.png"
        : "assets/images/speaking.png";
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
                    widget.onTab('leave');
                  },
                ),
              ),
            ),
            Positioned(
              right: 10,
              child: Container(
                child: InkWell(
                  onTap: () {
                    widget.onTab('speaking');
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
                          widget.onTab('raiseHandList');
                        },
                        child: Image.asset(
                          secondBtnUrl, //'assets/images/DownWheat.png'
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
