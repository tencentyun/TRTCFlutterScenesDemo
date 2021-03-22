import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/TxUtils.dart';

enum CallType {
  VideoOneVOne, //一对一视频通话
  AudioOneVOne, //一对一语音通话
}

class TRTCCallingContact extends StatefulWidget {
  TRTCCallingContact(this.callType, {Key key}) : super(key: key);
  final CallType callType;

  @override
  _TRTCCallingContactState createState() => _TRTCCallingContactState();
}

class _TRTCCallingContactState extends State<TRTCCallingContact> {
  String searchText = '';
  String myLoginInfoId = '';
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

  onSearchClick() {}

  onCallClick() {}

  initUserInfo() async {
    String loginId = await TxUtils.getLoginUserId();
    if (loginId == null || loginId == '') {
      TxUtils.showErrorToast("请先登录。", context);
      goLoginPage();
    } else {
      setState(() {
        myLoginInfoId = loginId;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initUserInfo();
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
                  hintText: "搜索手机号",
                  hintStyle:
                      TextStyle(color: Color.fromRGBO(187, 187, 187, 1.000)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                keyboardType: TextInputType.text,
                onChanged: (value) => this.searchText = value),
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
          child: RaisedButton(
            color: Color.fromRGBO(0, 110, 255, 1.000),
            onPressed: () {
              onSearchClick();
            },
            child: Text(
              '搜索',
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
    var myInfo = Row(
      children: [
        Container(
          constraints: BoxConstraints(minHeight: 12, minWidth: 3),
          margin: EdgeInsets.only(left: 20, right: 10),
          color: Color.fromRGBO(153, 153, 153, 1.000),
        ),
        Text('您的手机号 $myLoginInfoId'),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('视频通话'),
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
              child: getGuideSearchWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
