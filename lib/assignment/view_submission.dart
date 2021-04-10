import 'package:flutter/material.dart';
import 'package:iota/assignment/submission_tile.dart';
import 'package:iota/models/assignment_model.dart';
import 'package:iota/models/data_model.dart';
import 'package:iota/subjects/subject_tile_shimmer.dart';
import 'package:provider/provider.dart';

class ViewSubmission extends StatelessWidget {
  static final routeName = "/viewSubmission";
  @override
  Widget build(BuildContext context) {

    Assignment assignment = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
          titleSpacing: -5,
          title: Text("Submissions "),
      ),
      body: FutureBuilder(
          future: Provider.of<AssignmentProvider>(context,listen: false).fetchSubmittedAssignments(assignment),
          builder: (ctx,datasnapshot){
            if(datasnapshot.connectionState == ConnectionState.waiting){
              return ListView.builder(
              itemCount: 10,
              itemBuilder: (ctx, index) => SubjectShimmerTile(),
            );
            }else if(datasnapshot.connectionState == ConnectionState.done){
              return Consumer<AssignmentProvider>(
              builder: (ctx, assignmentData, child) => RefreshIndicator(
                onRefresh: () {
                  return Provider.of<AssignmentProvider>(context, listen: false)
                      .fetchSubmittedAssignments(assignment);
                },
                child: Container (
                  height: 250,
                child : ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: assignmentData.getSubmittedAssignmentProfessor.length,
                  itemBuilder: (ctx, index) => SubmissionTile(
                    submission :
                        assignmentData.getSubmittedAssignmentProfessor.toList()[index],
                  ),
                ),
              ),
              ),
            );
            }else {
              return Center(
              child: Text(DataModel.SOMETHING_WENT_WRONG));
            }
          },
        ),
      );
  }
}