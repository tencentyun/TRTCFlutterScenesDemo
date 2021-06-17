import 'package:flutter/material.dart';

class LiveImgButton extends StatelessWidget {
  const LiveImgButton(
      {Key? key, required this.onTap, required this.imgUrl, this.imgSize = 32})
      : super(key: key);
  final Function onTap;
  final String imgUrl;
  final double imgSize;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      child: InkWell(
        onTap: () {
          this.onTap();
        },
        child: Image.asset(
          this.imgUrl,
          height: this.imgSize,
          width: this.imgSize,
        ),
      ),
    );
  }
}
