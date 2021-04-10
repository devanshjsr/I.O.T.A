import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class Subject {
  final String id;
  final String name;
  final String description;
  final String facultyId;
  final String subjectCode;
  final List<String> branch;

  Subject({
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.facultyId,
    @required this.branch,
    @required this.subjectCode,
  });

  static List<Map<String, String>> branchNames = [
    {
      "display": "CSE",
      "value": "CSE",
    },
    {
      "display": "IT",
      "value": "IT",
    },
    {
      "display": "ECE",
      "value": "ECE",
    },
    {
      "display": "EE",
      "value": "EE",
    },
    {
      "display": "ME",
      "value": "ME",
    },
    {
      "display": "CHEM",
      "value": "CHEM",
    },
    {
      "display": "Civil",
      "value": "Civil",
    },
    {
      "display": "PIE",
      "value": "PIE",
    },
    {
      "display": "Bio-Tech",
      "value": "Bio-Tech",
    }
  ];
  
  static List<String> extractBranchFromString(String str) {
    if (str == null) {
      return [];
    }
    var subjects = str.split(",");
    //  blank entry check
    subjects.removeWhere((element) => element.trim() == "");
    return subjects;
  }


  static Future<String> getFacultyNameFromFacultyId(String facultyId) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("Faculty")
        .doc(facultyId)
        .collection("MyData")
        .get();
    return query.docs.first.data()["name"];
  }

}

class SubjectProvider with ChangeNotifier{

  List<Subject> _mySubjectsList = [];

  List<Subject> get getMySubjectsList{
    return [..._mySubjectsList];
  }


  Future<void> fetchmySubjects() async {
    final CollectionReference mySubjectsId = FirebaseFirestore.instance
        .collection("Faculty")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("MySubjects");
    try {
      var fetchId = await mySubjectsId.get();
      List<Subject> _mySubjects = [];
      for (var subjectId in fetchId.docs) {
        var fetchedSubject = await FirebaseFirestore.instance
            .collection("Subjects")
            .doc(subjectId.id)
            .get();
        if (fetchedSubject.data() != null) {
          _mySubjects.add(
            Subject(
              id: subjectId.id,
              name: fetchedSubject.data()["subject_name"],
              description: fetchedSubject.data()["des"],
              facultyId: fetchedSubject.data()["faculty_id"],
              branch: Subject.extractBranchFromString(
                  fetchedSubject.data()["branch"]),
              subjectCode: fetchedSubject.data()["subject_code"],
            ),
          );
        }
      }

      _mySubjectsList = _mySubjects;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

 
  //  Method used to get search parameters for a subject using subject name
  //  (Used to search for a subject)
  List<String> getSearchKeywords(String subjectName) {
    List<String> caseSearchList = [];
    subjectName = subjectName.toLowerCase();
    String temp = "";
    for (int i = 0; i < subjectName.length; i++) {
      temp = temp + subjectName[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }

  

  Future<void> addSubject(Map<String, String> _professor,
      Map<String, String> _subjects, String uid) async {
    DocumentReference docRef =
        await FirebaseFirestore.instance.collection("Subjects").add(_subjects);
    //  Add search keywords to db
    await FirebaseFirestore.instance
        .collection("Subjects")
        .doc(docRef.id)
        .update(
      {
        "searchKeywords": getSearchKeywords(_subjects['subject_name']),
      },
    );

    await FirebaseFirestore.instance
        .collection("Faculty")
        .doc(uid)
        .collection("MySubjects")
        .doc(docRef.id)
        .set(_professor);

    //Add the newly added subject in the mySubjectList
    Subject newAddedSubject = Subject(
        id: docRef.id,
        name: _subjects['subject_name'],
        description: _subjects['des'],
        facultyId: _subjects['faculty_id'],
        subjectCode: _subjects['subject_code'],
        branch: Subject.extractBranchFromString(_subjects['branch']));

    _mySubjectsList.add(newAddedSubject);

    notifyListeners();
  }
}