import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toast/toast.dart';
import 'package:dio/dio.dart';
import '../../../debug/Config.dart';
import '../../../utils/TxUtils.dart';
import '../../../debug/GenerateTestUserSig.dart';
import '../../../TRTCVoiceRoomDemo/model/TRTCVoiceRoom.dart';
import '../../../TRTCVoiceRoomDemo/model/TRTCVoiceRoomDef.dart';

/*
 * 房间列表
 */
class VoiceRoomListPage extends StatefulWidget {
  VoiceRoomListPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VoiceRoomListPageState();
}

class VoiceRoomListPageState extends State<VoiceRoomListPage> {
  TRTCVoiceRoom trtcVoiceRoom;
  List<RoomInfo> roomInfList = new List<RoomInfo>();
  openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Toast.show(
        "打开地址失败",
        context,
        duration: Toast.LENGTH_SHORT,
        gravity: Toast.CENTER,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    //获取数据
    this.getRoomList();
  }

  getRoomList() async {
    trtcVoiceRoom = await TRTCVoiceRoom.sharedInstance();

    Dio dio = new Dio();
    dio.get(
      "https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/forTest",
      queryParameters: {
        "method": "getRoomList",
        "appId": Config.sdkAppId,
        "type": 'voiceRoom'
      },
    ).then((value) async {
      var data = value.data;
      List<String> roomIdls = new List<String>();
      if (data["errorCode"] == 0) {
        List<dynamic> resList = data["data"] as List<dynamic>;
        for (int i = 0; i < resList.length; i++) {
          dynamic item = resList[i];
          roomIdls.add(item["roomId"]);
        }
      } else {
        TxUtils.showErrorToast(data['errorMessage'], context);
      }
      if (roomIdls.isEmpty) {
        print('no room list');
        return;
      }
      RoomInfoCallback resp = await trtcVoiceRoom.getRoomInfoList(roomIdls);
      if (resp.code == 0) {
        setState(() {
          roomInfList = resp.list;
        });
      } else {
        TxUtils.showErrorToast(resp.desc, context);
      }
    });
  }

  goRoomInfoPage(RoomInfo roomInfo) {
    if (roomInfo.roomId.toString() == TxUtils.getLoginUserId()) {
      Navigator.pushNamed(
        context,
        "/voiceRoom/roomAudience",
        arguments: {
          'roomId': roomInfo.roomId,
          "ownerId": roomInfo.ownerId,
          "roomName": roomInfo.roomName,
          'isAdmin': true,
        },
      );
      return;
    }
    Navigator.pushNamed(
      context,
      "/voiceRoom/roomAnchor",
      arguments: {
        "ownerId": roomInfo.ownerId,
        "roomName": roomInfo.roomName,
        'roomId': roomInfo.roomId,
        'isAdmin': false,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
          title: const Text('语音聊天室'),
          centerTitle: true,
          elevation: 0,
          // automaticallyImplyLeading: false,
          backgroundColor: Color.fromRGBO(14, 25, 44, 1),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.contact_support),
              tooltip: '查看说明文档',
              onPressed: () {
                this.openUrl(
                    'https://cloud.tencent.com/document/product/647/35428');
              },
            ),
          ]),
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
        child: EasyRefresh(
          onRefresh: () async {
            print('onRefresh');
            getRoomList();
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 8.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, //Grid按两列显示
                    mainAxisSpacing: 20.0,
                    crossAxisSpacing: 20.0,
                    childAspectRatio: 1.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      RoomInfo info = roomInfList[index];
                      //创建子widget
                      return InkWell(
                        onTap: () {
                          goRoomInfoPage(info);
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              info.coverUrl != null && info.coverUrl != ''
                                  ? info.coverUrl
                                  : "https://imgcache.qq.com/operation/dianshi/other/5.ca48acfebc4dfb68c6c463c9f33e60cb8d7c9565.png",
                            ),
                            Positioned(
                              left: 10,
                              right: 8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    info.roomName == null
                                        ? "无主题"
                                        : info.roomName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 8,
                              width: 90,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    info.ownerName == null
                                        ? "--"
                                        : info.ownerName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    info.memberCount.toString() + '人在线',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    childCount: roomInfList.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.pushNamed(
            context,
            "/voiceRoom/roomCreate",
          )
        },
        tooltip: '创建语音聊天室',
        child: Icon(Icons.add),
      ),
    );
  }
}
