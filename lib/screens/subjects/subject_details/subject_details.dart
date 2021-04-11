import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../dialog/custom_dialog.dart';
import '../../../models/shared_preferences.dart';
import '../../../models/subject_model.dart';
import '../../../styles.dart';

class SubjectDetails extends StatefulWidget {
  @override
  _SubjectDetailsState createState() => _SubjectDetailsState();
}

class _SubjectDetailsState extends State<SubjectDetails> {
  @override
  Widget build(BuildContext context) {
    //
    Subject subject = ModalRoute.of(context).settings.arguments;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          Hero(
            tag: subject.id,
            child: CircleAvatar(
              radius: 85,
              backgroundColor: CustomStyle.secondaryColor,
              child: CircleAvatar(
                backgroundColor: CustomStyle.primaryColor,
                radius: 78,
                child: Text(
                  subject.name.substring(0, 2).toUpperCase(),
                  style: TextStyle(
                      color: CustomStyle.backgroundColor,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 10),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          FutureBuilder(
            future: Subject.getFacultyNameFromFacultyId(subject.facultyId),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text(
                    "Faculty:  ${snapshot.data}",
                    style: CustomStyle.customButtonTextStyle(
                        size: 19, fontWeight: FontWeight.bold),
                  ),
                );
              } else {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                  child: FractionallySizedBox(
                    alignment: Alignment.topLeft,
                    widthFactor: 0.7,
                    child: Container(
                      margin: EdgeInsets.only(top: 5),
                      height: 14,
                      color: CustomStyle.primaryColor,
                    ),
                  ),
                );
              }
            },
          ),
          Divider(
            color: CustomStyle.secondaryColor,
            thickness: 1,
            endIndent: 50,
            indent: 50,
          ),
          Container(
            margin: EdgeInsets.fromLTRB(45, 6, 45, 6),
            child: Text(
              subject.description,
              softWrap: true,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, color: CustomStyle.primaryColor),
            ),
          ),
          Divider(
            color: CustomStyle.secondaryColor,
            thickness: 1,
            endIndent: 50,
            indent: 50,
          ),
          Container(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "BRANCHES ALLOWED:",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CustomStyle.primaryColor),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Card(
            color: CustomStyle.backgroundColor,
            elevation: 10,
            shadowColor: CustomStyle.secondaryColor,
            child: Container(
              width: MediaQuery.of(context).size.width - 100,
              height: 70,
              child: Center(
                child: RawScrollbar(
                  thumbColor: CustomStyle.secondaryColor,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: subject.branch.length,
                      itemBuilder: (ctx, index) {
                        return Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                  radius: 5,
                                  backgroundColor: Colors.black,
                                  child: Container()),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                subject.branch[index],
                                style: TextStyle(
                                    fontSize: 20,
                                    color: CustomStyle.primaryColor),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          FutureBuilder(
              future: Provider.of<SubjectProvider>(context, listen: false)
                  .checkIfEnrolledToASubjectUsingId(subject.id),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (MySharedPreferences.isStudent) {
                    if (snapshot.data == true) {
                      //  Student is enrolled
                      return ElevatedButton(
                        onPressed: () {
                          Provider.of<SubjectProvider>(context, listen: false)
                              .leaveSubject(
                                  subject,
                                  FirebaseAuth.instance.currentUser.uid,
                                  context)
                              .catchError((error) {
                            CustomDialog.generalErrorDialog(context: context);
                          }).then((value) {
                            setState(() {});
                          });
                        },
                        child: Text(
                          "LEAVE SUBJECT",
                          style: CustomStyle.customButtonTextStyle(
                              color: CustomStyle.textLight,
                              fontWeight: FontWeight.bold),
                        ),
                        style: CustomStyle.customElevatedButtonStyle(
                            isError: true),
                      );
                    } else {
                      //  Student is not enrolled
                      // Check if pending or not
                      return FutureBuilder(
                          future: Provider.of<SubjectProvider>(context,
                                  listen: false)
                              .checkIfSubjectJoinPermissionIsPending(subject,
                                  FirebaseAuth.instance.currentUser.uid),
                          builder: (ctx, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.data == true) {
                                return ElevatedButton(
                                  onPressed: () {
                                    Provider.of<SubjectProvider>(context,
                                            listen: false)
                                        .removeSubjectJoinRequest(
                                            subject,
                                            FirebaseAuth
                                                .instance.currentUser.uid)
                                        .catchError((error) {
                                      CustomDialog.generalErrorDialog(
                                          context: context);
                                    }).then((value) {
                                      setState(() {});
                                    });
                                  },
                                  child: Text(
                                    "CANCEL REQUEST",
                                    style: CustomStyle.customButtonTextStyle(
                                        color: CustomStyle.textLight,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  style:
                                      CustomStyle.customElevatedButtonStyle(),
                                );
                              } else {
                                return ElevatedButton(
                                  onPressed: () {
                                    Provider.of<SubjectProvider>(context,
                                            listen: false)
                                        .joinSubjectByPermission(
                                            subject,
                                            FirebaseAuth
                                                .instance.currentUser.uid,
                                            FirebaseAuth.instance.currentUser
                                                .displayName)
                                        .catchError((error) {
                                      CustomDialog.generalErrorDialog(
                                          context: context);
                                    }).then((value) {
                                      setState(() {});
                                    });
                                  },
                                  child: Text(
                                    "JOIN SUBJECT",
                                    style: CustomStyle.customButtonTextStyle(
                                        color: CustomStyle.textLight,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  style:
                                      CustomStyle.customElevatedButtonStyle(),
                                );
                              }
                            } else {
                              return CircularProgressIndicator();
                            }
                          });
                    }
                  } else {
                    //  User is a faculty, nothing too be shown
                    return Container();
                  }
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
