import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Caller {
  var callerFirebaseUid;
  var callerAgoraUid;
  var isStudent;
  var channelName;

  Caller(
      {this.callerAgoraUid,
      this.callerFirebaseUid,
      this.channelName,
      this.isStudent});

  Map<String, dynamic> toMap(Caller caller) {
    Map<String, dynamic> callMap = Map();
    callMap['callerFirebaseUid'] = caller.callerFirebaseUid;
    callMap['callerAgoraUid'] = caller.callerAgoraUid;
    callMap['isStudent'] = caller.isStudent;
    callMap['channelName'] = caller.channelName;
    return callMap;
  }

  Caller.fromMap(Map callMap) {
    this.callerFirebaseUid = callMap['callerFirebaseUid'];
    this.callerAgoraUid = callMap['callerAgoraUid'];
    this.channelName = callMap['channelName'];
    this.isStudent = callMap['isStudent'];
  }
}

class CallMethods {
  static liveEnded(callerAgoraUid, channelName) async {
    final firebaseUid = FirebaseAuth.instance.currentUser.uid;
    final liveRef = FirebaseFirestore.instance
        .collection('channels')
        .doc('live')
        .collection(channelName);
    var _docId;
    await liveRef
        .where('callerFirebaseUid', isEqualTo: firebaseUid)
        .get()
        .then((value) => value.docs.forEach((doc) {
              _docId = doc.id;
            }));
    liveRef.doc(_docId).delete();
  }
}
