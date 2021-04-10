import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iota/screens/professor/add_subjects.dart';
import 'package:iota/subjects/subject_tile.dart';
import 'package:iota/subjects/subject_tile_shimmer.dart';
import 'package:iota/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import '../../models/data_model.dart';
import '../../models/subject_model.dart';

class ProfessorMainScreen extends StatefulWidget {
  static const routeName = "/professor_main_screen";
  @override
  _ProfessorMainScreenState createState() => _ProfessorMainScreenState();
}

String professorName = "";
User user = FirebaseAuth.instance.currentUser;
String uid = user.uid;

//FirebaseFirestore.instance.collection("Faculty").doc(Uid).collection("MyData").
class _ProfessorMainScreenState extends State<ProfessorMainScreen> {
  @override

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: -5,
          title: Text("Home"),
          actions: [
            IconButton(
              onPressed: () {
              },
              icon: Icon(Icons.notification_important_sharp),
            ),
          ],
        ),
        body: FutureBuilder(
          future: Provider.of<SubjectProvider>(context, listen: false)
              .fetchmySubjects(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                itemCount: 10,
                itemBuilder: (ctx, index) => SubjectShimmerTile(),
              );
            } else if (dataSnapshot.hasError) {
              return Center(
                child: Text(DataModel.SOMETHING_WENT_WRONG),
              );
            } else {
              return Consumer<SubjectProvider>(
                builder: (ctx, subjectData, child) => RefreshIndicator(
                    child: ListView.builder(
                      itemCount: subjectData.getMySubjectsList.length,
                      itemBuilder: (ctx, index) => SubjectTile(
                        subject: subjectData.getMySubjectsList.toList()[index],
                      ),
                    ),
                    onRefresh: () {
                      return Provider.of<SubjectProvider>(context,
                              listen: false)
                          .fetchmySubjects();
                    }),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(AddSubjects.routeName);
            }),
        drawer: AppDrawer(DataModel.HOME));
  }
}

