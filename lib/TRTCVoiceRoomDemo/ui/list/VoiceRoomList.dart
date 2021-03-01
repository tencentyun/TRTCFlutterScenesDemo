import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toast/toast.dart';
import 'package:dio/dio.dart';
import '../../../debug/Config.dart';
import '../../../utils/TxUtils.dart';

/*
 * 房间列表
 */
class VoiceRoomListPage extends StatefulWidget {
  VoiceRoomListPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VoiceRoomListPageState();
}

class VoiceRoomListPageState extends State<VoiceRoomListPage> {
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

  getRoomList() {
    Dio dio = new Dio();
    dio.get(
      "https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/forTest",
      queryParameters: {
        "method": "getRoomList",
        "appId": Config.sdkAppId,
        "type": 'voiceRoom'
      },
    ).then((value) {
      var data = value.data;
      print(data);
      List<RoomInfo> roomls = new List<RoomInfo>();
      if (data["errorCode"] == 0) {
        List<dynamic> resList = data["data"] as List<dynamic>;
        for (int i = 0; i < resList.length; i++) {
          dynamic item = resList[i];
          //房间信息
          roomls.add(new RoomInfo(item["id"].toString(), item["roomId"],
              item["title"], "admin1", 1));
          roomls.add(new RoomInfo(item["id"].toString() + '-22',
              item["roomId"] + '-22', item["title"], "admin1", 1));
          roomls.add(new RoomInfo(item["id"].toString() + '-33',
              item["roomId"] + '-33', item["title"], "admin1", 2));
        }
      } else {
        TxUtils.showToast(data['errorMessage'], context);
      }
      setState(() {
        roomInfList = roomls;
      });
    });
  }

  goRoomPage(RoomInfo roomInfo) {
    if (roomInfo.id.indexOf('-22') > 0) {
      Navigator.pushNamed(
        context,
        "/voiceRoom/roomAudience",
        arguments: {
          'roomId': roomInfo.roomId,
        },
      );
      return;
    }
    Navigator.pushNamed(
      context,
      "/voiceRoom/roomAnchor",
      arguments: {
        'roomId': roomInfo.roomId,
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
        color: Color.fromRGBO(14, 25, 44, 1),
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
                          goRoomPage(info);
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              "assets/images/headPortrait/2.png",
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(info.title),
                                  Text(info.adminName),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    info.onLineCount.toString() + '人在线',
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

class RoomInfo {
  String roomId;
  String title;
  String id;
  String adminName;
  int onLineCount;
  RoomInfo(String id, String roomId, String title, String adminName,
      int onLineCount) {
    if (title == null) title = '--';
    if (adminName == null) adminName = '';
    this.id = id;
    this.title = title;
    this.roomId = roomId;
    this.adminName = adminName;
    if (onLineCount == null) onLineCount = 1;
    this.onLineCount = onLineCount;
  }
}
