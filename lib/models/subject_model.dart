import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'fcm_provider.dart';
import 'member_model.dart';

//  Class for subject
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

  //  Method to fetch branch list from (comma-seperated branch) string
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

class SubjectProvider with ChangeNotifier {
  //  List of subjects currently enrolled in(for student)
  List<Subject> _myEnrolledSubjectsList = [];

  //  List of subjects owned by user(for faculty)
  List<Subject> _mySubjectsList = [];

  //  getter to return copy of enrolledSubjectsList
  List<Subject> get getMyEnrolledSubjectsList {
    return [..._myEnrolledSubjectsList];
  }

  //  getter to return copy of mySubjectsList
  List<Subject> get getMySubjectsList {
    return [..._mySubjectsList];
  }

  List<Member> _myEnrolledStudents = [];

  List<Member> get getmyEnrolledStudents {
    return [..._myEnrolledStudents];
  }

  Future<void> fetchMyEnrolledSubjects(BuildContext context) async {
    final CollectionReference myEnrolledSubjectsId = FirebaseFirestore.instance
        .collection("Student")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("Enrolled Subjects");
    try {
      //  Fetch all the subject IDs
      var fetchedSubjectsId = await myEnrolledSubjectsId.get();
      List<Subject> subjects = [];
      List<String> subjectIds =
          fetchedSubjectsId.docs.map((e) => e.id).toList();
      var data = await FirebaseFirestore.instance.collection("Subjects").get();
      for (var fetchedSubject in data.docs) {
        if (subjectIds.contains(fetchedSubject.id)) {
          Provider.of<FcmProvider>(context, listen: false)
              .subscribeToSubject(fetchedSubject.id);
          subjects.add(
            Subject(
              id: fetchedSubject.id,
              name: fetchedSubject.data()["subject_name"],
              description: fetchedSubject.data()["des"],
              facultyId: fetchedSubject.data()["faculty_id"],
              branch: Subject.extractBranchFromString(
                  fetchedSubject.data()["branch"]),
              subjectCode: fetchedSubject.data()["subject_code"],
            ),
          );
        } else {
          Provider.of<FcmProvider>(context, listen: false)
              .unsubscribeFromSubject(fetchedSubject.id);
        }
        // print(x.data());
      }
      //  Fetch subject data from IDs
      // for (var element in fetchedSubjectsId.docs) {
      //   var fetchedSubject = await FirebaseFirestore.instance
      //       .collection("Subjects")
      //       .doc(element.id)
      //       .get();
      //   if (fetchedSubject.data() != null) {
      //     Provider.of<FcmProvider>(context, listen: false)
      //         .subscribeToSubject(fetchedSubject.id);
      //     subjects.add(
      //       Subject(
      //         id: fetchedSubject.id,
      //         name: fetchedSubject.data()["subject_name"],
      //         description: fetchedSubject.data()["des"],
      //         facultyId: fetchedSubject.data()["faculty_id"],
      //         branch: Subject.extractBranchFromString(
      //             fetchedSubject.data()["branch"]),
      //         subjectCode: fetchedSubject.data()["subject_code"],
      //       ),
      //     );
      //   }
      // }
      _myEnrolledSubjectsList = subjects;
      notifyListeners();
    } catch (error) {
      throw error;
    }
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

  //Method to add new Subject in the enrolled list( Method to join a subject(Join directly when using subject-code))
  Future<void> joinSubjectUsingCode(
      String subjectCode, String name, String uid, BuildContext context) async {
    try {
      QuerySnapshot data = await FirebaseFirestore.instance
          .collection("Subjects")
          .where('subject_code', isEqualTo: subjectCode)
          .get();
      if (data.docs.length == 0) {
        throw "NOT FOUND";
      } else {
        final Map<String, String> enrolledSubject = {
          "subject_name": data.docs[0].data()["subject_name"],
        };

        await FirebaseFirestore.instance
            .collection("Student")
            .doc(uid)
            .collection("Enrolled Subjects")
            .doc(data.docs[0].id)
            .set(enrolledSubject);

        //Add the newly added Subject into my Enrolled Subject List;
        Subject newEnrolledSubject = Subject(
          id: data.docs[0].id,
          name: data.docs[0].data()["subject_name"],
          description: data.docs[0].data()["des"],
          facultyId: data.docs[0].data()["faculty_id"],
          branch:
              Subject.extractBranchFromString(data.docs[0].data()["branch"]),
          subjectCode: data.docs[0].data()["subject_code"],
        );

        _myEnrolledSubjectsList.add(newEnrolledSubject);

        //Add the userId in the subjects enrolled students list
        Map<String, String> userName = {
          "student_name": name,
        };

        await FirebaseFirestore.instance
            .collection("Subjects")
            .doc(data.docs[0].id)
            .collection("Enrolled Students")
            .doc(uid)
            .set(userName);
        Provider.of<FcmProvider>(context, listen: false)
            .subscribeToSubject(data.docs[0].id);

        notifyListeners();

        //  If join request exists, delete it
        await removeSubjectJoinRequest(newEnrolledSubject, uid);
      }
    } catch (error) {
      throw error;
    }
  }

  //  Method to join any subject using Join Subject btn( Asks for accepting request from faculty)
  Future<void> joinSubjectByPermission(
      Subject subject, String studentId, String studentName) async {
    try {
      await FirebaseFirestore.instance
          .collection("Faculty")
          .doc(subject.facultyId)
          .collection("Pending students in subjects")
          .doc(subject.id)
          .collection("Students List")
          .doc(studentId)
          .set({"student name": studentName});
    } catch (error) {
      throw error;
    }
  }

  //  Method to remove any subject joining request using Cancel request btn
  Future<void> removeSubjectJoinRequest(
      Subject subject, String studentId) async {
    try {
      await FirebaseFirestore.instance
          .collection("Faculty")
          .doc(subject.facultyId)
          .collection("Pending students in subjects")
          .doc(subject.id)
          .collection("Students List")
          .doc(studentId)
          .delete();
    } catch (error) {
      throw error;
    }
  }

  //  Method to accept/reject subject joining request(used by faculty)
  Future<void> respondToJoinRequest(Subject subject, String studentId,
      bool accept, String studentName, BuildContext context) async {
    try {
      //  Join request is removed in both case(accept & reject)
      await removeSubjectJoinRequest(subject, studentId);
      if (accept == true) {
        final Map<String, String> enrolledSubject = {
          "subject_name": subject.name,
        };

        await FirebaseFirestore.instance
            .collection("Student")
            .doc(studentId)
            .collection("Enrolled Subjects")
            .doc(subject.id)
            .set(enrolledSubject);

        //Add the userId in the subjects enrolled students list
        Map<String, String> userName = {
          "student_name": studentName,
        };

        await FirebaseFirestore.instance
            .collection("Subjects")
            .doc(subject.id)
            .collection("Enrolled Students")
            .doc(studentId)
            .set(userName);
      } else {
        //  TODO: send a notification to student that his request has been denied
      }
    } catch (error) {
      throw error;
    }
  }

  Future<List<Map<String, String>>> fetchPendingRequestsForSubject(
      Subject subject) async {
    QuerySnapshot res = await FirebaseFirestore.instance
        .collection("Faculty")
        .doc(subject.facultyId)
        .collection("Pending students in subjects")
        .doc(subject.id)
        .collection("Students List")
        .get();
    List<Map<String, String>> studentList = [];
    for (var x in res.docs) {
      print(x.data());
      studentList.add(
        {
          "student name": x.data()["student name"],
          "student id": x.id,
        },
      );
    }
    return studentList;
  }

  Future<bool> checkIfSubjectJoinPermissionIsPending(
      Subject subject, String studentId) async {
    try {
      DocumentSnapshot res = await FirebaseFirestore.instance
          .collection("Faculty")
          .doc(subject.facultyId)
          .collection("Pending students in subjects")
          .doc(subject.id)
          .collection("Students List")
          .doc(studentId)
          .get();
      print(res.exists);
      if (res.exists) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      throw error;
    }
  }

  //  Method to leave a subject(for student)
  Future<void> leaveSubject(
      Subject subject, String studentId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection("Student")
          .doc(studentId)
          .collection("Enrolled Subjects")
          .doc(subject.id)
          .delete();
      //Remove the Subjectlocally from  my Enrolled Subject List;
      _myEnrolledSubjectsList.remove(subject);

      await FirebaseFirestore.instance
          .collection("Subjects")
          .doc(subject.id)
          .collection("Enrolled Students")
          .doc(studentId)
          .delete();
      Provider.of<FcmProvider>(context, listen: false)
          .unsubscribeFromSubject(subject.id);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  //  Method to leave a subject(for student)
  Future<void> removeFromSubject(
      Subject subject, String studentId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection("Student")
          .doc(studentId)
          .collection("Enrolled Subjects")
          .doc(subject.id)
          .delete();
      //Remove the Subjectlocally from  my Enrolled Subject List;
      _myEnrolledStudents.removeWhere((element) => element.id == studentId);

      await FirebaseFirestore.instance
          .collection("Subjects")
          .doc(subject.id)
          .collection("Enrolled Students")
          .doc(studentId)
          .delete();
      Provider.of<FcmProvider>(context, listen: false)
          .unsubscribeFromSubject(subject.id);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  //Fetch Enrolled Students of the given subject;
  Future<void> fetchEnrolledStudents(String docRef) async {
    var enrolledStudents = await FirebaseFirestore.instance
        .collection("Subjects")
        .doc(docRef)
        .collection("Enrolled Students")
        .get();
    List<Member> _myList = [];
    for (var element in enrolledStudents.docs) {
      String userId = element.id;

      var fetchedStudents = await FirebaseFirestore.instance
          .collection("Student")
          .doc(userId)
          .collection("MyData")
          .get();

      for (var student in fetchedStudents.docs) {
        Member newMember = Member(
            id: userId,
            name: student.data()["name"],
            mobileNumber: student.data()["mobileNumber"]);
        _myList.add(newMember);

        print(student.data()["name"]);
        print(student.data()["mobileNumber"]);
      }
    }

    _myEnrolledStudents = _myList;
  }

  //Method to create a subject
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

  Future<bool> checkIfEnrolledToASubjectUsingId(String id) async {
    bool isEnrolled =
        _myEnrolledSubjectsList.any((element) => element.id == id);
    if (isEnrolled == true) {
      return true;
    } else {
      //Check in firestore to be sure, and if found on firestore, add to local list as well
      DocumentSnapshot res = await FirebaseFirestore.instance
          .collection("Student")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection("Enrolled Subjects")
          .doc(id)
          .get();
      if (res.exists) {
        print(res.data());
        DocumentSnapshot fetchedSubject = await FirebaseFirestore.instance
            .collection("Subjects")
            .doc(res.id)
            .get();
        _myEnrolledSubjectsList.add(Subject(
          id: fetchedSubject.id,
          name: fetchedSubject.data()["subject_name"],
          description: fetchedSubject.data()["des"],
          facultyId: fetchedSubject.data()["faculty_id"],
          branch:
              Subject.extractBranchFromString(fetchedSubject.data()["branch"]),
          subjectCode: fetchedSubject.data()["subject_code"],
        ));
        notifyListeners();
        return true;
      } else {
        return false;
      }
    }
  }

  //  Function to get query snapshot stream(of subjects) based upon the search query
  Stream<QuerySnapshot> getSubjectsOnSearch(String search) {
    return FirebaseFirestore.instance
        .collection('Subjects')
        .where("searchKeywords", arrayContains: search)
        .snapshots();
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

  //Method to fetch subject using subject-code
  static Future<Subject> fetchSubjectUsingCode(String subjectCode) async {
    try {
      QuerySnapshot data = await FirebaseFirestore.instance
          .collection("Subjects")
          .where('subject_code', isEqualTo: subjectCode)
          .get();
      if (data.docs.length == 0) {
        return null;
      } else {
        Subject newSubject = Subject(
          id: data.docs[0].id,
          name: data.docs[0].data()["subject_name"],
          description: data.docs[0].data()["des"],
          facultyId: data.docs[0].data()["faculty_id"],
          branch:
              Subject.extractBranchFromString(data.docs[0].data()["branch"]),
          subjectCode: data.docs[0].data()["subject_code"],
        );
        return newSubject;
      }
    } catch (error) {
      throw error;
    }
  }
}
