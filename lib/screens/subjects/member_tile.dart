import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/member_model.dart';
import '../../models/shared_preferences.dart';
import '../../models/subject_model.dart';
import '../../styles.dart';
import '../student/student_profile_view.dart';

//  Member tile to show list of students enrolled in a subject
class MemberTile extends StatelessWidget {
  final Member member;

  MemberTile({@required this.member});

  @override
  Widget build(BuildContext context) {
    Subject subject = ModalRoute.of(context).settings.arguments;

    return GestureDetector(
        child: Container(
      padding: EdgeInsets.symmetric(vertical: 6),
      decoration: CustomStyle.subjectTileStyle(),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: ExpansionTile(
        leading: Hero(
          tag: member.id,
          child: CircleAvatar(
            radius: 35,
            backgroundColor: CustomStyle.secondaryColor,
            child: CircleAvatar(
              backgroundColor: CustomStyle.primaryColor,
              radius: 25,
              child: Text(
                member.name.substring(0, 2).toUpperCase(),
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
          member.name,
          style: CustomStyle.customButtonTextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          member.mobileNumber,
          style: CustomStyle.customButtonTextStyle(size: 14),
        ),
        trailing: Icon(
          Icons.arrow_drop_down,
          size: 35,
          color: CustomStyle.primaryColor,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: CustomStyle.customElevatedButtonStyle(),
                  onPressed: () {
                    StudentProfileView.showStudentProfile(member.id, context);
                  },
                  child: Text(
                    "PROFILE",
                    style: CustomStyle.customButtonTextStyle(
                      color: CustomStyle.textLight,
                    ),
                  ),
                ),
                if (!MySharedPreferences.isStudent)
                  ElevatedButton(
                    style: CustomStyle.customElevatedButtonStyle(isError: true),
                    onPressed: () {
                      Provider.of<SubjectProvider>(context, listen: false)
                          .removeFromSubject(subject, member.id, context);
                    },
                    child: Text(
                      "REMOVE",
                      style: CustomStyle.customButtonTextStyle(
                        color: CustomStyle.textLight,
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    ));
  }
}
