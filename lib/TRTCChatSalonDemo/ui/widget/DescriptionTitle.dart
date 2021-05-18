import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DescriptionTitle extends StatelessWidget {
  DescriptionTitle(this.imgUrl, this.title, {Key? key}) : super(key: key);
  final String imgUrl;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
          child: Image.asset(
            imgUrl,
            height: 16,
            width: 16,
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
