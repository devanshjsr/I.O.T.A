import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../models/auth_provider.dart';
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
