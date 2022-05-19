import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';
import 'package:tencent_trtc_cloud/tx_audio_effect_manager.dart';
import 'package:tencent_trtc_cloud/tx_beauty_manager.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/model/TRTCLiveRoom.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/model/TRTCLiveRoomDef.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/model/TRTCLiveRoomDelegate.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/ui/base/FavoriteAnimation.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/ui/base/FilterSetting.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/ui/base/LiveImgButton.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/ui/base/LiveMessageList.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/ui/base/LiveTextButton.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/ui/base/MusicSetting.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/ui/base/PKUserList.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/ui/base/PopUpMessageLIst.dart';
import 'package:trtc_scenes_demo/TRTCLiveRoomDemo/ui/base/SubVideoList.dart';
import 'package:trtc_scenes_demo/base/YunApiHelper.dart';
import 'package:trtc_scenes_demo/utils/TxUtils.dart';

class LiveRoomPage extends StatefulWidget {
  const LiveRoomPage({Key? key, this.isAdmin = false}) : super(key: key);
  final bool isAdmin;
  @override
  _LiveRoomPageState createState() => _LiveRoomPageState();
}

bool useCdnFirst = false;

class _LiveRoomPageState extends State<LiveRoomPage> {
  late TRTCLiveRoom trtcLiveCloud;
  late TXBeautyManager beautyManager;
  late TXAudioEffectManager audioEffectManager;
  final nameFocusNode = FocusNode();
  String roomTitle = "test的房间";
  String userName = "test";
  bool isStandardQuality = true;
  bool isNeedCreateRoom = false;
  bool isInRoom = false;
  bool isShowFilterSetting = false;
  bool isShowMusicSetting = false;
  bool isShowPkUserList = false;
  bool isShowComment = false;
  bool isFrontCamera = true;
  bool isBarrageON = true;
  bool isBarrageSliderOn = false;
  int _onLineUserCount = 0;
  String _currentOwnerId = "";
  bool isOwerAvailable = true;
  int _currentRoomId = 0;
  Map<String, bool> _smallVideoUserId = {};
  String _currentLoginUser = '';
  bool isJoinAnchor = false;
  bool isPKing = false;
  String pkUserId = "";
  List<RoomInfo> _pkUserList = [];
  List<List<MessageColor>> _messageLogList = [];
  String musicTips = "";
  List<String> _popupMessageList = [];
  bool isFavoriteVisiable = false;
  bool useCdnCurrent = useCdnFirst;
  TextEditingController inputController = new TextEditingController();
  final inputFocusNode = FocusNode();
  @override
  void initState() {
    initTrtc();
    super.initState();
    Future.delayed(Duration.zero, () {
      initRoomInfo();
    });
  }

  initRoomInfo() async {
    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    if (arguments.containsKey('isNeedCreateRoom')) {
      isNeedCreateRoom = arguments['isNeedCreateRoom'] as bool;
    }
    if(!isNeedCreateRoom) {
      isInRoom = true;
      enterRoom();
    } else {
      String userId = await TxUtils.getLoginUserId();
      _currentOwnerId = userId;
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
  }

  initTrtc() async {
    trtcLiveCloud = await TRTCLiveRoom.sharedInstance();
    beautyManager = trtcLiveCloud.getBeautyManager();
    audioEffectManager = trtcLiveCloud.getAudioEffectManager();
    trtcLiveCloud.registerListener(onListenerFunc);
  }

  enterRoom() async {
    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    int _tpmCurrentRoomId = int.tryParse(arguments['roomId'].toString())!;
    _currentOwnerId = arguments['ownerId'].toString();
    _currentRoomId = _tpmCurrentRoomId;
    ActionCallback _actionCallback = await trtcLiveCloud.enterRoom(_tpmCurrentRoomId);
    if (_actionCallback.code != 0) {
      showErrorToast("进房失败" + _actionCallback.desc, stopAndGoIndex);
      return;
    }
    if(widget.isAdmin) {
      trtcLiveCloud.startPublish("");
    }
    initData(_currentRoomId);
  }

  initData(int roomId) async {
    String currLoginUserId = await TxUtils.getLoginUserId();
    _currentLoginUser = currLoginUserId;
    getPKList(currLoginUserId, null);
    UserListCallback memberListCallback =
        await trtcLiveCloud.getRoomMemberList(0);
    UserListCallback anchorListCallback = await trtcLiveCloud.getAnchorList();

    Future.delayed(
      Duration(microseconds: 30),
      () {
        FilterSettingWidget.initBeautyValue.forEach((curBeauty, value) {
          this.onBeautyValueChange(curBeauty, value);
        });
        safeSetState(
          () {
            _currentRoomId = roomId;
            if (memberListCallback.list != null) {
              _onLineUserCount = memberListCallback.list!.length;
            }
            if (anchorListCallback.list != null) {
              anchorListCallback.list!.forEach((element) {
                if (element.userId != _currentOwnerId) {
                  _smallVideoUserId[element.userId] = true;
                }
              });
            }
          },
        );
      },
    );
  }

  startBroadcast() async {
    int roomId = TxUtils.getRandomNumber();
    ActionCallback actionCallback =
        await trtcLiveCloud.createRoom(roomId, RoomParam(
            roomName: roomTitle,
            quality: isStandardQuality
                ? TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT
                : TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC,
            coverUrl:
                "https://imgcache.qq.com/operation/dianshi/other/5.ca48acfebc4dfb68c6c463c9f33e60cb8d7c9565.png"));
    if (actionCallback.code == 0) {
      // test service code, please use your own service
      await YunApiHelper.createRoom(roomId.toString(), roomType: "liveRoom");
      // Example：sdkAppId = 12345678，roomId = 12345，userId = userA，So：streamId = 12345678_12345_userA_main
      // String currLoginUserId = await TxUtils.getLoginUserId();
      // String streamId = GenerateTestUserSig.sdkAppId.toString() +
      //     '_' +
      //     roomId.toString() +
      //     '_' +
      //     currLoginUserId +
      //     '_main';
      await trtcLiveCloud.startPublish("");
      initData(roomId);
      setState(() {
        isInRoom = true;
      });
    } else {
      showErrorToast("创建房间失败" + actionCallback.desc, stopAndGoIndex);
    }
    
  }

  getPKList(currLoginUserId, Function? callBack) async {
    if (widget.isAdmin) {
      var roomIdls = await YunApiHelper.getRoomList(roomType: 'liveRoom');

      RoomInfoCallback resp = await trtcLiveCloud.getRoomInfos(roomIdls);
      if (resp.code == 0 && resp.list != null) {
        safeSetState(() {
          _pkUserList = resp.list!.where((element) {
            if (element.ownerId == currLoginUserId) return false;
            return true;
          }).toList();
          if (callBack != null) callBack();
        });
      }
    }
  }

  @override
  void dispose() async {
      if (inputFocusNode.hasFocus) inputFocusNode.unfocus();
      super.dispose();
      trtcLiveCloud.stopCameraPreview();
      trtcLiveCloud.stopPublish();
      trtcLiveCloud.unRegisterListener(onListenerFunc);
  }

  onListenerFunc(type, params) {
    switch (type) {
      case TRTCLiveRoomDelegate.onRecvRoomCustomMsg:
        {
          String command = params["command"].toString();
          if ('like' == command) {
            addMessageLog([
              MessageColor("来自 ", null),
              MessageColor(params["message"].toString(), Color(0xFF3074FD)),
              MessageColor(" 的点赞", null)
            ]);
          } else if ('slider' == command) {
            safeSetState(() {
              _popupMessageList.add(params["message"].toString());
            });
          }
        }
        break;
      case TRTCLiveRoomDelegate.onRoomDestroy:
        showErrorToast("房间已经被销毁", stopAndGoIndex);
        break;
      case TRTCLiveRoomDelegate.onKickedOffline:
        showErrorToast("你已在其他地方登陆了", stopAndGoIndex);
        break;
      case TRTCLiveRoomDelegate.onRecvRoomTextMsg:
        addMessageLog([
          MessageColor(params["userName"].toString(), Color(0xFFFCAF41)),
          MessageColor(": " + params["message"].toString(), null)
        ]);
        break;
      case TRTCLiveRoomDelegate.onUserVideoAvailable:
        onUserVideoAvailableHandle(params);
        break;

      case TRTCLiveRoomDelegate.onAnchorExit:
        {
          safeSetState(() {
            if (_smallVideoUserId.containsKey(params.toString()))
              _smallVideoUserId.remove(params.toString());
          });
          addMessageLog([
            MessageColor("主播 ", null),
            MessageColor(params["userId"].toString(), Color(0xFF3CCFA5)),
            MessageColor(" 离开房间", null)
          ]);
        }
        break;
      case TRTCLiveRoomDelegate.onAnchorEnter:
        {
          addMessageLog([
            MessageColor("欢迎主播 ", null),
            MessageColor(params.toString(), Color(0xFFFF8607)),
            MessageColor(" 进入房间", null)
          ]);
          safeSetState(() {
            pkUserId = params.toString();
            if (_currentOwnerId != params.toString()) {
              _smallVideoUserId[params.toString()] = true;
            }
          });
        }
        break;
      case TRTCLiveRoomDelegate.onAudienceEnter:
        {
          safeSetState(() {
            _onLineUserCount = _onLineUserCount + 1;
          });
          addMessageLog([
            MessageColor("欢迎 ", null),
            MessageColor(params["userId"].toString(), Color(0xFFF7AF97)),
            MessageColor(" 进入房间", null)
          ]);
        }
        break;
      case TRTCLiveRoomDelegate.onAudienceExit:
        {
          safeSetState(() {
            _onLineUserCount = _onLineUserCount - 1;
          });
          safeSetState(() {
            if (_smallVideoUserId.containsKey(params["userId"]))
              _smallVideoUserId.remove(params["userId"]);
          });
          addMessageLog([
            MessageColor(params["userId"].toString(), Color(0xFF3CCFA5)),
            MessageColor(" 离开房间", null)
          ]);
        }
        break;

      case TRTCLiveRoomDelegate.onRequestJoinAnchor:
        onRequestJoinAnchorHandle(params);
        break;
      case TRTCLiveRoomDelegate.onInvitationTimeout:
        {
          safeSetState(() {
            isJoinAnchor = false;
          });
          showErrorToast("申请超时", null);
        }
        break;
      case TRTCLiveRoomDelegate.onAnchorRejected:
        {
          safeSetState(() {
            isJoinAnchor = false;
          });
          showErrorToast("主播拒绝了你的申请", null);
        }
        break;
      case TRTCLiveRoomDelegate.onKickoutJoinAnchor:
        {
          safeSetState(() {
            isJoinAnchor = false;
            if (_smallVideoUserId.containsKey(_currentLoginUser)) {
              _smallVideoUserId.remove(_currentLoginUser);
            }
            if (useCdnFirst) {
              // trtc change to cdn
              useCdnCurrent = true;
            }
          });
          trtcLiveCloud.stopPublish();
          showErrorToast("你被管理员踢下主播", null);
        }
        break;
      case TRTCLiveRoomDelegate.onAnchorAccepted:
        onAnchorAcceptedHandle(params);
        break;

      case TRTCLiveRoomDelegate.onRoomPKRejected:
        {
          safeSetState(() {
            isPKing = false;
            pkUserId = '';
          });
          showErrorToast("主播拒绝跨房Pk请求", null);
        }
        break;
      case TRTCLiveRoomDelegate.onRoomPKAccepted:
        {
          addMessageLog([
            MessageColor(params["userId"].toString(), Color(0xFFFCAF41)),
            MessageColor(" 主播接受跨房Pk请求", null)
          ]);
          safeSetState(() {
            isPKing = true;
          });
        }
        break;
      case TRTCLiveRoomDelegate.onRequestRoomPK:
        {
          onRequestRoomPKHandle(params);
        }
        break;
      case TRTCLiveRoomDelegate.onQuitRoomPK:
        {
          safeSetState(() {
            isPKing = false;
            pkUserId = '';
          });
          showErrorToast("断开跨房 PK ", () {});
        }
        break;
    }
  }

  showErrorToast(String message, Function? callback) {
    TxUtils.showErrorToast(message, context);
    if (callback != null) {
      Future.delayed(Duration(seconds: 2), () {
        callback();
      });
    }
  }

  //主播同意观众的连麦请求
  onAnchorAcceptedHandle(params) async {
    safeSetState(() {
      isJoinAnchor = true;
      _smallVideoUserId[_currentLoginUser] = true;
      if (useCdnFirst) {
        //cdn change to trtc
        useCdnCurrent = false;
      }
    });
    await trtcLiveCloud.startPublish("");
    addMessageLog([
      MessageColor("主播同意 ", null),
      MessageColor(_currentLoginUser, Color(0xFF3074FD)),
      MessageColor(" 连麦请求", null)
    ]);
  }

  onRequestRoomPKHandle(params) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text((params["userName"] == null
                  ? params["userId"].toString()
                  : params["userName"].toString()) +
              ' 发起PK请求'),
          actions: <Widget>[
            // ignore: deprecated_member_use
            FlatButton(
              child: Text("取消"),
              onPressed: () async {
                await trtcLiveCloud.responseRoomPK(
                    params["userId"].toString(), false);
                Navigator.pop(context);
              }, // 关闭对话框
            ),
            // ignore: deprecated_member_use
            FlatButton(
              child: Text("确定"),
              onPressed: () async {
                //关闭对话框并返回true
                await trtcLiveCloud.responseRoomPK(
                    params["userId"].toString(), true);
                safeSetState(() {
                  isPKing = true;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  onUserVideoAvailableHandle(param) {
    String userId = param['userId'];
    bool available = param['available'] as bool;
    // 根据状态对视频进行开启和关闭
    if (_currentOwnerId == userId) {
      setState(() {
        isOwerAvailable = available;
      });
    }
  }

  onRequestJoinAnchorHandle(params) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text((params["userName"] == null
                  ? params["userId"].toString()
                  : params["userName"].toString()) +
              ' 发起连麦请求'),
          actions: <Widget>[
            // ignore: deprecated_member_use
            FlatButton(
              child: Text("取消"),
              onPressed: () async {
                await trtcLiveCloud.responseJoinAnchor(
                    params["userId"].toString(), false, params["callId"]);
                Navigator.pop(context);
              }, // 关闭对话框
            ),
            // ignore: deprecated_member_use
            FlatButton(
              child: Text("确定"),
              onPressed: () async {
                //关闭对话框并返回true
                await trtcLiveCloud.responseJoinAnchor(
                    params["userId"].toString(), true, params["callId"]);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  addMessageLog(List<MessageColor> logInfos) {
    safeSetState(() {
      _messageLogList.add(logInfos);
    });
  }

  //切换摄像头
  onCameraSwitchTap() {
    safeSetState(() {
      isFrontCamera = !isFrontCamera;
      trtcLiveCloud.switchCamera(isFrontCamera);
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

  safeSetState(callBack) {
    setState(() {
      if (mounted) {
        callBack();
      }
    });
  }

  //滤镜
  onFilterSettingTap() {
    safeSetState(() {
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
              onChanged: onBeautyValueChange,
              onClose: () {
                safeSetState(() {
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

  showQuitRoomPK() async {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("确定退出PK"),
          actions: <Widget>[
            // ignore: deprecated_member_use
            FlatButton(
              child: Text("取消"),
              onPressed: () async {
                Navigator.pop(context);
              }, // 关闭对话框
            ),
            // ignore: deprecated_member_use
            FlatButton(
              child: Text("确定"),
              onPressed: () async {
                await trtcLiveCloud.quitRoomPK();
                safeSetState(() {
                  isPKing = false;
                  pkUserId = '';
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  stopAndGoIndex() async {
    try {
      await trtcLiveCloud.stopPublish();
      trtcLiveCloud.unRegisterListener(onListenerFunc);
      if (widget.isAdmin) {
        await trtcLiveCloud.destroyRoom();
        await YunApiHelper.destroyRoom(_currentRoomId.toString(),
            roomType: 'liveRoom');
      } else {
        await trtcLiveCloud.exitRoom();
      }
    } catch (ex) {} finally {
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          "/liveRoom/list",
        );
      }
    }
  }

  onCloseRoomTap() async {
    if (isPKing) {
      showQuitRoomPK();
      return;
    }
    stopAndGoIndex();
  }

  onCommentTap() {
    safeSetState(() {
      isShowComment = true;
    });
  }

  onMusicSettingTap() {
    safeSetState(() {
      isShowMusicSetting = true;
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
          return MusicSetting(
            playMusicTips: musicTips,
            onSelectMusice: (path, _musicTips) {
              audioEffectManager
                  .startPlayMusic(AudioMusicParam(id: 0, path: path));
              setState(() {
                musicTips = _musicTips;
              });
            },
            onAllMusicVolumeChange: (value) {
              audioEffectManager.setAllMusicVolume(value.toInt());
            },
            onMusicPitchChange: (value) {
              audioEffectManager.setMusicPitch(value.toInt(), 0);
            },
            onVoiceVolumeChange: (value) {
              audioEffectManager.setVoiceCaptureVolume(value.toInt());
            },
            onVoiceChangerTypeChange: (int type) {
              audioEffectManager.setVoiceChangerType(type);
            },
            onVoiceReverbTypeChange: (int type) {
              audioEffectManager.setVoiceReverbType(type);
            },
            onClose: () {
              safeSetState(() {
                isShowMusicSetting = false;
              });
              Navigator.of(context).pop(true);
            },
          );
        },
      );
    });
  }

  //显示pk列表
  onShowPkUserList() {
    getPKList(_currentLoginUser, () {
      showModalBottomSheet<void>(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
          return PKUserList(
            roomList: _pkUserList,
            onRequestRoomPK: (roomId, ownerId) async {
              await trtcLiveCloud.requestRoomPK(roomId, ownerId);
              TxUtils.showToast("已发起PK邀请，等待同意", context);
              Navigator.of(context).pop(true);
            },
          );
        },
      );
    });
    safeSetState(() {
      isShowPkUserList = true;
    });
  }

  onRequestJoinAnchor() {
    safeSetState(() {
      isJoinAnchor = true;
    });
    trtcLiveCloud.requestJoinAnchor();
    TxUtils.showToast("等待主播接受.....", context);
  }

  onLikeTap() {
    trtcLiveCloud.sendRoomCustomMsg("like", _currentLoginUser);
    safeSetState(() {
      isFavoriteVisiable = true;
      _popupMessageList.add(_currentLoginUser + "点赞");
    });
    Future.delayed(Duration(seconds: 3), () {
      safeSetState(() {
        isFavoriteVisiable = false;
      });
    });
  }

  Widget getTopBtnList() {
    List<Widget> btnList = (isPKing && pkUserId != '')
        ? [
            LiveTextButton(
              text: "结束PK",
              onPressed: onCloseRoomTap,
              backgroundColor: Colors.red,
            )
          ]
        : [
            LiveImgButton(
              imgUrl: isBarrageON
                  ? "assets/images/liveRoom/Barrage-ON.png"
                  : "assets/images/liveRoom/Barrage.png",
              onTap: () {
                safeSetState(() {
                  isBarrageON = !isBarrageON;
                });
              },
            ),
            LiveImgButton(
              imgUrl: "assets/images/liveRoom/closeRoom.png",
              onTap: () {
                onCloseRoomTap();
              },
            ),
          ];
    btnList.insert(
      0,
      Expanded(
        flex: 1,
        child: Container(
          padding: EdgeInsets.only(left: 0),
          margin: EdgeInsets.only(right: 70),
          decoration: new BoxDecoration(
            color: Color.fromRGBO(0, 0, 0, 0.2),
            borderRadius: BorderRadius.all(Radius.circular(26)),
          ),
          constraints: BoxConstraints(maxWidth: 180, minHeight: 48),
          width: 180,
          height: 48,
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(
                  'https://imgcache.qq.com/operation/dianshi/other/5.ca48acfebc4dfb68c6c463c9f33e60cb8d7c9565.png',
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 6,
                        width: 6,
                        color: Colors.red,
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 70),
                            child: Text(
                              roomTitle,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                          )),
                    ],
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: 80),
                    child: Text(
                      _onLineUserCount.toString() + '人正在观看',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return Container(
        margin: EdgeInsets.only(top: 35, left: 20, right: 10),
        child: Row(
          children: btnList,
        ));
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
              focusNode: nameFocusNode,
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

  Widget getInputMessage() {
    return Row(
      children: [
        Container(
          child: LiveImgButton(
              onTap: () {
                safeSetState(() {
                  isBarrageSliderOn = !isBarrageSliderOn;
                });
              },
              imgUrl: isBarrageSliderOn
                  ? "assets/images/liveRoom/barrage_slider_on.png"
                  : "assets/images/liveRoom/barrage_slider_off.png"),
        ),
        Expanded(
          flex: 2,
          child: TextField(
            cursorHeight: 25,
            controller: inputController,
            focusNode: inputFocusNode,
            onSubmitted: (s) {
              onSubmitted(s, context);
            },
            onChanged: (value) {
              inputController.text = value;
              inputController.selection = TextSelection.fromPosition(
                TextPosition(
                    affinity: TextAffinity.downstream, offset: value.length),
              );
            },
            autofocus: true,
            autocorrect: false,
            textAlign: TextAlign.left,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.send,
            cursorColor: Color(0x006fff),
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              isDense: true,
              hintText: "和大家说点什么吧…",
              contentPadding: EdgeInsets.only(
                top: 0,
                bottom: 5,
              ),
            ),
            style: TextStyle(fontSize: 16, color: Colors.black),
            minLines: 1,
          ),
        ),
        LiveTextButton(
            text: "发送",
            onPressed: () {
              onSubmitted(inputController.text, context);
            }),
      ],
    );
  }

    Widget getBottomBtnListPreview() {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
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
                  startBroadcast();
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

  Widget getBottomBtnList() {
    List<Widget> btnList = [];
    if (widget.isAdmin) {
      btnList = [
        LiveImgButton(
          imgUrl: "assets/images/liveRoom/Comment.png",
          imgSize: 52,
          onTap: () {
            onCommentTap();
          },
        ),
        LiveImgButton(
          imgUrl: "assets/images/liveRoom/CameraSwitch.png",
          imgSize: 52,
          onTap: () {
            onCameraSwitchTap();
          },
        ),
        LiveImgButton(
          imgUrl: "assets/images/liveRoom/PK.png",
          imgSize: 52,
          onTap: () {
            onShowPkUserList();
          },
        ),
        LiveImgButton(
          imgUrl: "assets/images/liveRoom/Filter.png",
          imgSize: 52,
          onTap: () {
            onFilterSettingTap();
          },
        ),
        LiveImgButton(
          imgUrl: "assets/images/liveRoom/music.png",
          imgSize: 52,
          onTap: () {
            onMusicSettingTap();
          },
        ),
      ];
    } else {
      btnList = [
        LiveImgButton(
          imgUrl: "assets/images/liveRoom/Comment.png",
          imgSize: 52,
          onTap: () {
            onCommentTap();
          },
        ),
        Expanded(
          flex: 1,
          child: Container(
            child: Container(),
          ),
        ),
        LiveImgButton(
          imgUrl: isJoinAnchor
              ? "assets/images/liveRoom/Microphone-off.png"
              : "assets/images/liveRoom/Microphone-on.png",
          imgSize: 52,
          onTap: () async {
            if (!isJoinAnchor) {
              onRequestJoinAnchor();
            } else {
              //主动退出主播
              safeSetState(() {
                isJoinAnchor = false;
                if (_smallVideoUserId.containsKey(_currentLoginUser)) {
                  _smallVideoUserId.remove(_currentLoginUser);
                }
                if (useCdnFirst) {
                  //trtc change to cdn
                  useCdnCurrent = true;
                }
              });
              await trtcLiveCloud.stopPublish();
            }
          },
        ),
        LiveImgButton(
          imgUrl: "assets/images/liveRoom/Like.png",
          imgSize: 52,
          onTap: () {
            onLikeTap();
          },
        ),
      ];
    }
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: btnList,
      ),
    );
  }

  onSubmitted(String messageVal, context) async {
    if (messageVal == '') {
      return;
    }
    if (isBarrageSliderOn) {
      trtcLiveCloud.sendRoomCustomMsg("slider", messageVal);
      safeSetState(() {
        _popupMessageList.add(messageVal);
      });
    } else {
      trtcLiveCloud.sendRoomTextMsg(messageVal);
    }
    addMessageLog(
      [MessageColor("我: ", Color(0xFFFC6091)), MessageColor(messageVal, null)],
    );
    TxUtils.showToast("发送成功", context);
    inputController.clear();
    safeSetState(() {
      isShowComment = false;
    });
  }

  Widget getPKingView() {
    return Container(
        color: Color.fromRGBO(0, 0, 0, 0.3),
        padding: EdgeInsets.only(top: 90),
        child: SizedBox(
          height: 350,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 180,
                height: 250,
                child: TRTCCloudVideoView(
                  key: ValueKey("PKPreview_VideoViewId"),
                  viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
                  onViewCreated: (viewId) async {
                    trtcLiveCloud.stopCameraPreview();
                    trtcLiveCloud.startCameraPreview(isFrontCamera, viewId);
                  },
                ),
              ),
              Container(
                // color: Color.fromRGBO(0, 00, 0, 0.2),
                width: 180,
                height: 250,
                child: pkUserId != ''
                    ? TRTCCloudVideoView(
                        key: ValueKey("PKPlay_VideoViewId"),
                        viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
                        onViewCreated: (viewId) async {
                          trtcLiveCloud.startPlay(pkUserId, viewId);
                        },
                      )
                    : Container(),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (inputFocusNode.hasFocus) {
            safeSetState(() {
              isShowComment = false;
            });
            inputFocusNode.unfocus();
          }
          if (nameFocusNode.hasFocus) {
            nameFocusNode.unfocus();
          }
        },
        child: Stack(
          fit: StackFit.expand,

          children: [
            isPKing
                ? getPKingView()
                : Container(
                    color: Color.fromRGBO(0, 0, 0, 0.3),
                    child: Container(
                      child: (!widget.isAdmin && !isOwerAvailable) ||
                              useCdnCurrent
                          ? Center(
                              child: Text(
                                useCdnCurrent
                                    ? 'Please use the player to play the CDN URL'
                                    : 'The live broadcast is temporarily offline~~~',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : TRTCCloudVideoView(
                              key: ValueKey("LiveRoomPage_bigVideoViewId"),
                              viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
                              hitTestBehavior: PlatformViewHitTestBehavior.transparent,
                              onViewCreated: (viewId) async {
                                if (widget.isAdmin) {
                                  await trtcLiveCloud.startCameraPreview(isFrontCamera, viewId);
                                } else {
                                  await trtcLiveCloud.startPlay( _currentOwnerId, viewId);
                                }
                              },
                            ),
                    ),
                  ),
            isInRoom ?  Stack(
              children: [
            Align(
              alignment: Alignment.topLeft,
              child: getTopBtnList(),
            ),
            PopUpMessageList(
              popupMessageList: isBarrageON ? _popupMessageList : [],
            ),
            LiveMessageList(
              messageList: _messageLogList,
            ),
            SubVideoList(
              isShowClose: widget.isAdmin ? true : false,
              userList: (pkUserId != "" && isPKing)
                  ? []
                  : _smallVideoUserId.keys.toList(),
              onClose: (String userId) async {
                if (userId == _currentLoginUser) {
                  await trtcLiveCloud.stopPublish();
                  setState(() {
                    isJoinAnchor = false;
                  });
                } else {
                  await trtcLiveCloud.kickoutJoinAnchor(userId);
                }
                if (_smallVideoUserId.containsKey(userId))
                  safeSetState(() {
                    _smallVideoUserId.remove(userId);
                  });
              },
              onViewCreate: (userId, viewId) async {
                String currLoginUserId = await TxUtils.getLoginUserId();
                if (userId == currLoginUserId) {
                  trtcLiveCloud.startCameraPreview(isFrontCamera, viewId);
                  return;
                }
                trtcLiveCloud.startPlay(userId, viewId);
              },
            ),
            FavoriteAnimation(isVisible: isFavoriteVisiable),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: isShowComment ? 
                 Padding(
                   child: getInputMessage(),
                   padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)) : getBottomBtnList(),
            ),
          ],
        ) : Stack(
              children: [
                Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: getCreateRoomCard(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: getBottomBtnListPreview(),
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
            )],)
      ),
    );
  }
}
