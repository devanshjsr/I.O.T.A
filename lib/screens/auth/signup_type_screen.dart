import 'package:flutter/material.dart';

import '../../styles.dart';
import '../auth/faculty_signup_screen.dart';
import '../auth/student_signup_screen.dart';

class SignupTypeScreen extends StatelessWidget {
  static const routeName = "/signup_type_screen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomStyle.backgroundColor,
      body: Container(
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 4),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Are you a:",
                style: CustomStyle.customButtonTextStyle(),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(StudentSignUpScreen.routeName);
                },
                style: CustomStyle.customOutlinedButtonStyle(),
                child: Text(
                  "STUDENT",
                  style: CustomStyle.customButtonTextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "or",
                style: CustomStyle.customButtonTextStyle(),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(FacultySignUpScreen.routeName);
                },
                style: CustomStyle.customOutlinedButtonStyle(),
                child: Text(
                  "FACULTY",
                  style: CustomStyle.customButtonTextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
