import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/room/member_room.dart';
import 'subject_model.dart';

class Room {
  String id;
  String name;
  String des;
  String subjectId;

  Room({
    @required this.id,
    @required this.name,
    @required this.des,
    @required this.subjectId,
  });
}

class RoomProvider with ChangeNotifier {
  List<Room> _allRooms = [];

  List<Room> get getAllRooms {
    return [..._allRooms];
  }

  List<MemberRoom> _notInRoomMember = [];

  List<MemberRoom> get getnotInRoomMember {
    return [..._notInRoomMember];
  }

  List<MemberRoom> _memberRoom = [];

  List<MemberRoom> get getMemberRoom {
    return [..._memberRoom];
  }

  List<Room> _myRooms = [];
  List<Room> get getMyRooms {
    return [..._myRooms];
  }

  Future<void> addRoom(Subject subject, Map<String, String> newRoom) async {
    var dataSnapshot =
        await FirebaseFirestore.instance.collection("Room").add(newRoom);

    Map<String, String> id = {
      "room name": newRoom["room name"],
    };

    await FirebaseFirestore.instance
        .collection("Subjects")
        .doc(subject.id)
        .collection("Room")
        .doc(dataSnapshot.id)
        .set(id);

    Room _newRoom = Room(
        id: dataSnapshot.id,
        name: newRoom["room name"],
        des: newRoom["room description"],
        subjectId: subject.id);

    _allRooms.add(_newRoom);

    notifyListeners();
  }

  Future<void> fetchAllRooms(Subject subject) async {
    var allRooms = await FirebaseFirestore.instance
        .collection("Subjects")
        .doc(subject.id)
        .collection("Room")
        .get();

    List<Room> tmpRoom = [];
    for (var element in allRooms.docs) {
      var roomDetail = await FirebaseFirestore.instance
          .collection("Room")
          .doc(element.id)
          .get();
      Room newRoom = Room(
        id: element.id,
        name: roomDetail.data()["room name"],
        des: roomDetail.data()["room description"],
        subjectId: subject.id,
      );

      tmpRoom.add(newRoom);
    }

    _allRooms = tmpRoom;
    notifyListeners();
  }

  Future<void> fetchMyRooms(Subject subject) async {
    String uid = FirebaseAuth.instance.currentUser.uid;
    var allRooms = await FirebaseFirestore.instance
        .collection("Subjects")
        .doc(subject.id)
        .collection("Room")
        .get();

    List<Room> _tmpRoom = [];
    for (var room in allRooms.docs) {
      var student = await FirebaseFirestore.instance
          .collection("Room")
          .doc(room.id)
          .collection("list of students")
          .doc(uid)
          .get();
      if (student.exists) {
        var data = await FirebaseFirestore.instance
            .collection("Room")
            .doc(room.id)
            .get();
        Room newRoom = Room(
          id: room.id,
          des: data.data()["room description"],
          name: data.data()["room name"],
          subjectId: subject.id,
        );
        _tmpRoom.add(newRoom);
      }
    }
    _myRooms = _tmpRoom;
    notifyListeners();
  }

  Future<void> fetchNonMembersRoom(String subjectId, Room room) async {
    print('Fetching from here');
    var allMembers = await FirebaseFirestore.instance
        .collection("Subjects")
        .doc(subjectId)
        .collection("Enrolled Students")
        .get();
    List<MemberRoom> _tmpList = [];
    for (var element in allMembers.docs) {
      var found = await FirebaseFirestore.instance
          .collection("Room")
          .doc(room.id)
          .collection("list of students")
          .doc(element.id)
          .get();
      if (!found.exists) {
        var data = await FirebaseFirestore.instance
            .collection("Student")
            .doc(element.id)
            .collection("MyData")
            .get();
        MemberRoom newMember = MemberRoom(
          id: element.id,
          name: data.docs.first.data()["name"],
          email: data.docs.first.data()["email"],
          room: room,
        );

        _tmpList.add(newMember);
      }
    }

    _notInRoomMember = _tmpList;

    notifyListeners();
  }

  Future<void> addMember(Room room, String uid) async {
    Map<String, String> id = {"uid ": uid};
    await FirebaseFirestore.instance
        .collection("Room")
        .doc(room.id)
        .collection("list of students")
        .doc(uid)
        .set(id);

    notifyListeners();
  }

  Future<void> removeMember(Room room, String uid) async {
    await FirebaseFirestore.instance
        .collection("Room")
        .doc(room.id)
        .collection("list of students")
        .doc(uid)
        .delete();
  }

  Future<void> fetchMembersRoom(Room room) async {
    var allMembers = await FirebaseFirestore.instance
        .collection("Room")
        .doc(room.id)
        .collection("list of students")
        .get();

    List<MemberRoom> _tmpList = [];
    for (var member in allMembers.docs) {
      var data = await FirebaseFirestore.instance
          .collection("Student")
          .doc(member.id)
          .collection("MyData")
          .get();
      MemberRoom newMember = MemberRoom(
        id: member.id,
        name: data.docs.first.data()["name"],
        email: data.docs.first.data()["email"],
        room: room,
      );

      _tmpList.add(newMember);
    }

    _memberRoom = _tmpList;
    notifyListeners();
  }

  Future<void> removeRoom(Room room) async {
    await FirebaseFirestore.instance.collection("Room").doc(room.id).delete();

    await FirebaseFirestore.instance
        .collection("Subjects")
        .doc(room.subjectId)
        .collection("Room")
        .doc(room.id)
        .delete();

    // remove room channel
    await FirebaseFirestore.instance
        .collection('RoomChannels')
        .doc(room.name)
        .delete();

    _allRooms.remove(room);
    notifyListeners();
  }
}
