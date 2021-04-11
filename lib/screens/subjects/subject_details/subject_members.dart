import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/data_model.dart';
import '../../../models/subject_model.dart';
import '../member_tile.dart';
import '../subject_tile_shimmer.dart';

class SubjectMembers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Subject subject = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      body: FutureBuilder(
        future: Provider.of<SubjectProvider>(context, listen: false)
            .fetchEnrolledStudents(subject.id),
        builder: (ctx, dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 10,
              itemBuilder: (ctx, index) => SubjectShimmerTile(),
            );
          } else if (dataSnapShot.hasError) {
            return Center(
              child: Text(DataModel.SOMETHING_WENT_WRONG),
            );
          } else {
            //  Using consumer here as if we use provider here, whole stateless widget gets
            //  re-rendered again, and we enter an infinite loop
            return Consumer<SubjectProvider>(
              builder: (ctx, memberData, child) => RefreshIndicator(
                onRefresh: () {
                  return Provider.of<SubjectProvider>(context, listen: false)
                      .fetchEnrolledStudents(subject.id);
                },
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 5, top: 15),
                      child: Text(
                        memberData.getmyEnrolledStudents.length > 1
                            ? "${memberData.getmyEnrolledStudents.length} STUDENTS ENROLLED"
                            : "${memberData.getmyEnrolledStudents.length} STUDENT ENROLLED",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: memberData.getmyEnrolledStudents.length,
                          itemBuilder: (ctx, index) => MemberTile(
                                member: memberData.getmyEnrolledStudents
                                    .toList()[index],
                              )),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
