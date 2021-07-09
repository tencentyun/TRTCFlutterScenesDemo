import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trtc_scenes_demo/i10n/localization_intl.dart';
import 'package:trtc_scenes_demo/utils/TxUtils.dart';
import '../model/TRTCMeeting.dart';
import './TRTCMeetingRoom.dart';

class TRTCMeetingMemberList extends StatefulWidget {
  TRTCMeetingMemberList({
    Key? key,
    required this.myInfo,
    required this.userList,
    required this.onMemberListClose,
  }) : super(key: key);

  final MyInfo myInfo;
  final List<UserInfo> userList;
  final Function(List<UserInfo> userList) onMemberListClose;

  @override
  TRTCMeetingMemberListState createState() => TRTCMeetingMemberListState();
}

class TRTCMeetingMemberListState extends State<TRTCMeetingMemberList> {
  // ignore: avoid_init_to_null
  var subSetState = null;

  bool _allAudioMuted = false;
  bool _allVideoMuted = false;
  List<UserInfo> _userList = [];

  late MyInfo myInfo;
  late TRTCMeeting trtcMeeting;

  @override
  initState() {
    super.initState();
    myInfo = widget.myInfo;
    _userList = widget.userList;

    if (_userList.length > 1) {
      _allAudioMuted = _userList.indexWhere(
              (user) => user.userId != myInfo.userId && !user.audioMuted) ==
          -1;
      _allVideoMuted = _userList.indexWhere(
              (user) => user.userId != myInfo.userId && !user.videoMuted) ==
          -1;
    }

    initRoom();
  }

  initRoom() async {
    trtcMeeting = await TRTCMeeting.sharedInstance();
  }

  @override
  didUpdateWidget(TRTCMeetingMemberList oldWidget) {
    super.didUpdateWidget(oldWidget);
    Future.delayed(Duration.zero, () {
      if (subSetState != null) {
        subSetState(() {});
      }
    });
  }

  @override
  dispose() {
    super.dispose();
    subSetState = null;
  }

  onPressedCallback(
      String userId, String type, void Function(void Function()) _setState) {
    if (userId == 'all') {
      if (type == 'audio') {
        _allAudioMuted = !_allAudioMuted;
        _userList.skip(1).forEach((user) => user.audioMuted = _allAudioMuted);
        trtcMeeting.muteAllRemoteAudio(_allAudioMuted);
        TxUtils.showStyledToast(
            _allAudioMuted
                ? Languages.of(context)!.meetingMuteAllAudio
                : Languages.of(context)!.meetingUnmuteAllAudio,
            context);
      } else {
        _allVideoMuted = !_allVideoMuted;
        _userList.skip(1).forEach((user) => user.videoMuted = _allVideoMuted);
        trtcMeeting.muteAllRemoteVideoStream(_allVideoMuted);
        TxUtils.showStyledToast(
            _allVideoMuted
                ? Languages.of(context)!.meetingMuteAllVideo
                : Languages.of(context)!.meetingUnmuteAllVideo,
            context);
      }
    } else {
      int index = _userList.indexWhere((user) => user.userId == userId);
      if (index == -1) return;
      if (type == 'audio') {
        _userList[index].audioMuted = !_userList[index].audioMuted;
        trtcMeeting.muteRemoteAudio(userId, _userList[index].audioMuted);
      } else {
        _userList[index].videoMuted = !_userList[index].videoMuted;
        trtcMeeting.muteRemoteVideoStream(
          userId,
          _userList[index].videoMuted,
        );
      }
    }

    _setState(() {
      _allAudioMuted = _allAudioMuted;
      _allVideoMuted = _allVideoMuted;
      _userList = _userList;
    });
  }

  Widget buildButton(
      String text, Color color, bool isMuted, Function() onPressed) {
    return TextButton(
      child: Text(text),
      onPressed: onPressed,
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(
          TextStyle(
            color: isMuted ? Colors.white : color,
            fontSize: 16.0,
          ),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
            side: BorderSide(color: color),
          ),
        ),
        backgroundColor: MaterialStateProperty.resolveWith(
            (states) => isMuted ? color : Colors.white),
        foregroundColor: MaterialStateProperty.resolveWith(
            (states) => isMuted ? Colors.white : color),
        minimumSize: MaterialStateProperty.all(Size(160.0, 60.0)),
      ),
    );
  }

  Widget buildMemberList(void Function(void Function()) _setState) {
    return Container(
      color: Colors.grey.shade200,
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
      margin: EdgeInsets.only(bottom: 80.0),
      child: ListView(
        children: _userList.map((user) {
          bool isMine = user.userId == myInfo.userId;
          return Container(
            key: ValueKey(user.userId),
            height: 50.0,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Text(
                    isMine ? user.userId + '(me)' : user.userId,
                    style: TextStyle(color: Colors.black, fontSize: 20.0),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Offstage(
                    offstage: isMine,
                    child: IconButton(
                      icon: Icon(
                        !isMine && user.audioMuted ? Icons.mic_off : Icons.mic,
                        color: !isMine && user.audioMuted
                            ? Colors.black54
                            : Colors.black,
                        size: 28.0,
                      ),
                      alignment: Alignment.centerRight,
                      onPressed: () =>
                          onPressedCallback(user.userId, 'audio', _setState),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Offstage(
                    offstage: isMine,
                    child: IconButton(
                      icon: Icon(
                        !isMine && user.videoMuted
                            ? Icons.videocam_off
                            : Icons.videocam,
                        color: !isMine && user.videoMuted
                            ? Colors.black54
                            : Colors.black,
                        size: 28.0,
                      ),
                      alignment: Alignment.centerRight,
                      onPressed: () =>
                          onPressedCallback(user.userId, 'video', _setState),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildTextButtons(void Function(void Function()) _setState) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            buildButton(
                _allAudioMuted
                    ? Languages.of(context)!.meetingUnmuteAllAudio
                    : Languages.of(context)!.meetingMuteAllAudio,
                Colors.green.shade200,
                _allAudioMuted,
                () => onPressedCallback('all', 'audio', _setState)),
            buildButton(
                _allVideoMuted
                    ? Languages.of(context)!.meetingUnmuteAllVideo
                    : Languages.of(context)!.meetingMuteAllVideo,
                Colors.blue,
                _allVideoMuted,
                () => onPressedCallback('all', 'video', _setState)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget buildListTitle() {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      title: Text(
        Languages.of(context)!.meetingMemberList,
        style: TextStyle(color: Colors.black),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        color: Colors.black,
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget buildListBody(void Function(void Function()) _setState) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(bottom: 20.0),
      child: Stack(
        children: <Widget>[
          buildMemberList(_setState),
          buildTextButtons(_setState),
        ],
      ),
    );
  }

  showMemberList() {
    Future<void> future = showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (_context, _setState) {
          subSetState = _setState;
          return Container(
            child: MaterialApp(
              home: Scaffold(
                backgroundColor: Colors.white,
                appBar: buildListTitle(),
                body: buildListBody(_setState),
              ),
            ),
          );
        });
      },
    );

    future.then((value) {
      subSetState = null;
      widget.onMemberListClose(_userList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.people,
        color: Colors.white,
        size: 36.0,
      ),
      onPressed: showMemberList,
    );
  }
}
