import 'package:flutter/material.dart';

import '../../../dialog/custom_dialog.dart';
import '../../../models/subject_model.dart';
import '../../../styles.dart';

class SubjectSettings extends StatefulWidget {
  static const routeName = "/subject_settings";

  @override
  _SubjectSettingsState createState() => _SubjectSettingsState();
}

class _SubjectSettingsState extends State<SubjectSettings> {
  bool isLoading;

  @override
  void initState() {
    isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //  subject fetched through modalroute
    Subject subject = ModalRoute.of(context).settings.arguments;

    //  Method to share subject
    void shareSubject() async {
      setState(() {
        isLoading = true;
      });
      CustomDialog.subjectShareDialog(context, subject, true);
      setState(() {
        isLoading = false;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      backgroundColor: CustomStyle.backgroundColor,
      body: Container(
        margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height / 4),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        //color: CustomStyle.secondaryColor,
                        backgroundColor: CustomStyle.backgroundColor,
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 25),
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Icon(
                          Icons.share,
                          color: CustomStyle.primaryColor,
                        ),
                        onPressed: () {
                          shareSubject();
                        },
                        style: CustomStyle.customOutlinedButtonStyle(),
                        label: Text(
                          "SHARE SUBJECT",
                          style: CustomStyle.customButtonTextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: Icon(
                    Icons.edit,
                    color: CustomStyle.primaryColor,
                  ),
                  onPressed: () {},
                  style: CustomStyle.customOutlinedButtonStyle(),
                  label: Text(
                    "EDIT SUBJECT",
                    style: CustomStyle.customButtonTextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25),
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: Icon(
                    Icons.delete_outline_outlined,
                    color: CustomStyle.errorColor,
                  ),
                  onPressed: () {},
                  style: CustomStyle.customOutlinedButtonStyle(isError: true),
                  label: Text(
                    "DELETE SUBJECT",
                    style: CustomStyle.customButtonTextStyle(
                        fontWeight: FontWeight.bold,
                        color: CustomStyle.errorColor),
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
