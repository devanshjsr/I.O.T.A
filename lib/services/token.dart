import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/subject_model.dart';

class Token {
  final token;

  Token({this.token});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(token: json['token']);
  }
}

Future<Token> generateToken({@required channelName}) async {
  final response = await http.get(
      'https://quizzapp2.herokuapp.com/access_token?channel=' +
          channelName +
          '&uid=0');

  if (response.statusCode == 200) {
    return Token.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to generate token');
  }
}

Future deleteTokens({@required channelName, Subject subject}) async {
  final db = FirebaseFirestore.instance;
  await db
      .collection('channels')
      .where('name', isEqualTo: channelName)
      .get()
      .then((value) => value.docs.forEach((element) {
            print("Deleting channel : " +
                element.data()['name'] +
                "from channels");
            element.reference.delete();
          }));
  final snapshotAtSubj = await db.collection('Subjects').get();
  var docId;
  List chnls = [];
  snapshotAtSubj.docs.forEach((doc) {
    // print(doc.data());
    // print('subject' + subject.name);
    if (doc.data()['subject_name'] == subject.name) {
      docId = doc.id;
      chnls = doc.data()['channels'] ?? [];
    }
  });
  print('before $chnls');
  chnls.remove(channelName);
  print('after $chnls');
  print("Deleting channel : " + channelName + "from subjects");
  await db.collection('Subjects').doc(docId).update({"channels": chnls});
}

Future deleteTokensOfRooms({@required channelName}) async {
  final db = FirebaseFirestore.instance;
  await db
      .collection('RoomChannels')
      .where('name', isEqualTo: channelName)
      .get()
      .then((value) => value.docs.forEach((element) {
            print("Deleting channel : " +
                element.data()['name'] +
                "from channels");
            element.reference.delete();
          }));
}
