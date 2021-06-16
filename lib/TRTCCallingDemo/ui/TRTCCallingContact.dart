import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trtc_scenes_demo/TRTCCallingDemo/model/TRTCCallingDelegate.dart';
import 'package:trtc_scenes_demo/debug/GenerateTestUserSig.dart';
import '../../utils/TxUtils.dart';
import '../../login/ProfileManager_Mock.dart';
import '../model/TRTCCalling.dart';
import 'base/CallTypes.dart';
import 'base/CallingScenes.dart';

class TRTCCallingContact extends StatefulWidget {
  TRTCCallingContact(this.callingScenes, {Key? key}) : super(key: key);
  final CallingScenes callingScenes;

  @override
  _TRTCCallingContactState createState() => _TRTCCallingContactState();
}

class _TRTCCallingContactState extends State<TRTCCallingContact> {
  String searchText = '';
  String myLoginInfoId = '';
  List<UserModel> userList = [];
  late ProfileManager _profileManager;
  late TRTCCalling sInstance;
  goIndex() {
    Navigator.pushReplacementNamed(
      context,
      "/index",
    );
    return true;
  }

  goLoginPage() {
    Navigator.pushReplacementNamed(
      context,
      "/login",
    );
    return true;
  }

  //搜索
  onSearchClick() async {
    List<UserModel> ls =
        await ProfileManager.getInstance().queryUserInfo(searchText);

    setState(() {
      userList = ls;
    });
  }

  //发起通话
  onCallClick(UserModel userInfo) async {
    if (userInfo.userId == myLoginInfoId) {
      TxUtils.showErrorToast('不能呼叫自己', context);
      return;
    }
    Navigator.pushReplacementNamed(
      context,
      "/calling/callingView",
      arguments: {
        "remoteUserInfo": userInfo,
        "callType": CallTypes.Type_Call_Someone,
        "callingScenes": widget.callingScenes
      },
    );
  }

  // 提示浮层
  showToast(text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }

  initUserInfo() async {
    _profileManager = await ProfileManager.getInstance();
    sInstance = await TRTCCalling.sharedInstance();
    String loginId = await TxUtils.getLoginUserId();
    await sInstance.login(GenerateTestUserSig.sdkAppId, loginId,
        await GenerateTestUserSig.genTestSig(loginId));
    sInstance.unRegisterListener(onTrtcListener);
    sInstance.registerListener(onTrtcListener);
    if (loginId == '') {
      TxUtils.showErrorToast("请先登录。", context);
      goLoginPage();
    } else {
      setState(() {
        myLoginInfoId = loginId;
      });
    }
  }

  onTrtcListener(type, params) async {
    switch (type) {
      case TRTCCallingDelegate.onInvited:
        {
          UserModel userInfo = await _profileManager
              .querySingleUserInfo(params["sponsor"].toString());
          Navigator.pushReplacementNamed(
            context,
            "/calling/callingView",
            arguments: {
              "remoteUserInfo": userInfo,
              "callType": CallTypes.Type_Being_Called,
              "callingScenes": params['type'] == TRTCCalling.typeVideoCall
                  ? CallingScenes.VideoOneVOne
                  : CallingScenes.AudioOneVOne
            },
          );
        }
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    initUserInfo();
  }

  @override
  void dispose() {
    super.dispose();
    sInstance.unRegisterListener(onTrtcListener);
  }

  getGuideSearchWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Center(
          child: Image.asset(
            'assets/images/callingDemo/search.png',
            height: 97,
          ),
        ),
        Center(
          child: Text('搜索添加已注册用户'),
        ),
        Center(
          child: Text('以发起通话'),
        ),
      ],
    );
  }

  getSearchResult() {
    return CustomScrollView(
      slivers: [
        SliverFixedExtentList(
          itemExtent: 55.0,
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              var userInfo = userList[index];
              return Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(44),
                        child: Image.network(
                          userInfo.avatar,
                          height: 44,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: Text(
                          userInfo.name,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      // ignore: deprecated_member_use
                      child: RaisedButton(
                        color: Colors.green,
                        onPressed: () {
                          onCallClick(userInfo);
                        },
                        child: Text(
                          '呼叫',
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                        ),
                        shape: RoundedRectangleBorder(
                          side: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
            childCount: userList.length,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var searchBtn = Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(19.0),
              ),
              color: Color.fromRGBO(244, 245, 249, 1.000),
            ),
            child: TextField(
                style: TextStyle(color: Colors.black),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "搜索用户ID",
                  hintStyle:
                      TextStyle(color: Color.fromRGBO(187, 187, 187, 1.000)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => this.searchText = value),
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 20),
          // ignore: deprecated_member_use
          child: RaisedButton(
            color: Color.fromRGBO(0, 110, 255, 1.000),
            shape: RoundedRectangleBorder(
              side: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            onPressed: () {
              onSearchClick();
            },
            child: Text(
              '搜索',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
    var myInfo = Row(
      children: [
        Container(
          constraints: BoxConstraints(minHeight: 12, minWidth: 3),
          margin: EdgeInsets.only(left: 20, right: 10),
          color: Color.fromRGBO(153, 153, 153, 1.000),
        ),
        Text('您的用户ID是 $myLoginInfoId'),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: widget.callingScenes == CallingScenes.VideoOneVOne
            ? Text('视频通话')
            : Text('语音通话'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios), //color: Colors.black
          onPressed: () async {
            goIndex();
          },
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: WillPopScope(
        onWillPop: () async {
          return goIndex();
        },
        child: Column(
          children: [
            searchBtn,
            myInfo,
            Expanded(
              flex: 1,
              child: getSearchResult(), //getGuideSearchWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
