import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TRTCCallingVideo extends StatefulWidget {
  @override
  _TRTCCallingVideoState createState() => _TRTCCallingVideoState();
}

class _TRTCCallingVideoState extends State<TRTCCallingVideo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('视频通话'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios), //color: Colors.black
            onPressed: () async {}),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(),
    );
  }
}
