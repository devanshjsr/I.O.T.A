import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/assignment_model.dart';
import '../../../models/data_model.dart';
import '../../../models/shared_preferences.dart';
import '../../../models/subject_model.dart';
import '../../../styles.dart';
import '../../assignments/add_assignments.dart';
import '../../assignments/assignment_tile.dart';

class SubjectAssignment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Subject subject = ModalRoute.of(context).settings.arguments;

    Widget getExpansionTile(Subject subject) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ExpansionTile(
                title: Text(
                  "OnGoing",
                  style: CustomStyle.customButtonTextStyle(
                      fontWeight: FontWeight.bold),
                ),
                trailing: Icon(
                  Icons.arrow_drop_down,
                  size: 35,
                  color: CustomStyle.primaryColor,
                ),
                children: [
                  FutureBuilder(
                    future:
                        Provider.of<AssignmentProvider>(context, listen: false)
                            .fetchAssignmentsProfessor(subject),
                    builder: (ctx, datasnapshot) {
                      if (datasnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return SizedBox(
                          height: 80,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (datasnapshot.connectionState ==
                          ConnectionState.done) {
                        return Consumer<AssignmentProvider>(
                          builder: (ctx, assignmentData, child) =>
                              RefreshIndicator(
                            onRefresh: () {
                              return Provider.of<AssignmentProvider>(context,
                                      listen: false)
                                  .fetchAssignmentsProfessor(subject);
                            },
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 250,
                                minHeight: 30,
                              ),
                              child:
                                  assignmentData.getOngoingAssignment.length ==
                                          0
                                      ? Text(
                                          "NO ASSIGNMENTS",
                                          style: TextStyle(
                                            color: CustomStyle.primaryColor,
                                            fontSize: 16,
                                          ),
                                        )
                                      : ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemCount: assignmentData
                                              .getOngoingAssignment.length,
                                          itemBuilder: (ctx, index) =>
                                              AssignmentTile(
                                            assignment: assignmentData
                                                .getOngoingAssignment
                                                .toList()[index],
                                            type: "onGoing",
                                          ),
                                        ),
                            ),
                          ),
                        );
                      } else {
                        return Center(
                            child: Text(DataModel.SOMETHING_WENT_WRONG));
                      }
                    },
                  ),
                ]),
            ExpansionTile(
                title: Text(
                  "Completed",
                  style: CustomStyle.customButtonTextStyle(
                      fontWeight: FontWeight.bold),
                ),
                trailing: Icon(
                  Icons.arrow_drop_down,
                  size: 35,
                  color: CustomStyle.primaryColor,
                ),
                children: [
                  FutureBuilder(
                    future:
                        Provider.of<AssignmentProvider>(context, listen: false)
                            .fetchAssignmentsProfessor(subject),
                    builder: (ctx, datasnapshot) {
                      if (datasnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return SizedBox(
                          height: 80,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (datasnapshot.connectionState ==
                          ConnectionState.done) {
                        return Consumer<AssignmentProvider>(
                          builder: (ctx, assignmentData, child) =>
                              RefreshIndicator(
                            onRefresh: () {
                              return Provider.of<AssignmentProvider>(context,
                                      listen: false)
                                  .fetchAssignmentsProfessor(subject);
                            },
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 250,
                                minHeight: 30,
                              ),
                              child: assignmentData
                                          .getCompletedAssignment.length ==
                                      0
                                  ? Text(
                                      "NO ASSIGNMENTS",
                                      style: TextStyle(
                                        color: CustomStyle.primaryColor,
                                        fontSize: 16,
                                      ),
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: assignmentData
                                          .getCompletedAssignment.length,
                                      itemBuilder: (ctx, index) =>
                                          AssignmentTile(
                                        assignment: assignmentData
                                            .getCompletedAssignment
                                            .toList()[index],
                                        type: "Completed Professor",
                                      ),
                                    ),
                            ),
                          ),
                        );
                      } else {
                        return Center(
                            child: Text(DataModel.SOMETHING_WENT_WRONG));
                      }
                    },
                  ),
                ]),
          ],
        ),
      );
    }

    Widget getExpansionTileStudent(Subject subject) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ExpansionTile(
                title: Text(
                  "Assigned",
                  style: CustomStyle.customButtonTextStyle(
                      fontWeight: FontWeight.bold),
                ),
                trailing: Icon(
                  Icons.arrow_drop_down,
                  size: 35,
                  color: CustomStyle.primaryColor,
                ),
                children: [
                  FutureBuilder(
                    future:
                        Provider.of<AssignmentProvider>(context, listen: false)
                            .fetchAssignmentStudent(subject),
                    builder: (ctx, datasnapshot) {
                      if (datasnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return SizedBox(
                          height: 80,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (datasnapshot.connectionState ==
                          ConnectionState.done) {
                        return Consumer<AssignmentProvider>(
                          builder: (ctx, assignmentData, child) =>
                              RefreshIndicator(
                            onRefresh: () {
                              return Provider.of<AssignmentProvider>(context,
                                      listen: false)
                                  .fetchAssignmentStudent(subject);
                            },
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 250,
                                minHeight: 30,
                              ),
                              child:
                                  assignmentData.getPendingAssignment.length ==
                                          0
                                      ? Text(
                                          "NO ASSIGNMENTS",
                                          style: TextStyle(
                                            color: CustomStyle.primaryColor,
                                            fontSize: 16,
                                          ),
                                        )
                                      : ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemCount: assignmentData
                                              .getPendingAssignment.length,
                                          itemBuilder: (ctx, index) =>
                                              AssignmentTile(
                                            assignment: assignmentData
                                                .getPendingAssignment
                                                .toList()[index],
                                            type: "Pending",
                                          ),
                                        ),
                            ),
                          ),
                        );
                      } else {
                        return Center(
                            child: Text(DataModel.SOMETHING_WENT_WRONG));
                      }
                    },
                  ),
                ]),
            ExpansionTile(
                title: Text(
                  "Completed",
                  style: CustomStyle.customButtonTextStyle(
                      fontWeight: FontWeight.bold),
                ),
                trailing: Icon(
                  Icons.arrow_drop_down,
                  size: 35,
                  color: CustomStyle.primaryColor,
                ),
                children: [
                  FutureBuilder(
                    future:
                        Provider.of<AssignmentProvider>(context, listen: false)
                            .fetchAssignmentStudent(subject),
                    builder: (ctx, datasnapshot) {
                      if (datasnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return SizedBox(
                          height: 80,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (datasnapshot.connectionState ==
                          ConnectionState.done) {
                        return Consumer<AssignmentProvider>(
                          builder: (ctx, assignmentData, child) =>
                              RefreshIndicator(
                            onRefresh: () {
                              return Provider.of<AssignmentProvider>(context,
                                      listen: false)
                                  .fetchAssignmentStudent(subject);
                            },
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 250,
                                minHeight: 30,
                              ),
                              child: assignmentData
                                          .getSubmittedAssignment.length ==
                                      0
                                  ? Text(
                                      "NO ASSIGNMENTS",
                                      style: TextStyle(
                                        color: CustomStyle.primaryColor,
                                        fontSize: 16,
                                      ),
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: assignmentData
                                          .getSubmittedAssignment.length,
                                      itemBuilder: (ctx, index) =>
                                          AssignmentTile(
                                        assignment: assignmentData
                                            .getSubmittedAssignment
                                            .toList()[index],
                                        type: "Completed",
                                      ),
                                    ),
                            ),
                          ),
                        );
                      } else {
                        return Center(
                            child: Text(DataModel.SOMETHING_WENT_WRONG));
                      }
                    },
                  ),
                ]),
          ],
        ),
      );
    }

    if (MySharedPreferences.isStudent) {
      return Scaffold(
        body: getExpansionTileStudent(subject),
      );
    } else {
      return Scaffold(
        body: getExpansionTile(subject),
        floatingActionButton: SizedBox(
          width: 65,
          height: 95,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(AddAssignment.routeName, arguments: subject);
            },
            child: Icon(
              Icons.add,
              size: 35,
            ),
            hoverColor: CustomStyle.primaryColor,
            backgroundColor: CustomStyle.primaryColor,
          ),
        ),
      );
    }
  }
}
