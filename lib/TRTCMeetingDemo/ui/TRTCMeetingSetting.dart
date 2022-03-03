import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:trtc_scenes_demo/i10n/localization_intl.dart';
import '../model/TRTCMeeting.dart';

class TRTCMeetingSetting extends StatefulWidget {
  TRTCMeetingSetting({Key? key, this.onSharePress}) : super(key: key);

  final Function()? onSharePress;

  @override
  State<StatefulWidget> createState() => TRTCMeetingSettingState();
}

class TRTCMeetingSettingState extends State<TRTCMeetingSetting> {
  List resolutionList = [
    {
      'value': TRTCCloudDef.TRTC_VIDEO_RESOLUTION_320_180,
      'text': '180 * 320',
      'minBitrate': 80,
      'maxBitrate': 350,
      'curBitrate': 350,
    },
    {
      'value': TRTCCloudDef.TRTC_VIDEO_RESOLUTION_480_270,
      'text': '270 * 480',
      'minBitrate': 200,
      'maxBitrate': 1000,
      'curBitrate': 500,
    },
    {
      'value': TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360,
      'text': '360 * 640',
      'minBitrate': 200,
      'maxBitrate': 1000,
      'curBitrate': 600,
    },
    {
      'value': TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540,
      'text': '540 * 960',
      'minBitrate': 400,
      'maxBitrate': 1600,
      'curBitrate': 900,
    },
    {
      'value': TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720,
      'text': '720 * 1280',
      'minBitrate': 500,
      'maxBitrate': 2000,
      'curBitrate': 1250,
    },
  ];
  List frameRateList = [15, 20];

  String _curResolution = '360 * 640';
  int _curResolutionValue = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_360;
  double _minBitrate = 200;
  double _maxBitrate = 1000;
  double _curBitrate = 600;
  int _curFrameRate = 15;
  bool _enableMirror = true;
  double _curCaptureValue = 100;
  double _curPlayValue = 100;

  late TRTCMeeting trtcMeeting;

  @override
  initState() {
    super.initState();
    initRoom();
  }

  initRoom() async {
    trtcMeeting = await TRTCMeeting.sharedInstance();
  }

  onTapResolution(void Function(void Function()) _setState) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (_context, state) {
          return Container(
            height: 200.0,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                  initialItem: resolutionList.indexWhere(
                      (res) => res['value'] == _curResolutionValue)),
              itemExtent: 24.0,
              onSelectedItemChanged: (index) {
                trtcMeeting.setVideoEncoderParam(
                  videoFps: _curFrameRate,
                  videoBitrate: resolutionList[index]['curBitrate'],
                  videoResolution: resolutionList[index]['value'],
                );
                _setState(() {
                  _curResolution = resolutionList[index]['text'];
                  _curResolutionValue = resolutionList[index]['value'];
                  _minBitrate = double.parse(
                      resolutionList[index]['minBitrate'].toString());
                  _maxBitrate = double.parse(
                      resolutionList[index]['maxBitrate'].toString());
                  _curBitrate = double.parse(
                      resolutionList[index]['curBitrate'].toString());
                });
              },
              children:
                  resolutionList.map((item) => Text(item['text'])).toList(),
            ),
          );
        });
      },
    );
  }

  onTapFrameRate(void Function(void Function()) _setState) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (_context, state) {
          return Container(
            height: 200.0,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                  initialItem: frameRateList.indexOf(_curFrameRate)),
              itemExtent: 24.0,
              onSelectedItemChanged: (index) {
                trtcMeeting.setVideoEncoderParam(
                  videoFps: frameRateList[index],
                  videoBitrate: _curBitrate.round(),
                  videoResolution: _curResolutionValue,
                );
                _setState(() {
                  _curFrameRate = frameRateList[index];
                });
              },
              children:
                  frameRateList.map((item) => Text(item.toString())).toList(),
            ),
          );
        });
      },
    );
  }

  onBitrateChanged(double value, void Function(void Function()) _setState) {
    trtcMeeting.setVideoEncoderParam(
      videoFps: _curFrameRate,
      videoBitrate: value.round(),
      videoResolution: _curResolutionValue,
    );
    _setState(() => _curBitrate = value);
  }

  switchMirror(void Function(void Function()) _setState) {
    trtcMeeting.setLocalViewMirror(!_enableMirror);
    _setState(() => _enableMirror = !_enableMirror);
  }

  Widget buildSettingText(String text,
      {double width = 70.0, double fontSize = 16.0}) {
    return Container(
      width: width,
      height: 50.0,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildGestureDetector(String text, void Function() onTap) {
    return GestureDetector(
      child: Container(
        alignment: Alignment.centerLeft,
        width: 150.0,
        height: 50.0,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  Widget buildDropIcon(IconData icon, void Function() onPressed) {
    return IconButton(
      alignment: Alignment.centerRight,
      icon: Icon(
        icon,
        color: Colors.black,
        size: 16.0,
      ),
      onPressed: onPressed,
    );
  }

  Widget buildSlider(
      double value, double min, double max, void Function(double) onChanged) {
    return Slider(
      value: value,
      min: min,
      max: max,
      onChanged: onChanged,
    );
  }

  Widget buildSwitch(void Function(void Function()) _setState) {
    return Container(
      alignment: Alignment.centerRight,
      height: 50.0,
      child: Switch(
        value: _enableMirror,
        onChanged: (value) => switchMirror(_setState),
      ),
    );
  }

  Widget buildVideoSetting(void Function(void Function()) _setState) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              buildSettingText(Languages.of(context)!.meetingResolution),
              buildGestureDetector(
                  _curResolution, () => onTapResolution(_setState)),
              buildDropIcon(
                  Icons.arrow_forward_ios, () => onTapResolution(_setState)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              buildSettingText(Languages.of(context)!.meetingFrameRate),
              buildGestureDetector(
                  _curFrameRate.toString(), () => onTapFrameRate(_setState)),
              buildDropIcon(
                  Icons.arrow_forward_ios, () => onTapFrameRate(_setState)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              buildSettingText(Languages.of(context)!.meetingBitRate),
              buildSlider(_curBitrate, _minBitrate, _maxBitrate,
                  (value) => onBitrateChanged(value, _setState)),
              buildSettingText(_curBitrate.round().toString() + 'kbps',
                  width: 56.0, fontSize: 12.0),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              buildSettingText(Languages.of(context)!.meetingLocalMirror),
              buildSwitch(_setState),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildAudioSetting(void Function(void Function()) _setState) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              buildSettingText(Languages.of(context)!.meetingCaptureVolume),
              buildSlider(_curCaptureValue, 0, 100, (value) {
                trtcMeeting.setAudioCaptureVolume(value.round());
                _setState(() => _curCaptureValue = value);
              }),
              buildSettingText(_curCaptureValue.round().toString(),
                  width: 50.0),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              buildSettingText(Languages.of(context)!.meetingPlayVolume),
              buildSlider(_curPlayValue, 0, 100, (value) {
                trtcMeeting.setAudioPlayoutVolume(value.round());
                _setState(() => _curPlayValue = value);
              }),
              buildSettingText(_curPlayValue.round().toString(), width: 50.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildShareTabView() {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Icon(
            Icons.mobile_screen_share,
            color: Colors.blue,
            size: 120.0,
          ),
          TextButton(
            child: Text(Languages.of(context)!.meetingShareScreen),
            onPressed: widget.onSharePress,
            style: ButtonStyle(
              textStyle: MaterialStateProperty.all(TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              )),
              backgroundColor: MaterialStateProperty.all(Colors.blue),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              minimumSize: MaterialStateProperty.all(Size(160.0, 60.0)),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget getTabBar() {
    return TabBar(
      labelStyle: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
      labelColor: Colors.black,
      indicatorWeight: 5.0,
      tabs: <Widget>[
        Tab(text: Languages.of(context)!.meetingVideoSetting),
        Tab(text: Languages.of(context)!.meetingAudioSetting),
        Tab(text: Languages.of(context)!.meetingShareScreen),
      ],
    );
  }

  Widget getTabBarBody(void Function(void Function()) _setState) {
    return TabBarView(
      children: <Widget>[
        buildVideoSetting(_setState),
        buildAudioSetting(_setState),
        buildShareTabView(),
      ],
    );
  }

  showSettingDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (_context, _setState) {
          return Container(
            child: MaterialApp(
              home: DefaultTabController(
                length: 3,
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                    centerTitle: true,
                    title: Text(
                      Languages.of(_context)!.settingText,
                      style: TextStyle(color: Colors.black),
                    ),
                    bottom: getTabBar(),
                  ),
                  body: getTabBarBody(_setState),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.settings,
        color: Colors.white,
        size: 36.0,
      ),
      onPressed: showSettingDialog,
    );
  }
}
