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
          alignment: Alignment.center, //指定未定位或部分定位widget的对齐方式
          fit: StackFit.expand,
          children: <Widget>[
            //未定位,撑满
            Container(
              //这里设置容器的对齐方式
              alignment: Alignment.center,
              child: Text("未进行定位", style: TextStyle(color: Colors.red)),
              color: Color.fromRGBO(14, 25, 44, 1),
            ),
            RoomBottomBar(
              isAnchor: true,
              onTab: (v) {
                print('onTab---' + v);
              },
            ),
          ],
        ),
      ),
    );
  }
}
