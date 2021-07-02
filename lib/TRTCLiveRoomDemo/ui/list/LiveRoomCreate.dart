/*
 * 创建房间
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:tencent_trtc_cloud/tx_beauty_manager.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/model/TRTCLiveRoom.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/ui/base/FilterSetting.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/ui/base/LiveTextButton.dart';
import '../../../utils/TxUtils.dart';

class LiveRoomCreatePage extends StatefulWidget {
  const LiveRoomCreatePage({Key? key}) : super(key: key);

  @override
  _LiveRoomCreatePageState createState() => _LiveRoomCreatePageState();
}

class _LiveRoomCreatePageState extends State<LiveRoomCreatePage> {
  late TRTCLiveRoom? trtcCloud;
  late TXBeautyManager beautyManager;
  String roomTitle = "test的房间";
  String userName = "test";
  bool isStandardQuality = true;
  bool isShowFilterSetting = false;
  bool isFrontCamera = true;
  @override
  void initState() {
    initTrtc();
    super.initState();
    initRoomInfo();
  }

  initTrtc() async {
    trtcCloud = await TRTCLiveRoom.sharedInstance();
    beautyManager = trtcCloud!.getBeautyManager();
    FilterSettingWidget.initBeautyValue.forEach((curBeauty, value) {
      this.onBeautyValueChange(curBeauty, value);
    });
  }

  onBeautyValueChange(String curBeauty, double value) {
    if (curBeauty == 'smooth' || curBeauty == 'nature' || curBeauty == 'pitu') {
      if ('smooth' == curBeauty) {
        beautyManager.setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_SMOOTH);
      } else if ('nature' == curBeauty) {
        beautyManager.setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_NATURE);
      } else if ('pitu' == curBeauty) {
        beautyManager.setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_PITU);
      }
      beautyManager.setBeautyLevel(value.round());
    } else if (curBeauty == 'whitening') {
      beautyManager.setWhitenessLevel(value.round());
    } else if (curBeauty == 'ruddy') {
      beautyManager.setRuddyLevel(value.round());
    }
  }

  initRoomInfo() async {
    String userId = await TxUtils.getLoginUserId();
    String loginUserName = await TxUtils.getStorageByKey("loginUserName");
    String tmpName = loginUserName == ""
        ? userId == ""
            ? "test"
            : userId.replaceAll("：", "")
        : loginUserName.replaceAll("：", "");
    setState(() {
      userName = tmpName;
      roomTitle = tmpName + "的房间";
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  goLiveRoomPage() async {
    int roomId = TxUtils.getRandomNumber();
    String ownerId = await TxUtils.getLoginUserId();
    trtcCloud!.stopCameraPreview().then((value) {
      Navigator.pushReplacementNamed(
        context,
        "/liveRoom/roomAnchor",
        arguments: {
          "ownerId": ownerId,
          "roomName": roomTitle,
          'roomId': roomId,
          'isNeedCreateRoom': true,
          "isStandardQuality": isStandardQuality,
        },
      );
    });
  }

  Widget getCreateRoomCard() {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: new BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.5),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(
                'https://imgcache.qq.com/operation/dianshi/other/5.ca48acfebc4dfb68c6c463c9f33e60cb8d7c9565.png',
              ),
            ),
            title: Text(
              this.userName,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            subtitle: TextField(
              autofocus: true,
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: this.roomTitle, //判断keyword是否为空
                  selection: TextSelection.fromPosition(
                    TextPosition(
                        affinity: TextAffinity.downstream,
                        offset: this.roomTitle.length),
                  ),
                ),
              ),
              style: TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                this.roomTitle = value;
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Divider(
              color: Colors.white,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  '音质',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: ButtonBar(
                    children: [
                      LiveTextButton(
                        text: '标准',
                        textStyle: isStandardQuality
                            ? null
                            : TextStyle(color: Color(0xff333333), fontSize: 14),
                        backgroundColor:
                            isStandardQuality ? null : Color(0xFFF4F5F9),
                        onPressed: () {
                          setState(() {
                            isStandardQuality = true;
                          });
                        },
                      ),
                      LiveTextButton(
                        text: '音乐',
                        backgroundColor:
                            isStandardQuality ? Color(0xFFF4F5F9) : null,
                        textStyle: isStandardQuality
                            ? TextStyle(color: Color(0xff333333), fontSize: 14)
                            : null,
                        onPressed: () {
                          setState(() {
                            isStandardQuality = false;
                          });
                        },
                      ),
                    ],
                  ))
            ],
          ),
        ],
      ),
    );
  }

  //切换摄像头
  onCameraSwitchTap() {
    setState(() {
      isFrontCamera = !isFrontCamera;
      trtcCloud!.switchCamera(isFrontCamera);
    });
  }

  //滤镜
  onFilterSettingTap() {
    setState(() {
      isShowFilterSetting = true;
      if (isShowFilterSetting) {
        showModalBottomSheet<void>(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          builder: (BuildContext context) {
            return FilterSettingWidget(
              onChanged: (String key, double value) {},
              onClose: () {
                setState(() {
                  isShowFilterSetting = false;
                });
                Navigator.of(context).pop(true);
              },
            );
          },
        );
      }
    });
  }

  Widget getBottomBtnList() {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            //color: Colors.black,
            margin: EdgeInsets.only(left: 30),
            child: InkWell(
              onTap: () {
                onCameraSwitchTap();
              },
              child: Image.asset(
                "assets/images/liveRoom/CameraSwitch.png",
                height: 52,
                width: 52,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              constraints:
                  BoxConstraints(maxHeight: 52, maxWidth: 148, minWidth: 148),
              width: 148,
              padding: EdgeInsets.only(left: 30, right: 30),
              child: LiveTextButton(
                text: '开始直播',
                radius: 28,
                textStyle: TextStyle(color: Color(0xFFFFFFFF), fontSize: 18),
                backgroundColor: Color(0xFF006EFF),
                size: Size(148, 52),
                onPressed: () {
                  goLiveRoomPage();
                },
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 30),
            child: InkWell(
              onTap: () {
                onFilterSettingTap();
              },
              child: Image.asset(
                "assets/images/liveRoom/Filter.png",
                height: 52,
                width: 52,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Color.fromRGBO(0, 0, 0, 0.2),
            child: TRTCCloudVideoView(
              key: ValueKey("LiveRoomCreatePage_bigVideoViewId"),
              viewType: TRTCCloudDef.TRTC_VideoView_SurfaceView,
              onViewCreated: (viewId) async {
                trtcCloud!.startCameraPreview(isFrontCamera, viewId);
              },
            ),
          ),
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: getCreateRoomCard(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: getBottomBtnList(),
          ),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  "/liveRoom/list",
                );
              },
              child: Container(
                margin: EdgeInsets.only(top: 58, right: 30),
                child: Image.asset(
                  'assets/images/liveRoom/closeRoom.png',
                  height: 32,
                  width: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
