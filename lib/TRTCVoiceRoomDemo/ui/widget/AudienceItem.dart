import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AudienceItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AudienceItemState();
}

class _AudienceItemState extends State<AudienceItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 60,
      color: Colors.greenAccent,
      child: Text(
        'AudienceItem',
      ),
    );
  }
}
