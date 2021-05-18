import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoomTopMessage extends StatefulWidget {
  RoomTopMessage({
    Key? key,
    this.message = '',
    this.visible = false,
    this.isShowBtn = false,
    this.okTitle,
    this.cancelTitle,
    this.onOkTab,
    this.onCancelTab,
  }) : super(key: key);
  final String message;
  final bool visible;
  final String? okTitle;
  final String? cancelTitle;
  final Function? onOkTab;
  final Function? onCancelTab;
  final bool isShowBtn;
  @override
  State<StatefulWidget> createState() => _RoomTopMessageState();
}

class _RoomTopMessageState extends State<RoomTopMessage> {
  Widget buildBtnList(BuildContext context) {
    return widget.isShowBtn
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 30, 10),
                height: 36,
                // ignore: deprecated_member_use
                child: FlatButton(
                  color: Color.fromRGBO(15, 169, 104, 1.0),
                  child: Text(
                    widget.okTitle!,
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    widget.onOkTab!();
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color.fromRGBO(235, 244, 255, 1.0),
                    width: 1,
                  ), //边框
                  borderRadius: BorderRadius.all(
                    Radius.circular(3.0),
                  ),
                ),
                margin: EdgeInsets.fromLTRB(30, 0, 0, 10),
                height: 36,
                child: FlatButton(
                  child: Text(
                    widget.cancelTitle!,
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    widget.onCancelTab!();
                  },
                ),
              ),
            ],
          )
        : Container(
            height: 0,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.visible ? MediaQuery.of(context).size.width : 0,
      color: Color.fromRGBO(0, 98, 227, 1.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: widget.visible ? 38 : 0,
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 10),
                padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                child: Text(
                  widget.message,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          buildBtnList(context),
        ],
      ),
    );
  }
}
