import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/subject_model.dart';
import 'subject_tile.dart';

class SubjectSearchScreen extends StatefulWidget {
  static const routeName = "/subject_search_screen";
  @override
  _SubjectSearchScreenState createState() => _SubjectSearchScreenState();
}

class _SubjectSearchScreenState extends State<SubjectSearchScreen> {
  String name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: 'Search...'),
          onChanged: (val) {
            setState(() {
              name = val.toLowerCase().trim();
            });
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Provider.of<SubjectProvider>(context, listen: false)
            .getSubjectsOnSearch(name),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else {
            if (name.trim() == "")
              return Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    "Search for a subject",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ));
            if (snapshot.data.docs.length == 0)
              return Container(
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    "No subjects found",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ));
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot data = snapshot.data.docs[index];

                return SubjectTile(
                  subject: Subject(
                    name: data['subject_name'],
                    branch: Subject.extractBranchFromString(data['branch']),
                    description: data['des'],
                    facultyId: data['faculty_id'],
                    id: data.id,
                    subjectCode: data['subject_code'],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
