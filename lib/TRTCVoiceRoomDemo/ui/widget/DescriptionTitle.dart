import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DescriptionTitle extends StatelessWidget {
  DescriptionTitle(this.imgUrl, this.title, {Key key}) : super(key: key);
  final String imgUrl;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Image.asset(
        imgUrl,
        height: 16,
        width: 16,
      ),
      Text(
        "  " + title,
        style: TextStyle(color: Colors.white),
      ),
    ]);
  }
}
