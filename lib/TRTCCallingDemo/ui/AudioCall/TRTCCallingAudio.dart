import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TRTCCallingAudio extends StatefulWidget {
  @override
  _TRTCCallingAudioState createState() => _TRTCCallingAudioState();
}

class _TRTCCallingAudioState extends State<TRTCCallingAudio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('语音通话'),
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
