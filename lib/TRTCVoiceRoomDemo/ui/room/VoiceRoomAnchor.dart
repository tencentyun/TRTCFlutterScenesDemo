import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widget/RoomBottomBar.dart';

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
  List<String> speakingList = new List<String>();
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
                  Expanded(
                    flex: 0,
                    child: Container(
                      alignment: Alignment.topLeft,
                      color: Colors.red,
                      width: MediaQuery.of(context).size.width,
                      //height: 200,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('听众图标'),
                              Text('听众'),
                            ],
                          ),
                          Container(
                              height: 130,
                              width: MediaQuery.of(context).size.width,
                              child: GridView(
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 50.0,
                                        childAspectRatio: 1.0),
                                children: <Widget>[
                                  Icon(Icons.beach_access),
                                  Icon(Icons.cake),
                                  Icon(Icons.free_breakfast),
                                  Icon(Icons.ac_unit),
                                  Icon(Icons.airport_shuttle),
                                  Icon(Icons.all_inclusive),
                                  Icon(Icons.beach_access),
                                  Icon(Icons.ac_unit),
                                  Icon(Icons.airport_shuttle),
                                  Icon(Icons.all_inclusive),
                                  Icon(Icons.beach_access),
                                  Icon(Icons.cake),
                                  Icon(Icons.free_breakfast),
                                  Icon(Icons.ac_unit),
                                  Icon(Icons.airport_shuttle),
                                  Icon(Icons.all_inclusive),
                                  Icon(Icons.beach_access),
                                  Icon(Icons.cake),
                                  Icon(Icons.free_breakfast),
                                  Icon(Icons.airport_shuttle),
                                  Icon(Icons.all_inclusive),
                                  Icon(Icons.beach_access),
                                  Icon(Icons.ac_unit),
                                  Icon(Icons.airport_shuttle),
                                  Icon(Icons.all_inclusive),
                                  Icon(Icons.beach_access),
                                  Icon(Icons.cake),
                                  Icon(Icons.free_breakfast),
                                  Icon(Icons.ac_unit),
                                  Icon(Icons.airport_shuttle),
                                  Icon(Icons.all_inclusive),
                                  Icon(Icons.beach_access),
                                  Icon(Icons.cake),
                                  Icon(Icons.free_breakfast),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.green,
                      width: MediaQuery.of(context).size.width,
                      child: Text('BUTTOM'),
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
