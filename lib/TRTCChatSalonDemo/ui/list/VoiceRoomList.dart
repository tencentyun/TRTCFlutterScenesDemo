import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/TxUtils.dart';
import '../../../TRTCChatSalonDemo/model/TRTCChatSalon.dart';
import '../../../TRTCChatSalonDemo/model/TRTCChatSalonDef.dart';
import '../../../base/YunApiHelper.dart';
import '../../../i10n/localization_intl.dart';

/*
 * 房间列表
 */
class VoiceRoomListPage extends StatefulWidget {
  VoiceRoomListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VoiceRoomListPageState();
}

class VoiceRoomListPageState extends State<VoiceRoomListPage> {
  late TRTCChatSalon trtcVoiceRoom;
  List<RoomInfo> roomInfList = [];
  openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Toast.show(
      //   Languages.of(context)!.errorOpenUrl,
      //   context,
      //   duration: Toast.LENGTH_SHORT,
      //   gravity: Toast.CENTER,
      // );
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
    trtcVoiceRoom = await TRTCChatSalon.sharedInstance();
    var roomIdls = await YunApiHelper.getRoomList();
    print(roomIdls);
    if (roomIdls.isEmpty) {
      print('no room list');
      setState(() {
        roomInfList = [];
      });
      return;
    }
    RoomInfoCallback resp = await trtcVoiceRoom.getRoomInfoList(roomIdls);
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
        "/chatSalon/roomAudience",
        arguments: {
          'roomId': roomInfo.roomId,
          "ownerId": roomInfo.ownerId,
          "roomName": roomInfo.roomName,
          'isNeedCreateRoom': false,
        },
      );
      return;
    }
    Navigator.pushReplacementNamed(
      context,
      "/chatSalon/roomAnchor",
      arguments: {
        "ownerId": roomInfo.ownerId,
        "roomName": roomInfo.roomName,
        'roomId': roomInfo.roomId,
        'isNeedCreateRoom': false,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int roomCount = roomInfList.length;

    return Scaffold(
      appBar: AppBar(
          title: Text(Languages.of(context)!.salonTitle),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios), //color: Colors.black
            onPressed: () async {
              Navigator.pushReplacementNamed(
                context,
                "/index",
              );
            },
          ),
          elevation: 0,
          // automaticallyImplyLeading: false,
          backgroundColor: Color.fromRGBO(14, 25, 44, 1),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.contact_support),
              tooltip: Languages.of(context)!.helpTooltip,
              onPressed: () {
                this.openUrl(
                    'https://cloud.tencent.com/document/product/647/53582');
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
                      Languages.of(context)!.noHadSalon,
                      style: TextStyle(color: Colors.white),
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
                                    : TxUtils.getRandoAvatarUrl(),
                                fit: BoxFit.fitWidth,
                              ),
                              Positioned(
                                left: 10,
                                right: 8,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      constraints:
                                          BoxConstraints(maxWidth: 140),
                                      child: Text(
                                        (info.roomName == null
                                            ? "--"
                                            : info.roomName)!,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
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
                                      (info.ownerName == null
                                          ? "--"
                                          : info.ownerName)!,
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
                                      Languages.of(context)!
                                          .onLineCount(info.memberCount!),
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
                      childCount: roomCount,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.pushReplacementNamed(
            context,
            "/chatSalon/roomCreate",
          )
        },
        tooltip: Languages.of(context)!.createSalonTooltip,
        child: Icon(Icons.add),
      ),
    );
  }
}
