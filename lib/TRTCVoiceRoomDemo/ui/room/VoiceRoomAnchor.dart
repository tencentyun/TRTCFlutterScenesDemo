import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widget/RoomBottomBar.dart';
import '../widget/AnchorItem.dart';
import '../widget/AudienceItem.dart';

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
                  DescriptionTitle("", "主播"),
                  Container(
                    height: 130,
                    width: MediaQuery.of(context).size.width,
                    child: GridView(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 120.0,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 25,
                          childAspectRatio: 1.0),
                      children: _AnchorList.map((e) => AnchorItem()).toList(),
                    ),
                  ),
                  DescriptionTitle("", "听众"),
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

class DescriptionTitle extends StatelessWidget {
  DescriptionTitle(this.imgUrl, this.title, {Key key}) : super(key: key);
  final String imgUrl;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(Icons.ac_unit_sharp),
      Text(
        "  " + title,
        style: TextStyle(color: Colors.white),
      ),
    ]);
  }
}
