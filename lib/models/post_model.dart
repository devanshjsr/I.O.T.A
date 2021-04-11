import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'subject_model.dart';

class PostModel {
  String id;
  String uid;
  String postDes;
  String postTime;

  PostModel({
    @required this.id,
    @required this.uid,
    @required this.postDes,
    @required this.postTime,
  });

  static Future<String> getNamefromUid(String uid) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("Student")
        .doc(uid)
        .collection("MyData")
        .get();

    if (query == null) {
      query = await FirebaseFirestore.instance
          .collection("Faculty")
          .doc(uid)
          .collection("MyData")
          .get();
    }

    return query.docs.first.data()["name"];
  }
}

class PostProvider with ChangeNotifier {
  List<PostModel> _allPost = [];

  List<PostModel> get getAllPost {
    return [..._allPost];
  }

  Future<void> fetchSubjectPost(Subject subject) async {
    var allPost = await FirebaseFirestore.instance
        .collection("Subjects")
        .doc(subject.id)
        .collection("Post")
        .orderBy("post Time")
        .get();

    List<PostModel> _list = [];
    for (var element in allPost.docs) {
      PostModel newPost = PostModel(
          id: element.id,
          uid: element.data()["uid"],
          postDes: element.data()["post description"],
          postTime: element.data()["post Time"]);

      _list.add(newPost);
    }

    _allPost = _list;

    notifyListeners();
  }

  Future<void> postCurrentPost(
      Subject subject, Map<String, String> post) async {
    post["uid"] = FirebaseAuth.instance.currentUser.uid;
    post["post Time"] = DateTime.now().toIso8601String();
    await FirebaseFirestore.instance
        .collection("Subjects")
        .doc(subject.id)
        .collection("Post")
        .add(post);

    notifyListeners();
  }
}
