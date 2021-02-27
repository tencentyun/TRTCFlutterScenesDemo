import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnchorItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AnchorItemState();
}

class _AnchorItemState extends State<AnchorItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 80,
      color: Colors.green,
      child: Text(
        'AnchorItem',
      ),
    );
  }
}
