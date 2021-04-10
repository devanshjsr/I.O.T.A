import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../../models/shared_preferences.dart';
import '../../models/subject_model.dart';
import '../../styles.dart';
import 'subject_details/subject_assignment.dart';
import 'subject_details/subject_details.dart';
import 'subject_details/subject_members.dart';
import 'subject_details/subject_quiz.dart';
import 'subject_details/subject_settings.dart';
import 'subject_details/subject_video_call.dart';

class SubjectBottomNavBar extends StatefulWidget {
  static const routeName = "/subject_bottom_nav_bar";

  @override
  _SubjectBottomNavBarState createState() => _SubjectBottomNavBarState();
}

class _SubjectBottomNavBarState extends State<SubjectBottomNavBar> {
  int page = 2;

  Widget getWidget() {
    switch (page) {
      case 0:
        return SubjectMembers();
      case 1:
        return SubjectVideoCall();
      case 3:
        return SubjectQuiz();
      case 4:
        return SubjectAssignment();
      default:
        return SubjectDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    //  subject fetched through modalroute
    Subject subject = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          subject.name,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        actions: [
          //  Show settings only to faculty
          !MySharedPreferences.isStudent
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(SubjectSettings.routeName,
                        arguments: subject);
                  },
                  color: Colors.black,
                  icon: Icon(Icons.settings),
                )
              //  Sized box to keep subject name in overall center of appbar
              : SizedBox(
                  width: 46,
                  height: 24,
                ),
        ],
      ),
      body: getWidget(),
      bottomNavigationBar: CurvedNavigationBar(
        height: 55,
        backgroundColor: CustomStyle.backgroundColor,
        color: CustomStyle.primaryColor,
        buttonBackgroundColor: CustomStyle.backgroundColor,
        animationDuration: Duration(milliseconds: 200),
        animationCurve: Curves.ease,
        index: 2,
        items: <Widget>[
          Icon(
            Icons.group,
            size: page == 0 ? 40 : 25,
            color: page == 0 ? Colors.black : Colors.white,
          ),
          Icon(
            Icons.video_call,
            size: page == 1 ? 40 : 25,
            color: page == 1 ? Colors.black : Colors.white,
          ),
          Icon(
            Icons.menu_book_rounded,
            size: page == 2 ? 40 : 25,
            color: page == 2 ? Colors.black : Colors.white,
          ),
          Icon(
            Icons.school,
            size: page == 3 ? 40 : 25,
            color: page == 3 ? Colors.black : Colors.white,
          ),
          Icon(
            Icons.file_copy_rounded,
            size: page == 4 ? 40 : 25,
            color: page == 4 ? Colors.black : Colors.white,
          ),
        ],
        onTap: (index) {
          setState(() {
            page = index;
          });
        },
      ),
    );
  }
}
