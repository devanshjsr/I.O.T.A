import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../dialog/custom_dialog.dart';
import '../../models/shared_preferences.dart';
import '../../models/subject_model.dart';
import '../../styles.dart';
import 'subject_bottom_navbar.dart';

class SubjectTile extends StatelessWidget {
  final Subject subject;
  SubjectTile({@required this.subject});
  @override
  Widget build(BuildContext context) {
    //  Method to show options for a subject
    //  Shown options depends on whether the user is student or faculty
    subjectOptions(Offset offset) {
      if (MySharedPreferences.isStudent) {
        //  student-options
        CustomDialog.showOptionDialog(context, subject, true, offset);
      } else {
        //  faculty-options
        CustomDialog.showOptionDialog(context, subject, false, offset);
      }
    }

    openSubjectDetailsPage() {
      Navigator.of(context)
          .pushNamed(SubjectBottomNavBar.routeName, arguments: subject);
    }

    return GestureDetector(
      onLongPressStart: (data) {
        subjectOptions(data.globalPosition);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        decoration: CustomStyle.subjectTileStyle(),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: ListTile(
          onTap: () {
            openSubjectDetailsPage();
          },
          leading: Hero(
            tag: subject.id,
            child: CircleAvatar(
              radius: 35,
              backgroundColor: CustomStyle.secondaryColor,
              child: CircleAvatar(
                backgroundColor: CustomStyle.primaryColor,
                radius: 25,
                child: Text(
                  subject.name.substring(0, 2).toUpperCase(),
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
            subject.name,
            style:
                CustomStyle.customButtonTextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: FutureBuilder(
              future: Subject.getFacultyNameFromFacultyId(subject.facultyId),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      snapshot.data,
                      style: CustomStyle.customButtonTextStyle(size: 14),
                    ),
                  );
                } else {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.grey[100],
                    child: FractionallySizedBox(
                      alignment: Alignment.topLeft,
                      widthFactor: 0.7,
                      child: Container(
                        margin: EdgeInsets.only(top: 5),
                        height: 14,
                        color: CustomStyle.primaryColor,
                      ),
                    ),
                  );
                }
              }),
          trailing: GestureDetector(
            onTapDown: (data) {
              subjectOptions(data.globalPosition);
            },
            child: Icon(
              Icons.more_vert_rounded,
              size: 35,
              color: CustomStyle.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
