import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dialog/custom_dialog.dart';
import '../../models/subject_model.dart';
import '../../styles.dart';
import '../student/student_profile_view.dart';

//  Screen to display all pending requests to join subjects
class ApproveJoinRequests extends StatefulWidget {
  static const routeName = "/approve_join_requests_screen";

  @override
  _ApproveJoinRequestsState createState() => _ApproveJoinRequestsState();
}

class _ApproveJoinRequestsState extends State<ApproveJoinRequests> {
  @override
  Widget build(BuildContext context) {
    Widget getExpansionTile(Subject subject) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: CustomStyle.subjectTileStyle(),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: ExpansionTile(
          leading: CircleAvatar(
            radius: 35,
            backgroundColor: CustomStyle.secondaryColor,
            child: CircleAvatar(
              backgroundColor: CustomStyle.primaryColor,
              radius: 25,
              child: Text(
                subject.name.substring(0, 2).toUpperCase(),
                style: TextStyle(
                    color: CustomStyle.backgroundColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
            ),
          ),
          title: Text(
            subject.name,
            style:
                CustomStyle.customButtonTextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Icon(
            Icons.arrow_drop_down,
            size: 35,
            color: CustomStyle.primaryColor,
          ),
          children: [
            FutureBuilder(
                future: Provider.of<SubjectProvider>(context)
                    .fetchPendingRequestsForSubject(subject),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<Map<String, String>> data = snapshot.data;
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 250,
                        minHeight: 30,
                      ),
                      child: data.length == 0
                          ? Text(
                              "NO REQUESTS",
                              style: TextStyle(
                                color: CustomStyle.primaryColor,
                                fontSize: 16,
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: data.length,
                              itemBuilder: (ctx, index) => Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                color:
                                    CustomStyle.primaryColor.withOpacity(0.05),
                                child: ListTile(
                                  title: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      data[index]["student name"],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  subtitle: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      IconButton(
                                        color: Colors.transparent,
                                        icon: Icon(
                                          Icons.done_all,
                                          color: Colors.green,
                                        ),
                                        iconSize: 35,
                                        onPressed: () {
                                          Provider.of<SubjectProvider>(context,
                                                  listen: false)
                                              .respondToJoinRequest(
                                                  subject,
                                                  data[index]["student id"],
                                                  true,
                                                  data[index]["student name"],
                                                  context)
                                              .catchError(
                                            (error) {
                                              CustomDialog.generalErrorDialog(
                                                  context: context);
                                            },
                                          ).then((value) {
                                            setState(() {});
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.person,
                                          color: CustomStyle.primaryColor,
                                        ),
                                        iconSize: 35,
                                        onPressed: () {
                                          StudentProfileView.showStudentProfile(
                                              data[index]["student id"],
                                              context);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.dnd_forwardslash,
                                          color: CustomStyle.errorColor,
                                        ),
                                        iconSize: 35,
                                        onPressed: () {
                                          Provider.of<SubjectProvider>(context,
                                                  listen: false)
                                              .respondToJoinRequest(
                                                  subject,
                                                  data[index]["student id"],
                                                  false,
                                                  data[index]["student name"],
                                                  context)
                                              .catchError(
                                            (error) {
                                              CustomDialog.generalErrorDialog(
                                                  context: context);
                                            },
                                          ).then((value) {
                                            setState(() {});
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    );
                  } else {
                    return Container(
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                })
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Approve requests"),
      ),
      body: Consumer<SubjectProvider>(
        builder: (ctx, subjectData, child) => RefreshIndicator(
            child: ListView.builder(
              itemCount: subjectData.getMySubjectsList.length,
              itemBuilder: (ctx, index) => getExpansionTile(
                subjectData.getMySubjectsList.toList()[index],
              ),
            ),
            onRefresh: () {
              return Provider.of<SubjectProvider>(context, listen: false)
                  .fetchmySubjects();
            }),
      ),
    );
  }
}
