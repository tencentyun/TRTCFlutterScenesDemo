import 'dart:math';

import 'package:flutter/material.dart';

class PopUpMessageList extends StatefulWidget {
  const PopUpMessageList({Key? key, this.popupMessageList}) : super(key: key);
  final List<String>? popupMessageList;
  @override
  _PopUpMessageListState createState() => _PopUpMessageListState();
}

class _PopUpMessageListState extends State<PopUpMessageList>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  final _random = new Random();

  static List<Color> colorList = [
    Color(0xFF3074FD),
    Color(0xFFFCAF41),
    Color(0xFFFC6091),
    Color(0xFF3CCFA5),
    Color(0xFFFF8607),
    Color(0xFFF7AF97),
    Color(0xFF3074FD),
    Color(0xFFFCAF41),
    Color(0xFFFC6091),
    Color(0xFF3CCFA5),
  ];

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(seconds: 10), vsync: this);
    animation = new Tween(
      begin: -50.0,
      end: 900.0,
    ).animate(controller);
    controller.repeat(reverse: false);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget getMessagePositioned(String message, int index) {
    int colorIndex = index % 10;
    if (colorIndex < 0) {
      colorIndex = 0;
    }
    return Positioned(
        right: animation.value - (50.0 * colorIndex),
        top: 0 + (20.0 * colorIndex),
        child: Text(
          message,
          style: TextStyle(
            color: colorList[colorIndex],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return Positioned(
            left: 0,
            right: 0,
            top: 95,
            child: Container(
              height: 200,
              color: Colors.transparent,
              child: Stack(
                  alignment: Alignment.topRight,
                  children: widget.popupMessageList!.map((e) {
                    return getMessagePositioned(
                        e, widget.popupMessageList!.indexOf(e));
                  }).toList()),
            ),
          );
        });
  }
}
