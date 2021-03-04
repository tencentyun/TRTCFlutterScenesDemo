import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/TxUtils.dart';
import '../utils/constants.dart' as constants;
import '../debug/GenerateTestUserSig.dart';
import '../TRTCVoiceRoomDemo/model/TRTCChatSalon.dart';
import '../TRTCVoiceRoomDemo/model/TRTCChatSalonDef.dart';

/*
 *  登录界面
 */
class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  TRTCChatSalon trtcVoiceRoom;

  final userFocusNode = FocusNode();

  /// 用户id
  String userId = '';

  login(context) async {
    if (userId == '') {
      TxUtils.showErrorToast('请输入用户名', context);
      return;
    }
    trtcVoiceRoom = await TRTCChatSalon.sharedInstance();

    ActionCallback resValue = await trtcVoiceRoom.login(
      GenerateTestUserSig.sdkAppId,
      userId,
      GenerateTestUserSig.genTestSig(userId),
    );

    await trtcVoiceRoom.setSelfProfile(
        'ID:' + userId, constants.DEFAULT_ROOM_IMAGE);
    if (resValue.code == 0) {
      TxUtils.showToast('登录成功', context);
      TxUtils.setStorageByKey(constants.USERID_KEY, userId);
      Navigator.pushNamed(
        context,
        "/index",
        arguments: {
          "userId": userId,
        },
      );
    } else {
      TxUtils.showErrorToast(resValue.desc, context);
    }
  }

// 隐藏底部输入框
  unFocus() {
    if (userFocusNode.hasFocus) {
      userFocusNode.unfocus();
    }
  }

  @override
  dispose() {
    super.dispose();
    unFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('腾讯云TRTC'),
        centerTitle: true,
        elevation: 0,
        // automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(14, 25, 44, 1),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (userFocusNode.hasFocus) {
            userFocusNode.unfocus();
          }
        },
        child: Container(
          color: Color.fromRGBO(14, 25, 44, 1),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: <Widget>[
              Container(
                color: Color.fromRGBO(13, 44, 91, 1),
                margin: const EdgeInsets.only(top: 60.0),
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Column(
                  children: [
                    TextField(
                        style: TextStyle(color: Colors.white),
                        autofocus: true,
                        focusNode: userFocusNode,
                        decoration: InputDecoration(
                          labelText: "用户名",
                          hintText: "请输入登录的UserID",
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.5)),
                          //border: InputBorder.none,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) => this.userId = value),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        padding: EdgeInsets.all(15.0),
                        child: Text("登录"),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () => login(context),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
