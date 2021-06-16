import 'dart:math';

import 'package:flutter/material.dart';

class FavoriteAnimation extends StatefulWidget {
  const FavoriteAnimation({Key? key, this.isVisible = false}) : super(key: key);
  final bool isVisible;
  @override
  _FavoriteAnimationState createState() => _FavoriteAnimationState();
}

class _FavoriteAnimationState extends State<FavoriteAnimation>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(seconds: 2), vsync: this);
    animation = new Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(controller);
    //controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FavoriteAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible) {
      controller.reset();
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    double currVal = animation.value;
    double bottom = 100;

    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return Positioned(
            right: (1.0 - animation.value) * 45 + 20,
            bottom: (1.0 - animation.value) * 180 + 70,
            child: Opacity(
              opacity: animation.value,
              child: Container(
                child: widget.isVisible
                    ? Icon(
                        Icons.favorite,
                        size: 42,
                        color: Colors.redAccent,
                      )
                    : Container(),
              ),
            ),
          );
        });
  }
}
