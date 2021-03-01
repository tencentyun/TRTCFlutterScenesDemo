import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widget/RoomBottomBar.dart';
import '../widget/AnchorItem.dart';
import '../widget/AudienceItem.dart';
import '../widget/RoomTopMsg.dart';
import '../widget/DescriptionTitle.dart';

/*
 *  主播界面
 */
class VoiceRoomAnchorPage extends StatefulWidget {
  VoiceRoomAnchorPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VoiceRoomAnchorPageState();
}

class VoiceRoomAnchorPageState extends State<VoiceRoomAnchorPage> {
  UserStatus userStatus = UserStatus.NoSpeaking;
  UserType userType = UserType.Administrator;
  List<String> _AnchorList = [
    '1',
    '33',
    '44',
    '2',
    '33',
    '44',
    '2',
    '33',
    '44',
    '2',
    '33',
    '44',
    '2',
    '33',
    '44'
  ];
  List<String> _AudienceList = [
    '2',
    '33',
    '44',
    '2',
    '33',
    '44',
    '2',
    '33',
    '44',
    '2',
    '33',
    '44',
    '2',
    '44',
    '2',
    '33',
    '44',
    '2',
    '33',
    '44',
    '2',
    '33',
    '44'
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: const Text('主播界面'),
        centerTitle: true,
        elevation: 0,
        // automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(14, 25, 44, 1),
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.topLeft, //指定未定位或部分定位widget的对齐方式
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  RoomTopMessage(
                    message: 'XXX申请成为主播',
                    visible: true,
                    isShowBtn: true,
                    okTitle: '欢迎',
                    cancelTitle: '拒绝',
                    onCancelTab: () {},
                    onOkTab: () {},
                  ),
                  DescriptionTitle("assets/images/Anchor_ICON.png", "主播"),
                  Container(
                    height: 140,
                    width: MediaQuery.of(context).size.width,
                    child: GridView(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 140.0,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 15, //水平间隔
                        childAspectRatio: 1.0,
                      ),
                      children: _AnchorList.map((_anchorItem) => AnchorItem(
                            userName: _anchorItem,
                            userImgUrl: 'assets/images/Anchor-exp.jpg',
                            isAdministrator: _anchorItem == '1' ? true : false,
                            isSoundOff: _anchorItem == '1' ? true : false,
                            onUserTap: () {},
                          )).toList(),
                    ),
                  ),
                  DescriptionTitle("assets/images/Audience_ICON.png", "听众"),
                  Expanded(
                    flex: 2,
                    child: GridView(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 80.0,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 25,
                          childAspectRatio: 1.0),
                      children:
                          _AudienceList.map((e) => AudienceItem()).toList(),
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: Container(
                      height: 60,
                    ),
                  )
                ],
              ),
              color: Color.fromRGBO(14, 25, 44, 1),
            ),
            RoomBottomBar(
              userStatus: userStatus,
              userType: userType,
              onTab: (v) {
                print('onTab---' + v);
                setState(() {
                  userStatus = UserStatus.Speaking;
                  userType = UserType.Audience;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
