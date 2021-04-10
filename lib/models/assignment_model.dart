import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:iota/models/subject_model.dart';
import 'package:iota/models/submission_model.dart';
class Assignment {
  final String id;
  final String name;
  final String description;
  final String dueDate;
  final String url;

  Assignment(
      {@required this.id,
      @required this.name,
      this.description,
      @required this.dueDate,
      @required this.url});
  
    static Future<String> fetchMyWork(Assignment assignment) async{
    DocumentSnapshot doc = await FirebaseFirestore.instance
                                .collection("Assignment")
                                .doc(assignment.id)
                                .collection("list_of_submissions")
                                .doc(FirebaseAuth.instance.currentUser.uid)
                                .get();

    return doc.data()["url_of_submitted_pdf"];
  }
}


class AssignmentProvider with ChangeNotifier {
  List<Assignment> _onGoingAssignments = [];

  List<Assignment> _completedAssignments = [];


  List<Assignment> _studentPendingAssignment = [];
  List<Assignment> _studentSubmittedAssignment = [];

  List<Assignment> get getSubmittedAssignment {
    return [..._studentSubmittedAssignment];
  }

  List<Assignment> get getPendingAssignment {
    return [..._studentPendingAssignment];
  }

  List<Assignment> get getOngoingAssignment {
    return [..._onGoingAssignments];
  }

  List<Assignment> get getCompletedAssignment {
    return [..._completedAssignments];
  }
  
  List<Submission> _submittedAssignment = [];

  List<Submission> get getSubmittedAssignmentProfessor {
    return [..._submittedAssignment];
  }




  //Upload the assignmentwork done by student
  Future<void> uploadAssignmentWork(
      List<int> asset, Assignment assignment, String name) async {
    StorageReference reference = FirebaseStorage.instance
        .ref()
        .child("Assignment Submissions")
        .child(name);

    StorageUploadTask uploadTask = reference.putData(asset);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    print(url);

    String uid = FirebaseAuth.instance.currentUser.uid;
    Map<String, String> submittedAssignment = {
      "url_of_submitted_pdf": url,
      "submission time": DateTime.now().toIso8601String(),
    };

    await FirebaseFirestore.instance
        .collection("Assignment")
        .doc(assignment.id)
        .collection("list_of_submissions")
        .doc(uid)
        .set(submittedAssignment);
    
    _studentPendingAssignment.remove(assignment);
    _studentSubmittedAssignment.add(assignment);

    notifyListeners();
  }
  
  //Upload the assignment added by professor

  Future<void> uploadAssignment(Subject subject, Map<String, String> assignment,
      List<int> asset, String name) async {
    //Check if pdf file is attached or not upload only if its attached
    if (asset.isNotEmpty) {
      StorageReference reference =
          FirebaseStorage.instance.ref().child("Assignment").child(name);
      StorageUploadTask uploadTask = reference.putData(asset);
      String url = await (await uploadTask.onComplete).ref.getDownloadURL();
      assignment["url_of_question_pdf"] = url;
      print(url);
    }

    //Add assignment in the assignment section with all the fields
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection("Assignment")
        .add(assignment);

    Map<String, String> assignmentId = {
      "due date": assignment["due date"],
    };
    await FirebaseFirestore.instance
        .collection("Subjects")
        .doc(subject.id)
        .collection("Assignments")
        .doc(docRef.id)
        .set(assignmentId);

    var students = await FirebaseFirestore.instance
        .collection("Subjects")
        .doc(subject.id)
        .collection("Enrolled Students")
        .get();

    for (var element in students.docs) {
      String uid = element.id;
      await FirebaseFirestore.instance
          .collection("Student")
          .doc(uid)
          .collection("My Assignment")
          .doc(docRef.id)
          .set(assignmentId);
    }



      
    Assignment newAssignment = Assignment(
      id: docRef.id,name: 
      assignment["name"],
      description: assignment["description"],
      dueDate: assignment["due date"],
      url: assignment["url_of_question_pdf"]);
    _onGoingAssignments.add(newAssignment);

    notifyListeners();
  }


  Future<void> deleteUploadedAssignment(Assignment assignment) async {
    String url = assignment.url;
    StorageReference pdfRef = await FirebaseStorage.instance
        .ref()
        .getStorage()
        .getReferenceFromUrl(url);

    try {
      pdfRef.delete();
      print("File Succesfully Removed");
    } catch (error) {
      throw Error;
    }

    await FirebaseFirestore.instance
        .collection("Assignment")
        .doc(assignment.id)
        .collection("list_of_submissions")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .delete();
    
    _studentSubmittedAssignment.remove(assignment);
    _studentPendingAssignment.add(assignment);
    
    notifyListeners();
  }

  Future<void> changeDeadline(Assignment assignment, String newDeadline) async {
    await FirebaseFirestore.instance
        .collection("Assignment")
        .doc(assignment.id)
        .update({"due date": newDeadline});

    notifyListeners();
  }


  Future<void> fetchSubmittedAssignments(Assignment assignment) async {
    var allSubmittedAssignment = await FirebaseFirestore.instance
        .collection("Assignment")
        .doc(assignment.id)
        .collection("list_of_submissions")
        .get();

    List<Submission> _tempSubmission = [];
    for (var element in allSubmittedAssignment.docs) {
      String uid = element.id;

      var myDate = await FirebaseFirestore.instance
          .collection("Student")
          .doc(uid)
          .collection("MyData")
          .get();

      String name = "";
      for (var user in myDate.docs) {
        name = await user.data()["name"];
      }

      String time = element.data()["submission time"];
      Submission newSubmission = Submission(
          id: element.id,
          url: element.data()["url_of_submitted_pdf"],
          submissionTime: DateTime.parse(time),
          name: name);
      _tempSubmission.add(newSubmission);
    }

    _submittedAssignment = _tempSubmission;
    notifyListeners();
  }
  

  //Fetch all the assignments for the professor
  Future<void> fetchAssignmentsProfessor(Subject subject) async {
    var fetchedassignments = await FirebaseFirestore.instance
        .collection("Subjects")
        .doc(subject.id)
        .collection("Assignments")
        .get();

    List<Assignment> _onGoingassignmentList = [];
    List<Assignment> _completedassignmentList = [];

    for (var element in fetchedassignments.docs) {
      var assignment = await FirebaseFirestore.instance
          .collection("Assignment")
          .doc(element.id)
          .get();
      String time = assignment.data()["due date"];
      Assignment newAssignment = Assignment(
          id: element.id,
          name: assignment.data()["name"],
          description: assignment.data()["description"],
          dueDate: time.substring(0, 10) + "  " + time.substring(11, 19),
          url: assignment.data()["url_of_question_pdf"]);

      DateTime current = DateTime.now();
      DateTime currentTime = DateTime.utc(current.year, current.month,
          current.day, current.hour, current.minute);
      DateTime assignmentTime = DateTime.parse(time);

      print(currentTime.toString());
      print(assignmentTime.toString());
      print(currentTime.isAfter(assignmentTime));

      if (currentTime.isAfter(assignmentTime)) {
        _completedassignmentList.add(newAssignment);
      } else {
        _onGoingassignmentList.add(newAssignment);
      }
    }
    _onGoingAssignments = _onGoingassignmentList;
    _completedAssignments = _completedassignmentList;

    notifyListeners();
  }

  //Fetch assignment alloted to student in particular subject
  Future<void> fetchAssignmentStudent(Subject subject) async {
    var fetchedassignments = await FirebaseFirestore.instance
        .collection("Subjects")
        .doc(subject.id)
        .collection("Assignments")
        .get();

    List<Assignment> studentsubmitted = [];
    List<Assignment> pending = [];

    for (var element in fetchedassignments.docs) {
      var assignment = await FirebaseFirestore.instance
          .collection("Assignment")
          .doc(element.id)
          .get();
      String time = assignment.data()["due date"];
      Assignment newAssignment = Assignment(
          id: element.id,
          name: assignment.data()["name"],
          description: assignment.data()["description"],
          dueDate: time.substring(0, 10) + "  " + time.substring(11, 19),
          url: assignment.data()["url_of_question_pdf"]);

      var qury = await FirebaseFirestore.instance
          .collection("Assignment")
          .doc(element.id)
          .collection("list_of_submissions")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .get();

      print(qury.data());
      print(element.id);

      if (qury.data() != null) {
        studentsubmitted.add(newAssignment);
      } else {
        pending.add(newAssignment);
      }
      print(time);
    }

    _studentSubmittedAssignment = studentsubmitted;
    _studentPendingAssignment = pending;
    notifyListeners();
  }


}