import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnchorItem extends StatefulWidget {
  AnchorItem({
    Key key,
    this.userName = "",
    this.userImgUrl = "",
    this.isAdministrator = false,
    this.onKickOutUser,
    this.roomOwnerId,
    this.isMute,
    this.isVolumeUpdate,
  }) : super(key: key);

  final String userName;
  final String userImgUrl;
  final bool isAdministrator;
  final int roomOwnerId;
  final Function onKickOutUser;
  final bool isMute;
  final bool isVolumeUpdate;
  @override
  State<StatefulWidget> createState() => _AnchorItemState();
}

class _AnchorItemState extends State<AnchorItem>
    with SingleTickerProviderStateMixin {
  handleShowKickOutUser(context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) => Container(
                color: Color.fromRGBO(19, 35, 63, 1),
                height: 160,
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onKickOutUser();
                      },
                      title: Text(
                        '要求下麦',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(235, 240, 250, 1),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          height: 2,
                          width: MediaQuery.of(context).size.width,
                          color: Color.fromRGBO(0, 9, 22, 1),
                          child: Text(''),
                        ),
                      ],
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      title: Text(
                        '取消',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(235, 240, 250, 0.5),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                )));
      },
    );
  }

  Animation<double> animation;
  AnimationController _controller;
  @override
  initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = Tween(begin: 4.0, end: 0.0).animate(_controller);
    animation.addStatusListener((status) {
      ///dismissed	动画在起始点停止
      ///forward	动画正在正向执行
      ///reverse	动画正在反向执行
      ///completed	动画在终点停止
      if (status == AnimationStatus.completed) {
        //动画执行结束时反向执行动画
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        //动画恢复到初始状态时执行动画（正向）
        _controller.forward();
      }
    });
    //启动动画（正向）
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  widget.isVolumeUpdate
                      ? AnimatedBuilder(
                          animation: animation,
                          builder: (BuildContext context, Widget child) {
                            return Container(
                              decoration: BoxDecoration(
                                border: new Border.all(
                                  color: Color.fromRGBO(15, 169, 104,
                                      1), //_colorsTween.evaluate(animation),
                                  width: animation.value,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(widget.userImgUrl),
                                  fit: BoxFit.fitWidth,
                                ),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              width: 80,
                              height: 80,
                            );
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(widget.userImgUrl),
                              fit: BoxFit.fitWidth,
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          width: 80,
                          height: 80,
                        ),
                  Positioned(
                    left: 55,
                    top: 55,
                    child: InkWell(
                      onTap: () {},
                      child: widget.isMute
                          ? Image.asset(
                              "assets/images/sound_off.png",
                              height: 24,
                            )
                          : Text(''),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                height: 15,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                child: widget.isAdministrator
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/Administrator.png",
                            height: 14,
                          ),
                          Expanded(
                            flex: 0,
                            child: Text(
                              ' ' + widget.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        widget.userName,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
