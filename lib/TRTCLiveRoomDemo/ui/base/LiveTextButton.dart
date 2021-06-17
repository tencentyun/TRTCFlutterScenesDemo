import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LiveTextButton extends StatelessWidget {
  const LiveTextButton({
    Key? key,
    required this.text,
    this.size,
    this.backgroundColor,
    required this.onPressed,
    this.radius,
    this.textStyle,
  }) : super(key: key);
  final String text;
  final Function onPressed;
  final Size? size;
  final double? radius;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.all(
                Radius.circular(this.radius != null ? this.radius! : 20)),
          )),
          backgroundColor: MaterialStateProperty.all(
              this.backgroundColor != null
                  ? this.backgroundColor!
                  : Color(0xFF29CC85)),
          minimumSize: MaterialStateProperty.all(
              this.size != null ? this.size! : Size(76, 38))),
      child: Text(
        this.text,
        style: this.textStyle != null
            ? this.textStyle!
            : TextStyle(color: Colors.white, fontSize: 14),
      ),
      onPressed: () {
        this.onPressed();
      },
    );
  }
}
