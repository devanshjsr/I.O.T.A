import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../dialog/custom_dialog.dart';
import '../../models/assignment_model.dart';
import '../../models/data_model.dart';
import '../../models/shared_preferences.dart';
import '../../styles.dart';
import 'view_assignment_arguments.dart';

class ViewAssignment extends StatefulWidget {
  static final routeName = "/viewAssignment";

  @override
  _ViewAssignmentState createState() => _ViewAssignmentState();
}

class _ViewAssignmentState extends State<ViewAssignment> {
  File file;

  String url = "";
  String fileName = "";
  String workAttachement = "Add Work";
  String mySubmittedUrl = "";
  bool deadline = false;
  bool submit = false;

  String myWorkUrl = "";
  Future getPdfWork() async {
    var rng = new Random();
    String randomName = "";

    for (var i = 0; i < 20; i++) {
      print(rng.nextInt(100));
      randomName += rng.nextInt(100).toString();
    }
    try {
      file = await FilePicker.getFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc'],
      );

      setState(() {
        url = file.uri.toString();
      });
    } catch (error) {
      throw error;
    }

    fileName = '${randomName}.pdf';
    print(fileName);

    print(
        'file path ================================== ${file.readAsBytesSync()}');
  }

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  @override
  Widget build(BuildContext context) {
    AssignmentArgument assignmentArgument =
        ModalRoute.of(context).settings.arguments;

    final String time = assignmentArgument.assignment.dueDate;

    final String year = time.substring(0, 4);
    final String month = time.substring(5, 7);
    final String day = time.substring(8, 10);

    final String hr = time.substring(12, 14);
    final String min = time.substring(15, 17);

    final DateTime current = DateTime.now();
    final DateTime currentTime = DateTime.utc(
        current.year, current.month, current.day, current.hour, current.minute);
    final DateTime assignmentTime = DateTime.utc(int.parse(year),
        int.parse(month), int.parse(day), int.parse(hr), int.parse(min));

    DateTime currentDate = DateTime.now();

    Future submitAssignment() async {
      List<int> asset = [];
      if (file != null) {
        print(currentTime.isAfter(assignmentTime));

        if (currentTime.isAfter(assignmentTime)) {
          Fluttertoast.showToast(
              msg: DataModel.DEADLINE_PASSED,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          Navigator.of(context).pop();
        } else {
          asset = file.readAsBytesSync();

          setState(() {
            submit = true;
          });
          await Provider.of<AssignmentProvider>(context, listen: false)
              .uploadAssignmentWork(
                  asset, assignmentArgument.assignment, fileName);

          setState(() {
            submit = false;
          });

          Fluttertoast.showToast(
              msg: DataModel.WORKK_SUBMITTED,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          Navigator.of(context).pop();
        }
      } else {
        Fluttertoast.showToast(
            msg: DataModel.ATTACH_WORK,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }

    Future<void> _selectTime() async {
      //TimeOfDay currentTime = TimeOfDay(hour: assignmentTime.hour,minute: assignmentTime.minute);
      TimeOfDay currentTime = TimeOfDay.now();
      print(currentTime);
      var pickedTime = await showTimePicker(
        context: context,
        initialTime: currentTime,
      );
      if (pickedTime != null) {
        currentTime = pickedTime;
        DateTime pickedDateTime = DateTime.utc(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            pickedTime.hour,
            pickedTime.minute);

        setState(() {
          deadline = true;
        });
        await Provider.of<AssignmentProvider>(context, listen: false)
            .changeDeadline(assignmentArgument.assignment,
                pickedDateTime.toIso8601String());

        Fluttertoast.showToast(
            msg: DataModel.DEADLINE_CHANGED,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);

        setState(() {
          deadline = false;
        });
        Navigator.of(context).pop();
      }
    }

    Future<void> _selectDate() async {
      currentDate = DateTime(
          assignmentTime.year, assignmentTime.month, assignmentTime.day);
      print(currentDate);
      var pickedDate = await showDatePicker(
          context: context,
          initialDate: currentDate,
          firstDate: DateTime(2015),
          lastDate: DateTime(2050));
      if (pickedDate != null) currentDate = pickedDate;
      _selectTime();
    }

    Future _deleteWork() async {
      setState(() {
        submit = true;
      });
      await Provider.of<AssignmentProvider>(context, listen: false)
          .deleteUploadedAssignment(assignmentArgument.assignment);

      setState(() {
        submit = false;
      });

      Fluttertoast.showToast(
          msg: DataModel.WORK_REMOVED,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.of(context).pop();
    }

    Future _getMyWorkUrl() async {
      myWorkUrl = await Assignment.fetchMyWork(assignmentArgument.assignment);
    }

    return Scaffold(
        appBar: AppBar(
          titleSpacing: -5,
          title: Text("Submit Assignment "),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Text(
                  assignmentArgument.assignment.name,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  assignmentArgument.assignment.description,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 30,
                ),
                assignmentArgument.assignment.url.isEmpty
                    ? SizedBox(
                        height: 20,
                      )
                    : Container(
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: CustomStyle.primaryColor,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  _launchURL(assignmentArgument.assignment.url);
                                },
                                child: ListTile(
                                  tileColor: Colors.grey,
                                  title: Text(
                                    "Attached Assignment",
                                    style: CustomStyle.customButtonTextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: GestureDetector(
                                    onTapDown: (data) {
                                      CustomDialog.showDownloadDialog(
                                          context,
                                          data.globalPosition,
                                          assignmentArgument.assignment.url);
                                    },
                                    child: Icon(
                                      Icons.more_vert_rounded,
                                      size: 35,
                                      color: CustomStyle.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            )
                          ],
                        ),
                      ),
                MySharedPreferences.isStudent
                    ? assignmentArgument.type == "Pending"
                        ? url.isNotEmpty
                            ? Container(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: CustomStyle.primaryColor,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          _launchURL(myWorkUrl);
                                        },
                                        child: ListTile(
                                          tileColor: Colors.grey,
                                          title: Text(
                                            "Attached Work",
                                            style: CustomStyle
                                                .customButtonTextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                          trailing: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                url = "";
                                              });
                                            },
                                            child: Icon(
                                              Icons.cancel_outlined,
                                              size: 35,
                                              color: CustomStyle.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 40,
                                    )
                                  ],
                                ),
                              )
                            : Row(children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: CustomStyle.primaryColor,
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      color: CustomStyle.textLight,
                                      icon: Icon(Icons.attach_file),
                                      onPressed: () {
                                        getPdfWork();
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Text(
                                  "Add Work",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ])
                        : Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: CustomStyle.primaryColor,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                _launchURL(mySubmittedUrl);
                                print(mySubmittedUrl +
                                    "''''''''''''''''''''''''''''''''''''''''''''''");
                              },
                              child: ListTile(
                                tileColor: Colors.grey,
                                title: Text(
                                  "Your Work",
                                  style: CustomStyle.customButtonTextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                trailing: GestureDetector(
                                  onTapDown: (data) {
                                    _getMyWorkUrl();
                                    CustomDialog.showDownloadDialog(context,
                                        data.globalPosition, mySubmittedUrl);
                                  },
                                  child: Icon(
                                    Icons.more_vert_rounded,
                                    size: 35,
                                    color: CustomStyle.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          )
                    : SizedBox(height: 10),
                SizedBox(
                  height: 40,
                ),
                MySharedPreferences.isStudent
                    ? submit == false
                        ? ElevatedButton(
                            style: CustomStyle.customElevatedButtonStyle(),
                            onPressed: () {
                              assignmentArgument.type == "Pending"
                                  ? submitAssignment()
                                  : _deleteWork();
                            },
                            child: Text(
                              assignmentArgument.type == "Pending"
                                  ? DataModel.SUBMIT
                                  : "Undo Submission ",
                              style: CustomStyle.customButtonTextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ))
                        : Center(
                            child: CircularProgressIndicator(),
                          )
                    : deadline == false
                        ? ElevatedButton(
                            style: CustomStyle.customElevatedButtonStyle(),
                            onPressed: () {
                              _selectDate();
                            },
                            child: Text(
                              "Change Deadline",
                              style: CustomStyle.customButtonTextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ))
                        : Center(
                            child: CircularProgressIndicator(),
                          )
              ],
            ),
          ),
        ));
  }
}
