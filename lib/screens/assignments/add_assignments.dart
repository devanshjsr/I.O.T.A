import 'dart:io' as FileView;
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/assignment_model.dart';
import '../../models/data_model.dart';
import '../../models/subject_model.dart';
import '../../styles.dart';

class AddAssignment extends StatefulWidget {
  static final routeName = "/addAssignment";

  @override
  _AddAssignmentState createState() => _AddAssignmentState();
}

class _AddAssignmentState extends State<AddAssignment> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  DateTime currentDate = DateTime.now();

  var currentTime = TimeOfDay.now();

  String deadline = "Select Deadline";

  Uri url;
  FileView.File file;
  String fileName = "";

  String myUrl = "";

  final Map<String, String> _assignment = {
    "name": "",
    "description": "",
    "due date": "",
    "url_of_question_pdf": "",
  };

  Future<void> _selectDate(BuildContext context) async {
    print(currentDate);
    var pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2015),
        lastDate: DateTime(2050));
    if (pickedDate != null) currentDate = pickedDate;
    _selectTime(context);
  }

  Future<void> _selectTime(BuildContext context) async {
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
        deadline = currentDate.toString().substring(0, 10) +
            " " +
            currentTime.toString().substring(10, 15);
        _assignment["due date"] = pickedDateTime.toIso8601String();
        print(deadline);
      });
    }
  }

  Future getPdfUpload() async {
    var rng = new Random();
    String randomName = "";

    for (var i = 0; i < 20; i++) {
      print(rng.nextInt(100));
      randomName += rng.nextInt(100).toString();
    }
    file = await FilePicker.getFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc'],
    );

    fileName = '${randomName}.pdf';
    print(fileName);

    setState(() {
      url = file.uri;
      myUrl = file.uri.toString();
    });

    print('${file.readAsBytesSync()}');
  }

  @override
  Widget build(BuildContext context) {
    Subject subject = ModalRoute.of(context).settings.arguments;

    void addAssignment() async {
      final isValid = _formKey.currentState.validate();
      if (isValid) {
        _formKey.currentState.save();
        if (deadline == "Select Deadline") {
          Fluttertoast.showToast(
              msg: DataModel.ADD_DEADLINE,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          try {
            setState(() {
              isLoading = true;
            });

            List<int> asset = [];
            if (file != null) {
              asset = file.readAsBytesSync();
            }
            Provider.of<AssignmentProvider>(context, listen: false)
                .uploadAssignment(subject, _assignment, asset, fileName);

            setState(() {
              isLoading = false;
            });

            Fluttertoast.showToast(
                msg: DataModel.ASSIGNMENT_TOAST,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);

            Navigator.of(context).pop();
          } catch (error) {
            throw error;
          }
        }
      }
    }

    void _launchURL() async => await canLaunch(myUrl)
        ? await launch(myUrl)
        : throw 'Could not launch $url ';

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Enter assignment details:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CustomStyle.primaryColor,
                      ),
                    ),
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    decoration: CustomStyle.customTextFieldDecoration(
                        labelText: DataModel.ASSIGNMENT_TITLE),
                    validator: (value) {
                      if (value == null || value.trim() == "")
                        return DataModel.REQUIRED;
                      return null;
                    },
                    onSaved: (value) {
                      _assignment["name"] = value;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    decoration: CustomStyle.customTextFieldDecoration(
                        labelText: DataModel.ASSIGNMENT_DESCRIPTION),
                    onSaved: (value) {
                      _assignment["description"] = value;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: CustomStyle.primaryColor,
                      ),
                      child: IconButton(
                        color: CustomStyle.textLight,
                        icon: Icon(Icons.timelapse),
                        onPressed: () {
                          _selectDate(context);
                        },
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      child: Text(
                        deadline,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ]),
                  SizedBox(
                    height: 15,
                  ),
                  myUrl.isEmpty
                      ? Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: CustomStyle.primaryColor,
                              ),
                              child: IconButton(
                                color: CustomStyle.textLight,
                                icon: Icon(Icons.attach_file),
                                onPressed: () {
                                  getPdfUpload();
                                },
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              child: Text(
                                "Attach File",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: CustomStyle.primaryColor,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _launchURL();
                            },
                            child: ListTile(
                              tileColor: Colors.grey,
                              title: Text(
                                "Attached Assignment",
                                style: CustomStyle.customButtonTextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    myUrl = "";
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
                    height: 15,
                  ),
                  if (isLoading == false)
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: CustomStyle.customElevatedButtonStyle(),
                        onPressed: () {
                          addAssignment();
                        },
                        child: Text(
                          DataModel.UPLOAD,
                          style: CustomStyle.customButtonTextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (isLoading == true)
                    Center(
                      child: CircularProgressIndicator(),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
