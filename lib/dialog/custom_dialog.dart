import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iota/assignment/view_assignment.dart';
import 'package:iota/assignment/view_assignment_argument.dart';
import 'package:iota/assignment/view_submission.dart';
import 'package:iota/models/assignment_model.dart';
import 'package:iota/models/data_model.dart';
import 'package:iota/models/room_model.dart';
import 'package:iota/screens/room/add_students.dart';
import 'package:iota/screens/room/remove_member.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_provider.dart';
import '../models/subject_model.dart';
import '../services/dynamic_link_service.dart';
import '../styles.dart';
import 'package:url_launcher/url_launcher.dart';
//  Class to store all the custom error-dialog to reduce boilerplate code
class CustomDialog {
  //  General error dialog if anything goes wrong
  static Future<void> generalErrorDialog({
    BuildContext context,
    String title = "Something went wrong",
    String content = "Please try again later",
  }) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
              fontSize: 15,
              color: CustomStyle.errorColor,
              fontWeight: FontWeight.bold),
        ),
        content: Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: CustomStyle.errorColor,
          ),
        ),
        actions: [
          ElevatedButton(
            style: CustomStyle.customElevatedButtonStyle(isError: true),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "OKAY",
              style: TextStyle(
                color: CustomStyle.textLight,
              ),
            ),
          )
        ],
      ),
    );
  }

  //  Options to be shown to student and faculty when clicking on options/long press on subject tile
  static void showOptionDialog(
      BuildContext context, Subject subject, bool isStudent, Offset offset) {
    double left = offset.dx;
    double top = offset.dy;
    List<PopupMenuEntry<int>> options = isStudent
        ? [
            PopupMenuItem(
              value: 2,
              textStyle: TextStyle(color: CustomStyle.errorColor),
              child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text("Leave")),
            ),
          ]
        : [
            PopupMenuItem(
              value: 1,
              child: GestureDetector(
                  onTap: () {
                    subjectShareDialog(context, subject, false);
                  },
                  child: Text("Share")),
            ),
            PopupMenuItem(
              value: 2,
              child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text("Edit")),
            ),
            PopupMenuItem(
              value: 3,
              textStyle: TextStyle(color: CustomStyle.errorColor),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Text("Delete"),
              ),
            ),
          ];
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 10, 10),
      items: options,
    );
  }

  //Dialog for sharing subject via subject code

  static Future subjectShareDialog(
      BuildContext context, Subject subject, bool insideSettings) async {
    String shareLink = "";
    void shareSubject(bool isCode, String data) async {
      String shareString;
      shareString = isCode
          ? "Join my subject '${subject.name}' using the following code:\n$data"
          : "Join my subject '${subject.name}' using the following link: \n$data";
      Share.share(shareString).then((value) {
        Navigator.of(context).pop();
        if (!insideSettings) {
          Navigator.of(context).pop();
        }
      });
    }

    void copyToClipboard(bool isCode, String data) async {
      String shareString;
      shareString = isCode
          ? "Join my subject '${subject.name}' using the following code:\n$data"
          : "Join my subject '${subject.name}' using the following link: \n$data";

      Clipboard.setData(ClipboardData(text: shareString)).then((value) {
        Fluttertoast.showToast(msg: "Copied to clipboard");
        Navigator.of(context).pop();
        if (!insideSettings) {
          Navigator.of(context).pop();
        }
      });
    }

    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              "SHARE SUBJECT",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: CustomStyle.primaryColor),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Subject code: ${subject.subjectCode}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: CustomStyle.primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: CustomStyle.primaryColor,
                      ),
                      child: IconButton(
                        color: CustomStyle.textLight,
                        icon: Icon(Icons.share_sharp),
                        onPressed: () {
                          shareSubject(true, subject.subjectCode);
                        },
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: CustomStyle.primaryColor,
                      ),
                      child: IconButton(
                        color: CustomStyle.textLight,
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          copyToClipboard(true, subject.subjectCode);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder(
                    future: DynamicLinkService.createDynamicLink(subject),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        shareLink = snapshot.data.toString();
                        return Expanded(
                          child: Text(
                            "Subject link: ${snapshot.data.toString()}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: CustomStyle.primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      } else {
                        return Text(
                          "Loading link...",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: CustomStyle.primaryColor,
                              fontWeight: FontWeight.bold),
                        );
                      }
                    },
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: CustomStyle.primaryColor,
                      ),
                      child: IconButton(
                        color: CustomStyle.textLight,
                        icon: Icon(Icons.share_sharp),
                        onPressed: () {
                          shareSubject(false, shareLink);
                        },
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: CustomStyle.primaryColor,
                      ),
                      child: IconButton(
                        color: CustomStyle.textLight,
                        icon: Icon(Icons.copy),
                        onPressed: () {
                          copyToClipboard(false, shareLink);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

   static Future showJoinDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    // Map<String, String> _docRef = {
    //   'subject_code': "",
    // };
    String subjectCode = "";
    final String name = FirebaseAuth.instance.currentUser.displayName;
    final String uid = FirebaseAuth.instance.currentUser.uid;
    addMyEnrolledSubjects() {
      final isValid = _formKey.currentState.validate();
      if (isValid) {
        _formKey.currentState.save();
        Provider.of<SubjectProvider>(context, listen: false)
            .joinSubjectUsingCode(subjectCode, name, uid)
            .catchError((error) {
          String snackBarContent;
          if (error == "NOT FOUND") {
            snackBarContent = 'Invalid code, no subject found';
          } else {
            snackBarContent = 'Some error occured, please try again later';
          }
          final snackBar = SnackBar(
            content: Text(
              snackBarContent,
              style: TextStyle(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            backgroundColor: CustomStyle.errorColor,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }).then((value) => Navigator.of(context).pop());
      }
    }
  return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              "Enter Subject Code for joining the team",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: CustomStyle.primaryColor),
            ),
            content: Form(
              key: _formKey,
              child: TextFormField(
                autofocus: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                decoration: CustomStyle.customTextFieldDecoration(
                    labelText: DataModel.ENTERCODE),
                validator: (value) {
                  if (value == null || value.trim() == "")
                    return DataModel.REQUIRED;
                  if (value.length != 6) return DataModel.LENGTHSIX;
                  return null;
                },
                onSaved: (value) {
                  subjectCode = value;
                  // _docRef['subject_code'] = value;
                },
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      child: Text("Okay"),
                      onPressed: () {
                        addMyEnrolledSubjects();
                      },
                      style: CustomStyle.customElevatedButtonStyle(),
                    ),
                    ElevatedButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                      style: CustomStyle.customElevatedButtonStyle(),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }


  //  Alert dialog to send password verification link to email
  static Future<bool> resetPasswordDialog(BuildContext context) async {
    final _textController = TextEditingController();
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Forgot password?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content:
              const Text("Enter your e-mail to receive password reset link."),
          actions: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: TextField(
                decoration:
                    CustomStyle.customTextFieldDecoration(labelText: "E-mail"),
                controller: _textController,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: CustomStyle.customElevatedButtonStyle(),
                    onPressed: () {
                      if (_textController.text.trim() == "") {
                        Fluttertoast.showToast(msg: "Please provide email");
                        return;
                      }
                      Provider.of<AuthProvider>(context, listen: false)
                          .resetPassword(_textController.text)
                          .then((value) {
                        Navigator.of(context).pop(true);
                      });
                    },
                    child: const Text("CONFIRM"),
                  ),
                  ElevatedButton(
                    style: CustomStyle.customElevatedButtonStyle(isError: true),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("CANCEL"),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

   static void showAssignmentDialog(
      BuildContext context, Offset offset, Assignment assignment, String type) {
    double left = offset.dx;
    double top = offset.dy;

    List<PopupMenuEntry<int>> options = [
      PopupMenuItem(
        value: 1,
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(ViewAssignment.routeName,
                  arguments:
                      AssignmentArgument(assignment: assignment, type: type));
            },
            child: Text("View Assignment")),
      ),
      PopupMenuItem(
        value: 2,
        child: GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pushNamed(ViewSubmission.routeName, arguments: assignment);
            },
            child: Text("Submissions")),
      ),
    ];

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 10, 10),
      items: options,
    );
  }
 static void showDownloadDialog(
      BuildContext context, Offset offset, String url) {
    double left = offset.dx;
    double top = offset.dy;

    List<PopupMenuEntry<int>> options = [
      PopupMenuItem(
        value: 1,
        child: GestureDetector(
            onTap: () async {
              await canLaunch(url)
                  ? await launch(url)
                  : throw 'Could not launch $url';
            },
            child: Text("Download Assignment")),
      ),
    ];

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 10, 10),
      items: options,
    );
  }
  
  static void showRoomOptionDialog(
      BuildContext context, Offset offset, Room room) {
    double left = offset.dx;
    double top = offset.dy;

    List<PopupMenuEntry<int>> options = [
      PopupMenuItem(
        value: 1,
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushNamed(AddStudents.routeName, arguments: room);
            },
            child: Text("Add Member")),
      ),
      PopupMenuItem(
        value: 1,
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushNamed(RemoveMember.routeName, arguments: room);
            },
            child: Text("Remove Member")),
      ),
      PopupMenuItem(
        value: 1,
        child: GestureDetector(
            onTap: () async {
              await Provider.of<RoomProvider>(context, listen: false)
                  .removeRoom(room);
              Navigator.of(context).pop();
            },
            child: Text("Remove Room")),
      ),
    ];
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 10, 10),
      items: options,
    );
  }

}
