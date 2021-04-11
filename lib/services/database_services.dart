import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseServices {
  Future<void> addQuiz(Map quizData, String quizId) async {
    await FirebaseFirestore.instance
        .collection("Quiz_List")
        .doc(quizId)
        .set(quizData)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> addQuestion(Map queData, String quizId, String queId) async {
    await FirebaseFirestore.instance
        .collection("Quiz_List")
        .doc(quizId)
        .collection(quizId)
        .doc(queId)
        .set(queData)
        .catchError((e) {
      print(e.toString());
    });
  }

  getQuizInfo(String subjectId) async {
    return FirebaseFirestore.instance
        .collection("Quiz_List")
        .where("subjectId", isEqualTo: subjectId)
        .snapshots();
  }

  Future<QuerySnapshot> getQuestionList(String quizId) async {
    return await FirebaseFirestore.instance
        .collection("Quiz_List")
        .doc(quizId)
        .collection(quizId)
        .get();
  }

  // deleteAttemptedQuiz(String quizId) async {
  //   return await FirebaseFirestore.instance
  //       .collection("Quiz_List")
  //       .doc(quizId)
  //       .delete();
  // }

  Future<void> saveQuiz(Map<String, String> quizMap, String quizId) async {
    await FirebaseFirestore.instance
        .collection("AttemptedQuiz")
        .doc(quizId)
        .set({"title": quizMap["title"]});
    await FirebaseFirestore.instance
        .collection("AttemptedQuiz")
        .doc(quizId)
        .collection("StudentResponses")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .set(quizMap)
        .catchError((e) {
      print(e.toString());
    });
    await saveQuizDetailsInStudentCollection(quizId);
  }

  Future saveQuizDetailsInStudentCollection(String quizId) async {
    await FirebaseFirestore.instance
        .collection("Student")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("MyAttemptedQuizzes")
        .doc(quizId)
        .set({"quizId": quizId}).catchError((e) {
      print(e.toString());
    });
  }

  Future<void> saveQuestion(Map queData, String quizId, String queId) async {
    await FirebaseFirestore.instance
        .collection("AttemptedQuiz")
        .doc(quizId)
        .collection("StudentResponses")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection(quizId)
        .doc(queId)
        .set(queData)
        .catchError((e) {
      print(e.toString());
    });
    await saveQuizDetailsInStudentCollection(quizId);
  }

  Future<QuerySnapshot> getAttemptedQuizzes() async {
    return FirebaseFirestore.instance.collection("AttemptedQuiz").get();
  }

  Future<bool> checkIfCurrentStudentAttemptedQuiz(String quizId) async {
    var data = await FirebaseFirestore.instance
        .collection("AttemptedQuiz")
        .doc(quizId)
        .collection("StudentResponses")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    if (!data.exists) {
      return false;
    } else {
      return true;
    }
  }

  getAttemptedQuizData(String quizId) async {
    return await FirebaseFirestore.instance
        .collection("Quiz_List")
        .doc(quizId)
        .get();
  }

  Future<QuerySnapshot> getAttemptedQuestionList(String quizId) async {
    QuerySnapshot res = await FirebaseFirestore.instance
        .collection("AttemptedQuiz")
        .doc(quizId)
        .collection("StudentResponses")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection(quizId)
        .get();
    return res;
  }

  Future<DocumentSnapshot> getAttemptedQuesInfo(
      String quizId, String questionId) async {
    DocumentSnapshot data = await FirebaseFirestore.instance
        .collection("AttemptedQuiz")
        .doc(quizId)
        .collection("StudentResponses")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection(quizId)
        .doc(questionId)
        .get();
    print("AAA" + data.data().toString());
    return data;
  }

  ///prf

  Future<List<DocumentSnapshot>> getSubjectQuizzes(String subjectId) async {
    List<DocumentSnapshot> res = [];
    QuerySnapshot quizInfo =
        await FirebaseFirestore.instance.collection("Quiz_List").get();
    for (int i = 0; i < quizInfo.docs.length; i++) {
      String quizId = quizInfo.docs[i].id;

      DocumentSnapshot value = await getAttemptedQuizData(quizId);
      String currentId = value.data()["subjectId"];
      if (currentId.compareTo(subjectId) == 0) {
        res.add(value);
      }
    }
    return res;
  }
}
