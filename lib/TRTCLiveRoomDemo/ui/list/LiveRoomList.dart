import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trtc_scenes_demo/debug/GenerateTestUserSig.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/TxUtils.dart';
import '../../../TRTCLiveRoomDemo/model/TRTCLiveRoom.dart';
import '../../../TRTCLiveRoomDemo/model/TRTCLiveRoomDef.dart';
import '../../../base/YunApiHelper.dart';
import '../../../i10n/localization_intl.dart';

/*
 * 房间列表
 */
class LiveRoomListPage extends StatefulWidget {
  LiveRoomListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LiveRoomListPageState();
}

class LiveRoomListPageState extends State<LiveRoomListPage> {
  late TRTCLiveRoom trtcLiveRoomServer;
  List<RoomInfo> roomInfList = [];
  openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
        msg: Languages.of(context)!.errorOpenUrl,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    //获取数据
    this.getRoomList();
  }

  @override
  dispose() {
    super.dispose();
  }

  getRoomList() async {
    trtcLiveRoomServer = await TRTCLiveRoom.sharedInstance();
    String loginId = await TxUtils.getLoginUserId();
    await trtcLiveRoomServer.login(
        GenerateTestUserSig.sdkAppId,
        loginId,
        await GenerateTestUserSig.genTestSig(loginId),
        TRTCLiveRoomConfig(useCDNFirst: false));
    var roomIdls = await YunApiHelper.getRoomList(roomType: 'liveRoom');
    if (roomIdls.isEmpty) {
      print('no room list');
      setState(() {
        roomInfList = [];
      });
      return;
    }
    // roomIdls.forEach((element) {
    //   YunApiHelper.destroyRoom(element, roomType: "liveRoom");
    // });
    RoomInfoCallback resp = await trtcLiveRoomServer.getRoomInfos(roomIdls);
    if (resp.code == 0) {
      setState(() {
        roomInfList = resp.list!;
      });
    } else {
      TxUtils.showErrorToast(resp.desc, context);
    }
  }

  goRoomInfoPage(RoomInfo roomInfo) async {
    String loginUserId = await TxUtils.getLoginUserId();
    if (roomInfo.ownerId.toString() == loginUserId) {
      Navigator.pushReplacementNamed(
        context,
        "/liveRoom/roomAnchor",
        arguments: {
          "ownerId": roomInfo.ownerId,
          "roomName": roomInfo.roomName,
          'roomId': roomInfo.roomId,
          'isNeedCreateRoom': false,
        },
      );
      return;
    }
    Navigator.pushReplacementNamed(
      context,
      "/liveRoom/roomAudience",
      arguments: {
        'roomId': roomInfo.roomId,
        "ownerId": roomInfo.ownerId,
        "roomName": roomInfo.roomName,
        'isNeedCreateRoom': false,
      },
    );
  }

  Widget buildRoomInfo(RoomInfo info) {
    return InkWell(
      onTap: () {
        goRoomInfoPage(info);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
                // border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(8)),
                image: DecorationImage(
                  image: NetworkImage(
                    info.coverUrl != null && info.coverUrl != ''
                        ? info.coverUrl
                        : TxUtils.getRandoAvatarUrl(),
                  ),
                  fit: BoxFit.fitWidth,
                )),
          ),
          Positioned(
            left: 10,
            right: 8,
            top: 15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding:
                      EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
                  constraints: BoxConstraints(maxWidth: 140),
                  child: Text(
                    Languages.of(context)!.onLineCount(info.memberCount!),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 35,
            left: 8,
            width: 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (info.ownerName == null ? info.ownerId : info.ownerName)!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
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
                  (info.roomName == null ? "--" : info.roomName)!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int roomCount = roomInfList.length;

    return Scaffold(
      appBar: AppBar(
          title: Text(
            "视频互动",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.black,
            onPressed: () async {
              Navigator.pushReplacementNamed(
                context,
                "/index",
              );
            },
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.contact_support,
                color: Colors.black,
              ),
              tooltip: Languages.of(context)!.helpTooltip,
              onPressed: () {
                this.openUrl(
                    'https://cloud.tencent.com/document/product/647/57388');
              },
            ),
          ]),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacementNamed(
            context,
            "/index",
          );
          return true;
        },
        child: Container(
          child: EasyRefresh(
            header: ClassicalHeader(
              refreshText: Languages.of(context)!.refreshText,
              refreshReadyText: Languages.of(context)!.refreshReadyText,
              refreshingText: Languages.of(context)!.refreshingText,
              refreshedText: Languages.of(context)!.refreshedText,
              showInfo: false,
            ),
            emptyWidget: roomCount <= 0
                ? Center(
                    child: Text(
                      "暂无视频互动直播间",
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                : null,
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
                        return buildRoomInfo(info);
                      },
                      childCount: roomCount,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // bottomNavigationBar: Container(
      //   constraints:
      //       BoxConstraints(maxHeight: 52, maxWidth: 140, minWidth: 140),
      //   width: 140,
      //   child: LiveButton(
      //     onPressed: () {},
      //     size: Size(140, 52),
      //     text: "创建房间",
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.pushReplacementNamed(
            context,
            "/liveRoom/roomCreate",
          )
        },
        tooltip: "创建视频互动房间",
        child: Icon(Icons.add),
      ),
    );
  }
}
