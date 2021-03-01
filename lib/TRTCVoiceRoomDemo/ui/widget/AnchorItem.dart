import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnchorItem extends StatefulWidget {
  AnchorItem({
    Key key,
    this.userName,
    this.userImgUrl,
    this.isAdministrator,
    this.onUserTap,
    this.isSoundOff,
  }) : super(key: key);

  final String userName;
  final String userImgUrl;
  final bool isAdministrator;
  final Function onUserTap;
  final bool isSoundOff;
  @override
  State<StatefulWidget> createState() => _AnchorItemState();
}

class _AnchorItemState extends State<AnchorItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: InkWell(
                  onTap: () {
                    widget.onUserTap();
                  },
                  child: Image.asset(
                    widget.userImgUrl,
                    height: 80,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: Row(
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
          ),
          Positioned(
            right: 10,
            top: 60,
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
    );
  }
}
