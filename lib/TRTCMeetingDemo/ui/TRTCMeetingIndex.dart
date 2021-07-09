import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trtc_scenes_demo/i10n/localization_intl.dart';

class TRTCMeetingIndex extends StatefulWidget {
  TRTCMeetingIndex({Key? key}) : super(key: key);

  @override
  TRTCMeetingIndexState createState() => TRTCMeetingIndexState();
}

class TRTCMeetingIndexState extends State<TRTCMeetingIndex> {
  String _meetingNumber = '';
  bool _enabledCamera = true;
  bool _enabledMicrophone = true;
  final meetIdFocusNode = FocusNode();

  Future<bool> goIndex() async {
    Navigator.pushReplacementNamed(
      context,
      "/index",
    );
    return true;
  }

  openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showToast(Languages.of(context)!.errorOpenUrl,
          context: context, position: StyledToastPosition.center);
    }
  }

  unFocus() {
    if (meetIdFocusNode.hasFocus) {
      meetIdFocusNode.unfocus();
    }
  }

  enterMeeting() async {
    if (!verifyMeetingId()) return;

    var isCameraGranted = await Permission.camera.request().isGranted;
    var isMicrGranted = await Permission.microphone.request().isGranted;

    if (Platform.isMacOS || (isCameraGranted && isMicrGranted)) {
      Navigator.pushNamed(context, "/meeting/meetingRoom", arguments: {
        "meetingNumber": _meetingNumber,
        "enabledCamera": _enabledCamera,
        "enabledMicrophone": _enabledMicrophone,
      });
    } else {
      showToast(Languages.of(context)!.errorMicrophonePermission,
          context: context, position: StyledToastPosition.center);
    }
  }

  bool verifyMeetingId() {
    String meetId = _meetingNumber.replaceAll(new RegExp(r"\s+\b|\b\s"), "");

    if (meetId == '' || meetId == '0') {
      showToast(Languages.of(context)!.errorMeetingIdInput,
          context: context, position: StyledToastPosition.center);
      return false;
    } else if (meetId.toString().length > 10) {
      showToast(Languages.of(context)!.errorMeetingIdLength,
          context: context, position: StyledToastPosition.center);
      return false;
    } else if (!new RegExp(r"[0-9]+$").hasMatch(meetId)) {
      showToast(Languages.of(context)!.errorMeetingIdNumber,
          context: context, position: StyledToastPosition.center);
      return false;
    }

    unFocus();

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: WillPopScope(
        onWillPop: goIndex,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: unFocus,
          child: Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Column(
              children: <Widget>[
                buildInput(),
                buildSwitch(),
                buildEnterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      title: Text(
        Languages.of(context)!.meetingCallTitle,
        style: TextStyle(color: Colors.black),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        color: Colors.black,
        onPressed: goIndex,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.contact_support),
          color: Colors.black,
          tooltip: Languages.of(context)!.helpTooltip,
          onPressed: () =>
              openUrl('https://cloud.tencent.com/document/product/647/45667'),
        ),
      ],
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
    );
  }

  Widget buildInput() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey.shade200,
      ),
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: TextField(
        style: TextStyle(color: Colors.black),
        autofocus: true,
        focusNode: meetIdFocusNode,
        decoration: InputDecoration(
          labelText: Languages.of(context)!.meetingInputLabel,
          hintText: Languages.of(context)!.meetingInputHintText,
          labelStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          hintStyle: TextStyle(color: Colors.black45),
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) => setState(() => _meetingNumber = value),
      ),
    );
  }

  Widget buildSwitch() {
    return Container(
      margin: const EdgeInsets.only(top: 30.0),
      child: Column(
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text(
              Languages.of(context)!.meetingTurnOnCamera,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Switch(
              value: _enabledCamera,
              onChanged: (value) => setState(() => _enabledCamera = value),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text(
              Languages.of(context)!.meetingTurnOnMic,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Switch(
              value: _enabledMicrophone,
              onChanged: (value) => setState(() => _enabledMicrophone = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEnterButton() {
    return Container(
      margin: const EdgeInsets.only(top: 30.0),
      child: TextButton(
        child: Text(Languages.of(context)!.meetingEnterLabel),
        onPressed: _meetingNumber.isEmpty ? null : enterMeeting,
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: MaterialStateProperty.resolveWith((states) =>
              _meetingNumber.isEmpty ? Colors.grey.shade200 : Colors.blue),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          minimumSize: MaterialStateProperty.all(Size(160.0, 60.0)),
        ),
      ),
    );
  }
}
