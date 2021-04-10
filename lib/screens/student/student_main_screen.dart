import 'package:flutter/material.dart';
import 'package:iota/dialog/custom_dialog.dart';
import 'package:iota/models/data_model.dart';
import 'package:iota/models/subject_model.dart';
import 'package:iota/screens/student/custom_fab.dart';
import 'package:iota/screens/subjects/subject_search.dart';
import 'package:iota/screens/subjects/subject_tile_shimmer.dart';
import 'package:iota/subjects/subject_tile.dart';
import 'package:iota/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import '../../models/auth_provider.dart';

class StudentMainScreen extends StatelessWidget {
  static const routeName = "/student_main_screen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DataModel.HOME),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(SubjectSearchScreen.routeName);
            },
            icon: Icon(Icons.search),
          ),
        
      ],),
      body:  FutureBuilder(
        future: Provider.of<SubjectProvider>(context, listen: false)
            .fetchMyEnrolledSubjects(),
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
              builder: (ctx, subjectData, child) => RefreshIndicator(
                onRefresh: () {
                  return Provider.of<SubjectProvider>(context, listen: false)
                      .fetchMyEnrolledSubjects();
                },
                child: ListView.builder(
                  itemCount: subjectData.getMyEnrolledSubjectsList.length,
                  itemBuilder: (ctx, index) => SubjectTile(
                    subject:
                        subjectData.getMyEnrolledSubjectsList.toList()[index],
                  ),
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: CustomFAB(),
      drawer: AppDrawer(DataModel.HOME),
    );
  }
}
