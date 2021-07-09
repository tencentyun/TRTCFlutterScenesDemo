import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './utils/TxUtils.dart';
// import 'base/DemoSevice.dart';
import 'utils/constants.dart' as constants;
import './debug/GenerateTestUserSig.dart';
import './TRTCChatSalonDemo/model/TRTCChatSalon.dart';
import './i10n/localization_intl.dart';

class IndexPage extends StatefulWidget {
  IndexPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> {
  late TRTCChatSalon trtcVoiceRoom;
  @override
  void initState() {
    super.initState();
    this.initSDK();
  }

  initSDK() async {
    trtcVoiceRoom = await TRTCChatSalon.sharedInstance();
    String userId = await TxUtils.getStorageByKey(constants.USERID_KEY);
    if (userId == '') {
      await Navigator.popAndPushNamed(
        context,
        "/login",
      );
    } else {
      TxUtils.setStorageByKey(constants.USERID_KEY, userId);

      await trtcVoiceRoom.login(
        GenerateTestUserSig.sdkAppId,
        userId,
        GenerateTestUserSig.genTestSig(userId),
      );
    }
    // DemoSevice.sharedInstance().start();
  }

  Future<bool?>? logout() {
    var showDialog2 = showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(Languages.of(context)!.tipsText),
          content: Text(Languages.of(context)!.logoutContent),
          actions: <Widget>[
            // ignore: deprecated_member_use
            FlatButton(
              child: Text(Languages.of(context)!.cancelText),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            // ignore: deprecated_member_use
            FlatButton(
              child: Text(Languages.of(context)!.okText),
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
    return showDialog2;
  }

  goVoiceRoomDemo() {
    Navigator.pushReplacementNamed(
      context,
      "/chatSalon/list",
    );
  }

  goCallingDemo(isVideo) {
    Navigator.pushReplacementNamed(
      context,
      isVideo ? "/calling/videoContact" : "/calling/audioContact",
    );
  }

  goLiveRoomDemo() {
    Navigator.pushReplacementNamed(
      context,
      "/liveRoom/list",
    );
  }

  goMeetingDemo() {
    Navigator.pushReplacementNamed(
      context,
      "/meeting/meetingIndex",
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
          tooltip: Languages.of(context)!.logout,
          onPressed: () async {
            await logout();
          },
        ),
        title: Text(Languages.of(context)!.trtc),
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
        padding: EdgeInsets.only(top: 180, left: 20, right: 20),
        child: GridView(
          padding: EdgeInsets.only(bottom: 20),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 30, crossAxisSpacing: 30),
          children: <Widget>[
            this.getTitleItem(
              Languages.of(context)!.salonTitle,
              "assets/images/ChatSalon.png",
              () {
                goVoiceRoomDemo();
              },
            ),
            this.getTitleItem(
              "视频通话",
              "assets/images/callingDemo/videoCall.png",
              () {
                goCallingDemo(true);
              },
            ),
            this.getTitleItem(
              "语音通话",
              "assets/images/callingDemo/audioCall.png",
              () {
                goCallingDemo(false);
              },
            ),
            this.getTitleItem(
              "视频互动",
              "assets/images/callingDemo/videoCall.png",
              () {
                goLiveRoomDemo();
              },
            ),
            this.getTitleItem(
              Languages.of(context)!.meetingCallTitle,
              "assets/images/callingDemo/meetingCall.png",
              () {
                goMeetingDemo();
              },
            ),
          ],
        ),
      ),
    );
  }
}
