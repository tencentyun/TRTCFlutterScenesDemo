/*
 * 创建房间
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:toast/toast.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../debug/GenerateTestUserSig.dart';
import '../../../TRTCVoiceRoomDemo/model/TRTCVoiceRoom.dart';
import '../../../TRTCVoiceRoomDemo/model/TRTCVoiceRoomDef.dart';

// 多人视频会议首页
class VoiceRoomCreatePage extends StatefulWidget {
  VoiceRoomCreatePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VoiceRoomCreatePageState();
}

class VoiceRoomCreatePageState extends State<VoiceRoomCreatePage> {
  TRTCVoiceRoom trtcVoiceRoom;

  /// 用户id
  String userName = '';

  /// 登录后签名
  String userSig;

  /// 会议id
  String meetTitle = '';

  final meetIdFocusNode = FocusNode();
  final userFocusNode = FocusNode();

  // 提示浮层
  showToast(text) {
    Toast.show(
      text,
      context,
      duration: Toast.LENGTH_SHORT,
      gravity: Toast.CENTER,
    );
  }

  @override
  initState() {
    super.initState();
  }

  // 隐藏底部输入框
  unFocus() {
    if (meetIdFocusNode.hasFocus) {
      meetIdFocusNode.unfocus();
    } else if (userFocusNode.hasFocus) {
      userFocusNode.unfocus();
    }
  }

  @override
  dispose() {
    super.dispose();
    unFocus();
  }

  createVoiceRoom() async {
    if (GenerateTestUserSig.sdkAppId == 0) {
      showToast('请填写SDKAPPID');
      return;
    }
    if (GenerateTestUserSig.secretKey == '') {
      showToast('请填写密钥');
      return;
    }
    meetTitle = meetTitle.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
    if (meetTitle == '') {
      showToast('请输入房间主题');
      return;
    } else if (meetTitle.toString().length > 250) {
      showToast('房间主题过长，请输入合法的房间主题');
      return;
    }
    userName = userName.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
    if (userName == '') {
      showToast('请输入用户ID');
      return;
    } else if (userName.length > 10) {
      showToast('用户名过长，请输入合法的用户名');
      return;
    }
    unFocus();
    if (await Permission.camera.request().isGranted &&
        await Permission.microphone.request().isGranted) {
      String avatarURL =
          "https://imgcache.qq.com/operation/dianshi/other/2.4c958e11852b2caa75da6c2726f9248108d6ec8a.png";
      trtcVoiceRoom = await TRTCVoiceRoom.sharedInstance();
      await trtcVoiceRoom.setSelfProfile(userName, avatarURL);
      ActionCallback resp = await trtcVoiceRoom.createRoom(
        2405,
        RoomParam(coverUrl: avatarURL, roomName: meetTitle),
      );
      if (resp.code == 0) {
        Navigator.pushNamed(context, "/voiceRoom/roomAnchor", arguments: {
          "meetTitle": int.parse(meetTitle),
          "userName": userName,
          "enabledCamera": false,
          "enabledMicrophone": true,
          "quality": TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH
        });
      } else {
        showToast("创建房间失败。" + resp.desc);
      }
    } else {
      showToast('需要获取音视频权限才能进入');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: const Text('创建语聊沙龙'),
        centerTitle: true,
        elevation: 0,
        // automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(19, 41, 75, 1),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (meetIdFocusNode.hasFocus) {
            meetIdFocusNode.unfocus();
          } else if (userFocusNode.hasFocus) {
            userFocusNode.unfocus();
          }
        },
        child: Container(
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
                        autofocus: false,
                        focusNode: meetIdFocusNode,
                        decoration: InputDecoration(
                          labelText: "主题",
                          hintText: "默认房间名称",
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.5)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => meetTitle = value),
                    TextField(
                        style: TextStyle(color: Colors.white),
                        autofocus: false,
                        focusNode: userFocusNode,
                        decoration: InputDecoration(
                          labelText: "用户名",
                          hintText: "默认用户名",
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.5)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) => this.userName = value),
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
                        child: Text("开始交谈"),
                        color: Theme.of(context).primaryColor, //#0062E3;
                        textColor: Colors.white,
                        onPressed: createVoiceRoom,
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
