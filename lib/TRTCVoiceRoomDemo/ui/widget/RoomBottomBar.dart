import 'package:flutter/material.dart';

class RoomBottomBar extends StatefulWidget {
  RoomBottomBar({Key key, this.isAnchor, this.onTab}) : super(key: key);
  final bool isAnchor;
  final Function onTab;
  @override
  _RoomBottomBarState createState() => _RoomBottomBarState();
}

class _RoomBottomBarState extends State<RoomBottomBar> {
  List<BottomNavigationBarItem> _anchorTabs = [
    BottomNavigationBarItem(label: "主页", icon: Icon(Icons.home)),
    BottomNavigationBarItem(label: "其他", icon: Icon(Icons.devices_other)),
  ];

  List<BottomNavigationBarItem> _audienceTabs = [
    BottomNavigationBarItem(label: "主页", icon: Icon(Icons.home)),
    BottomNavigationBarItem(label: "其他", icon: Icon(Icons.devices_other)),
  ];

  int _currentIndex = 0;

  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 0,
        left: 0,
        child: InkWell(
          child: Text("RoomBottomBar"),
          onTap: () {
            widget.onTab('v');
          },
        ));
  }
}
