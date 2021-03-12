import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './utils/TxUtils.dart';
import 'utils/constants.dart' as constants;
import './debug/GenerateTestUserSig.dart';
import './TRTCChatSalonDemo/model/TRTCChatSalon.dart';
import './i10n/localization_intl.dart';

class IndexPage extends StatefulWidget {
  IndexPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> {
  TRTCChatSalon trtcVoiceRoom;
  @override
  void initState() {
    super.initState();
    this.initSDK();
  }

  initSDK() async {
    trtcVoiceRoom = await TRTCChatSalon.sharedInstance();
    String userId = await TxUtils.getStorageByKey(constants.USERID_KEY);
    if (userId == null || userId == '') {
      Navigator.popAndPushNamed(
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
  }

  Future<bool> logout() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(Languages.of(context).tipsText),
          content: Text(Languages.of(context).logoutContent),
          actions: <Widget>[
            FlatButton(
              child: Text(Languages.of(context).cancelText),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            FlatButton(
              child: Text(Languages.of(context).okText),
              onPressed: () {
                //关闭对话框并返回true
                trtcVoiceRoom.logout();
                //TRTCChatSalon.destroySharedInstance();
                TxUtils.setStorageByKey(constants.USERID_KEY, '');
                Navigator.popAndPushNamed(
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
    Navigator.pushReplacementNamed(
      context,
      "/chatSalon/list",
    );
  }

  Widget getTitleItem(String title, String imgUrl, Function onTap) {
    var titleItem = Container(
      height: 80.0,
      color: Color.fromRGBO(30, 57, 103, 1),
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  onTap();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      imgUrl,
                      height: 44,
                      width: 44,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
    return titleItem;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.person),
          tooltip: Languages.of(context).logout,
          onPressed: () async {
            await logout();
          },
        ),
        title: Text(Languages.of(context).trtc),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromRGBO(14, 25, 44, 1),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage(
              "assets/images/bg_main_title.png",
            ),
            alignment: Alignment.topCenter,
          ),
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
        padding: EdgeInsets.only(top: 150, left: 20, right: 20),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 30, crossAxisSpacing: 30),
          children: <Widget>[
            this.getTitleItem(
                Languages.of(context).salonTitle, "assets/images/ChatSalon.png",
                () {
              goVoiceRoomDemo();
            })
          ],
        ),
      ),
    );
  }
}
