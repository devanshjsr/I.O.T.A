import 'package:flutter/material.dart';

class Avatar extends StatefulWidget {
  final uid;
  Avatar({this.uid});
  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.redAccent,
      child: CircleAvatar(
        backgroundColor: Colors.lightBlueAccent,
        radius: 50.0,
        child: Text(
          widget.uid.toString(),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
