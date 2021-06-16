import 'package:flutter/material.dart';

class MessageColor {
  const MessageColor(this.msg, this.color);
  final String msg;
  final Color? color;
}

class LiveMessageList extends StatefulWidget {
  const LiveMessageList({Key? key, this.messageList}) : super(key: key);

  final List<List<MessageColor>>? messageList;
  @override
  _LiveMessageListState createState() => _LiveMessageListState();
}

class _LiveMessageListState extends State<LiveMessageList> {
  Widget getMessageList() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      bottom: 120,
      //right: 200,
      width: 250,
      child: Container(
        height: 200,
        padding: EdgeInsets.only(left: 10, right: 10),
        child: ListView.separated(
          itemCount: widget.messageList!.length,
          separatorBuilder: (BuildContext context, int index) => Divider(),
          padding: EdgeInsets.only(top: 10, bottom: 0),
          itemBuilder: (context, index) {
            List<MessageColor> msgColorList = widget.messageList![index];
            // widget.messageList![index]
            List<InlineSpan> ls = msgColorList.map((msgObj) {
              return TextSpan(
                text: msgObj.msg,
                style: TextStyle(
                  color: msgObj.color == null ? Colors.white : msgObj.color,
                ),
              );
            }).toList();
            return Container(
              decoration: new BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.2),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              height: 32,
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      children: ls),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
