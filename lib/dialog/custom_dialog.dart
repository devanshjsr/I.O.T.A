import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../models/auth_provider.dart';
import '../models/subject_model.dart';
import '../services/dynamic_link_service.dart';
import '../styles.dart';

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
}
