import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trtc_scenes_demo/TRTCChatSalonDemo/model/TRTCChatSalonDelegate.dart';
import 'package:trtc_scenes_demo/utils/TxUtils.dart';
import '../model/TRTCChatSalon.dart';
import '../model/TRTCChatSalonDef.dart';
import '../../debug/GenerateTestUserSig.dart';
import 'dart:math';

class ChatSalonTest extends StatefulWidget {
  ChatSalonTest({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChatSalonTestState();
}

class ChatSalonTestState extends State<ChatSalonTest> {
  String roomId = '9999';
  loginRoomByCount(userCount) async {
    var trtcVoiceRoom = await TRTCChatSalon.sharedInstance();
    Random rng = new Random();
    int startUserId = rng.nextInt(99);
    for (int i = 0; i < userCount; i++) {
      String userId = startUserId.toString() + i.toString();
      trtcVoiceRoom
          .login(
        GenerateTestUserSig.sdkAppId,
        userId,
        GenerateTestUserSig.genTestSig(userId),
      )
          .then((value) {
        if (value.code == 0) {
          trtcVoiceRoom
              .setSelfProfile(userId, TxUtils.getRandoAvatarUrl())
              .then((value) {
            trtcVoiceRoom.enterRoom(int.tryParse(roomId)).then((value) {
              //sleep(Duration(seconds: 1));
              // trtcVoiceRoom.raiseHand();
              //sleep(Duration(seconds: 3));
              //trtcVoiceRoom.enterMic();
            });
            TxUtils.showErrorToast(userId + '成功进房', context);
          });
        } else {
          print(value.desc);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('Test'),
        ),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                style: TextStyle(color: Colors.red),
                autofocus: false,
                controller: TextEditingController.fromValue(
                  TextEditingValue(
                    text:
                        '${this.roomId == null ? "" : this.roomId}', //判断keyword是否为空
                    selection: TextSelection.fromPosition(
                      TextPosition(
                          affinity: TextAffinity.downstream,
                          offset: '${this.roomId}'.length),
                    ),
                  ),
                ),
                decoration: InputDecoration(
                  labelText: "主题",
                  hintText: "默认房间名称",
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle:
                      TextStyle(color: Color.fromRGBO(255, 255, 255, 0.5)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  roomId = value;
                },
              ),
              RaisedButton(
                onPressed: () async {
                  this.loginRoomByCount(60);
                },
                child: Text('500个观众进入房间'),
              ),
            ],
          ),
        ));
  }
}
