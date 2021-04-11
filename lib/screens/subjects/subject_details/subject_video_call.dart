import 'package:flutter/material.dart';

import '../../../models/shared_preferences.dart';
import '../../../models/subject_model.dart';
import '../../../styles.dart';
import '../../video/call_screen.dart';
import '../../video/create_channel.dart';

class SubjectVideoCall extends StatelessWidget {
  final userType =
      MySharedPreferences.isStudent == true ? "Student" : "Faculty";
  @override
  Widget build(BuildContext context) {
    Subject subject = ModalRoute.of(context).settings.arguments;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (userType == "Faculty")
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(CreateChannel.routeName, arguments: subject);
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
                Navigator.of(context)
                    .pushNamed(IndexPage.routeName, arguments: subject);
                //IndexPage is Call_Screen
              },
            ),
          ),
        ],
      ),
    );
  }
}
