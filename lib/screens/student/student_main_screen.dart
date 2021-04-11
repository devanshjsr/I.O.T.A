import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/data_model.dart';
import '../../models/subject_model.dart';
import '../../services/dynamic_link_service.dart';
import '../../widgets/app_drawer.dart';
import '../subjects/subject_search.dart';
import '../subjects/subject_tile.dart';
import '../subjects/subject_tile_shimmer.dart';
import 'custom_fab.dart';

class StudentMainScreen extends StatefulWidget {
  static const routeName = "/student_main_screen";

  @override
  _StudentMainScreenState createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  @override
  void initState() {
    DynamicLinkService.initDynamicLinks(context);
    super.initState();
  }

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
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<SubjectProvider>(context, listen: false)
            .fetchMyEnrolledSubjects(context),
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
                      .fetchMyEnrolledSubjects(context);
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
