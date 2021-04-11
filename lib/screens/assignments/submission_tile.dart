import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/submission_model.dart';
import '../../styles.dart';

class SubmissionTile extends StatelessWidget {
  Submission submission;

  SubmissionTile({@required this.submission});

  void _launchURL() async => await canLaunch(submission.url)
      ? await launch(submission.url)
      : throw 'Could not launch url';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        decoration: CustomStyle.subjectTileStyle(),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: ListTile(
          onTap: () {
            _launchURL();
          },
          leading: Hero(
            tag: submission.id,
            child: CircleAvatar(
              radius: 35,
              backgroundColor: CustomStyle.secondaryColor,
              child: CircleAvatar(
                backgroundColor: CustomStyle.primaryColor,
                radius: 25,
                child: Text(
                  submission.name.isEmpty
                      ? "US"
                      : submission.name.substring(0, 2).toUpperCase(),
                  style: TextStyle(
                      color: CustomStyle.backgroundColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2),
                ),
              ),
            ),
          ),
          title: Text(
            submission.name,
            style:
                CustomStyle.customButtonTextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Submitted Time :  " + submission.submissionTime.toString(),
            style: CustomStyle.customButtonTextStyle(size: 14),
          ),
        ),
      ),
    );
  }
}
