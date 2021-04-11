import 'package:flutter/material.dart';

import 'screens/assignments/add_assignments.dart';
import 'screens/assignments/view_assignment.dart';
import 'screens/assignments/view_submission.dart';
import 'screens/auth/faculty_signup_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_type_screen.dart';
import 'screens/auth/student_signup_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/professor/addSubjects.dart';
import 'screens/professor/approve_join_requests_screen.dart';
import 'screens/professor/professor_main_screen.dart';
import 'screens/room/add_students.dart';
import 'screens/room/create_room.dart';
import 'screens/room/post_main_page.dart';
import 'screens/room/remove_member.dart';
import 'screens/room/view_room.dart';
import 'screens/student/student_main_screen.dart';
import 'screens/subjects/subject_bottom_navbar.dart';
import 'screens/subjects/subject_details/subject_settings.dart';
import 'screens/subjects/subject_search.dart';
import 'screens/temp_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/video/call_screen.dart';
import 'screens/video/create_channel.dart';
import 'screens/video/video_home_screen.dart';

Map<String, WidgetBuilder> routes = {
  WelcomeScreen.routeName: (ctx) => WelcomeScreen(),
  LoginScreen.routeName: (ctx) => LoginScreen(),
  StudentSignUpScreen.routeName: (ctx) => StudentSignUpScreen(),
  StudentMainScreen.routeName: (ctx) => StudentMainScreen(),
  SignupTypeScreen.routeName: (ctx) => SignupTypeScreen(),
  FacultySignUpScreen.routeName: (ctx) => FacultySignUpScreen(),
  ProfessorMainScreen.routeName: (ctx) => ProfessorMainScreen(),
  AddSubjects.routeName: (ctx) => AddSubjects(),
  UserProfileScreen.routeName: (ctx) => UserProfileScreen(),
  Temp.routeName: (ctx) => Temp(),

  // video routes
  CreateChannel.routeName: (ctx) => CreateChannel(),
  VideoHomeScreen.routeName: (ctx) => VideoHomeScreen(),
  IndexPage.routeName: (ctx) => IndexPage(),

  //  Subjects
  SubjectBottomNavBar.routeName: (ctx) => SubjectBottomNavBar(),
  SubjectSettings.routeName: (ctx) => SubjectSettings(),
  SubjectSearchScreen.routeName: (ctx) => SubjectSearchScreen(),

  //Assignments
  AddAssignment.routeName: (ctx) => AddAssignment(),
  ViewAssignment.routeName: (ctx) => ViewAssignment(),
  ViewSubmission.routeName: (ctx) => ViewSubmission(),

  //Room
  Post.routeName: (ctx) => Post(),
  CreateRoom.routeName: (ctx) => CreateRoom(),
  AddStudents.routeName: (ctx) => AddStudents(),
  ViewRoom.routeName: (ctx) => ViewRoom(),
  RemoveMember.routeName: (ctx) => RemoveMember(),
  ApproveJoinRequests.routeName: (ctx) => ApproveJoinRequests(),
};
