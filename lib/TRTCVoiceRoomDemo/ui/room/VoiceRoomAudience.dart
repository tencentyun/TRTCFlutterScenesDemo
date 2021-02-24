import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/*
 *  观众界面
 */
class VoiceRoomAudiencePage extends StatefulWidget {
  VoiceRoomAudiencePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VoiceRoomAudiencePageState();
}

class VoiceRoomAudiencePageState extends State<VoiceRoomAudiencePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: const Text('观众界面'),
        centerTitle: true,
        elevation: 0,
        // automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(14, 25, 44, 1),
      ),
      body: Center(
        child: Text('观众界面'),
      ),
    );
  }
}
