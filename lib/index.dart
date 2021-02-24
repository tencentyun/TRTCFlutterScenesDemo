import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './utils/TxUtils.dart' as TxUtils;
import 'utils/constants.dart' as constants;

class IndexPage extends StatefulWidget {
  IndexPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> {
  @override
  void initState() {
    super.initState();
    var userObject = TxUtils.getStorageByKey(constants.USERID_KEY);
    userObject.then((value) => {
          if (value == null || value == '')
            {
              Navigator.pushNamed(
                context,
                "/login",
              )
            }
        });
    print('init state:');
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
            // if (delete != null) {
            //   Navigator.pop(context);
            // }
          },
        ),
        title: const Text('TRTC'),
        centerTitle: true,
        elevation: 0,
        // automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(14, 25, 44, 1),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, "/voiceRoom/list");
          },
          child: Container(
            child: Text('go TRTCVoiceRoomDemo'),
          ),
        ),
      ),
    );
  }
}
