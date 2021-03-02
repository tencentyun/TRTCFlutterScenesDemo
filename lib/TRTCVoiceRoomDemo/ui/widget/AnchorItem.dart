import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnchorItem extends StatefulWidget {
  AnchorItem({
    Key key,
    this.userName = "",
    this.userImgUrl = "",
    this.isAdministrator = false,
    this.onKickOutUser,
    this.isSoundOff,
  }) : super(key: key);

  final String userName;
  final String userImgUrl;
  final bool isAdministrator;
  final Function onKickOutUser;
  final bool isSoundOff;
  @override
  State<StatefulWidget> createState() => _AnchorItemState();
}

class _AnchorItemState extends State<AnchorItem> {
  handleShowDownWheat(context) {
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

    widget.onKickOutUser();
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
                  Container(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: InkWell(
                        onTap: () {
                          if (!widget.isAdministrator) {
                            //bug 需要判断当前用户是否为管理员才可以调用
                            this.handleShowDownWheat(context);
                          }
                        },
                        child: Image.asset(
                          widget.userImgUrl,
                          height: 80,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 55,
                    top: 55,
                    child: InkWell(
                      onTap: () {},
                      child: widget.isSoundOff
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
            children: [
              widget.isAdministrator
                  ? Image.asset(
                      "assets/images/Administrator.png",
                      height: 14,
                    )
                  : Text(''),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(
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
