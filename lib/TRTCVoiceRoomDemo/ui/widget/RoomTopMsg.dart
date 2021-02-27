import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoomTopMessage extends StatefulWidget {
  RoomTopMessage({
    Key key,
    this.message,
    this.visible,
    this.onTab,
  }) : super(key: key);
  final String message;
  final bool visible;
  final Function onTab;
  @override
  State<StatefulWidget> createState() => _RoomTopMessageState();
}

class _RoomTopMessageState extends State<RoomTopMessage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 80,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                widget.message,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                child: RaisedButton(
                  child: Text('OK'),
                  onPressed: () {},
                ),
              ),
              RaisedButton(
                child: Text('Cancel'),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
