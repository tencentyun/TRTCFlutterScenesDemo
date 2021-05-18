import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AudienceItem extends StatefulWidget {
  AudienceItem({
    Key? key,
    this.userName = "",
    this.userImgUrl = "",
  }) : super(key: key);

  final String userName;
  final String userImgUrl;
  @override
  State<StatefulWidget> createState() => _AudienceItemState();
}

class _AudienceItemState extends State<AudienceItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: InkWell(
                  onTap: () {
                    //
                  },
                  child: Image.network(
                    widget.userImgUrl,
                    height: 60,
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
                Container(
                  width: 60,
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
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
        ],
      ),
    );
  }
}
