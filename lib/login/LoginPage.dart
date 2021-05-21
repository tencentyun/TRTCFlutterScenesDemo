import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/TxUtils.dart';
import '../utils/constants.dart' as constants;
import '../debug/GenerateTestUserSig.dart';
import '../TRTCChatSalonDemo/model/TRTCChatSalon.dart';
import '../TRTCChatSalonDemo/model/TRTCChatSalonDef.dart';
import '../i10n/localization_intl.dart';

/*
 *  登录界面
 */
class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  late TRTCChatSalon trtcVoiceRoom;

  final userFocusNode = FocusNode();

  /// 用户id
  String userId = '';

  login(context) async {
    if ((await Permission.camera.request().isGranted &&
        await Permission.microphone.request().isGranted)) {
    } else {
      TxUtils.showErrorToast('需要获取音视频权限才能进入', context);
      return;
    }
    if (userId == '') {
      TxUtils.showErrorToast(Languages.of(context)!.errorUserIDInput, context);
      return;
    }
    if (double.tryParse(userId) == null) {
      TxUtils.showErrorToast(Languages.of(context)!.errorUserIDNumber, context);
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
      TxUtils.showToast(Languages.of(context)!.successLogin, context);
      TxUtils.setStorageByKey(constants.USERID_KEY, userId);
      Navigator.pushNamed(context, "/index");
    } else {
      TxUtils.showErrorToast('setSelfProfile:' + resValue.desc, context);
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(Languages.of(context)!.tencentTRTC),
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
                          labelText: Languages.of(context)!.userIDLabel,
                          hintText: Languages.of(context)!.userIDHintText,
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.5)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        keyboardType: TextInputType.number,
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
                        child: Text(Languages.of(context)!.login),
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
