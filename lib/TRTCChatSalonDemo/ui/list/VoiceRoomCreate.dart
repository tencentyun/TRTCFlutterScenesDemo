/*
 * 创建房间
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../utils/TxUtils.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../debug/GenerateTestUserSig.dart';
import '../../../TRTCChatSalonDemo/model/TRTCChatSalon.dart';

// 多人视频会议首页
class VoiceRoomCreatePage extends StatefulWidget {
  VoiceRoomCreatePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VoiceRoomCreatePageState();
}

class VoiceRoomCreatePageState extends State<VoiceRoomCreatePage> {
  TRTCChatSalon trtcVoiceRoom;

  /// 用户id
  String userName = 'xx';

  /// 登录后签名
  String userSig;

  /// 会议id
  String meetTitle = 'xx的主题';

  final meetIdFocusNode = FocusNode();
  final userFocusNode = FocusNode();

  @override
  initState() {
    this.initSDK();
    super.initState();
  }

  initSDK() async {
    trtcVoiceRoom = await TRTCChatSalon.sharedInstance();
    String userId = await TxUtils.getLoginUserId();
    String loginUserName = await TxUtils.getStorageByKey("loginUserName");
    setState(() {
      userName = (loginUserName != null && loginUserName != "")
          ? loginUserName
          : 'id-$userId';
      meetTitle = '$userName的主题';
    });
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

  _isVerifyInputOk() {
    if (GenerateTestUserSig.sdkAppId == 0) {
      TxUtils.showErrorToast('请填写SDKAPPID', context);
      return false;
    }
    if (GenerateTestUserSig.secretKey == '') {
      TxUtils.showErrorToast('请填写密钥', context);
      return false;
    }
    meetTitle = meetTitle.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
    if (meetTitle == '') {
      TxUtils.showErrorToast('请输入房间主题', context);
      return false;
    } else if (meetTitle.toString().length > 250) {
      TxUtils.showErrorToast('房间主题过长，请输入合法的房间主题', context);
      return false;
    }
    userName = userName.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
    if (userName == '') {
      TxUtils.showErrorToast('请输入用户名', context);
      return false;
    } else if (userName.length > 10) {
      TxUtils.showErrorToast('用户名过长，请输入合法的用户名', context);
      return false;
    }
    return true;
  }

  createVoiceRoom() async {
    if (!_isVerifyInputOk()) return;
    unFocus();
    int roomId = TxUtils.getRandomNumber();
    String _avatarUrl = TxUtils.getRandoAvatarUrl();
    if (await Permission.microphone.request().isGranted) {
      try {
        await trtcVoiceRoom.setSelfProfile(
          userName,
          _avatarUrl,
        );
        await TxUtils.setStorageByKey("loginUserName", userName);
        String ownerId = await TxUtils.getLoginUserId();
        Navigator.popAndPushNamed(
          context,
          "/chatSalon/roomAnchor",
          arguments: {
            "coverUrl": _avatarUrl,
            "roomName": meetTitle,
            "roomId": roomId,
            "ownerId": ownerId,
            'isNeedCreateRoom': true,
          },
        );
      } catch (ex) {
        TxUtils.showErrorToast(ex.toString(), context);
      }
    } else {
      TxUtils.showErrorToast('需要获取音视频权限才能进入', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建语音沙龙'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios), //color: Colors.black
          onPressed: () async {
            Navigator.pushReplacementNamed(
              context,
              "/chatSalon/list",
            );
          },
        ),
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
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text:
                                '${this.meetTitle == null ? "" : this.meetTitle}', //判断keyword是否为空
                            selection: TextSelection.fromPosition(
                              TextPosition(
                                  affinity: TextAffinity.downstream,
                                  offset: '${this.meetTitle}'.length),
                            ),
                          ),
                        ),
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
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text:
                                '${this.userName == null ? "" : this.userName}', //判断keyword是否为空
                            selection: TextSelection.fromPosition(
                              TextPosition(
                                  affinity: TextAffinity.downstream,
                                  offset: '${this.userName}'.length),
                            ),
                          ),
                        ),
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
