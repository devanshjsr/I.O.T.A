// import '../services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../styles.dart';
import 'call_screen.dart';
import 'create_channel.dart';

class VideoHomeScreen extends StatefulWidget {
  static const routeName = '/video_home_screen';

  @override
  _VideoHomeScreenState createState() => _VideoHomeScreenState();
}

class _VideoHomeScreenState extends State<VideoHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomStyle.secondaryColor,
        title: Text('Video call'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(CreateChannel.routeName);
                },
                child: Text(
                  'Create new Channel',
                  style: CustomStyle.customButtonTextStyle(
                      fontWeight: FontWeight.bold),
                ),
                style: CustomStyle.customOutlinedButtonStyle(),
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: OutlinedButton(
                child: Text(
                  'Video Call',
                  style: CustomStyle.customButtonTextStyle(
                      fontWeight: FontWeight.bold),
                ),
                style: CustomStyle.customOutlinedButtonStyle(),
                onPressed: () {
                  Navigator.of(context).pushNamed(IndexPage.routeName);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
