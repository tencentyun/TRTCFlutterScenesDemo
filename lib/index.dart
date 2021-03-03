import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './utils/TxUtils.dart';
import 'utils/constants.dart' as constants;
import './base/TestFlowDelegate.dart';
import './debug/GenerateTestUserSig.dart';
import './TRTCVoiceRoomDemo/model/TRTCVoiceRoom.dart';

class IndexPage extends StatefulWidget {
  IndexPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> {
  TRTCVoiceRoom trtcVoiceRoom;
  @override
  void initState() {
    TRTCVoiceRoom.sharedInstance().then((value) {
      trtcVoiceRoom = value;
    });
    super.initState();
    TRTCVoiceRoom.sharedInstance().then((trtcVoiceRoomObj) async {
      trtcVoiceRoom = trtcVoiceRoomObj;
      String userId = await TxUtils.getStorageByKey(constants.USERID_KEY);
      if (userId == null || userId == '') {
        Navigator.pushNamed(
          context,
          "/login",
        );
      } else {
        TxUtils.setStorageByKey(constants.USERID_KEY, userId);
        trtcVoiceRoom.login(
          GenerateTestUserSig.sdkAppId,
          userId,
          GenerateTestUserSig.genTestSig(userId),
        );
      }
    });
  }

  Future<bool> logout() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("提示"),
          content: Text("确定退出登录吗?"),
          actions: <Widget>[
            FlatButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            FlatButton(
              child: Text("确定"),
              onPressed: () {
                //关闭对话框并返回true
                trtcVoiceRoom.logout();
                TxUtils.setStorageByKey(constants.USERID_KEY, '');
                Navigator.pushNamed(
                  context,
                  "/login",
                );
              },
            ),
          ],
        );
      },
    );
  }

  goVoiceRoomDemo() {
    Navigator.pushNamed(
      context,
      "/voiceRoom/list",
      arguments: {
        "userId": 'test',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.person),
          tooltip: '退出',
          onPressed: () async {
            await logout();
          },
        ),
        title: const Text('TRTC'),
        centerTitle: true,
        elevation: 0,
        // automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(14, 25, 44, 1),
      ),
      body: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.asset("assets/images/bg_main_title.png"),
            Flow(
              delegate: TestFlowDelegate(margin: EdgeInsets.all(10.0)),
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    width: 550.0,
                    height: 80.0,
                    alignment: Alignment.center,
                    child: Text('语音聊天室'),
                    color: Colors.white,
                  ),
                  onTap: () {
                    goVoiceRoomDemo();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
