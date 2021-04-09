import 'package:shared_preferences/shared_preferences.dart';

//  Class to save and retreive the data stored in Saved Preferences

//  Saved data ->
//  isStudent -> bool -> true if current user is a student

class MySharedPreferences {
  //  variable to store current user type
  static bool isStudent;
  //  Method to save/update isStudent
  static Future<void> isStudentSave(bool currentUserIsStudent) async {
    isStudent = currentUserIsStudent;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isStudent", currentUserIsStudent);
  }

  //  method to retreive isStudent, returns false if 'isStudent' not found
  static Future<bool> isStudentGet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isStudent = prefs.getBool("isStudent") ?? false;
    return isStudent;
  }
}
