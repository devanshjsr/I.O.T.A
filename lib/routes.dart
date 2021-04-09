import 'package:flutter/material.dart';

import 'screens/auth/faculty_signup_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_type_screen.dart';
import 'screens/auth/student_signup_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/professor/professor_main_screen.dart';
import 'screens/student/student_main_screen.dart';

Map<String, WidgetBuilder> routes = {
  WelcomeScreen.routeName: (ctx) => WelcomeScreen(),
  LoginScreen.routeName: (ctx) => LoginScreen(),
  StudentSignUpScreen.routeName: (ctx) => StudentSignUpScreen(),
  SignupTypeScreen.routeName: (ctx) => SignupTypeScreen(),
  FacultySignUpScreen.routeName: (ctx) => FacultySignUpScreen(),
  StudentMainScreen.routeName: (ctx) => StudentMainScreen(),
  ProfessorMainScreen.routeName: (ctx) => ProfessorMainScreen(),
};
