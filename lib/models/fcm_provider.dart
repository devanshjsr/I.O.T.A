import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../services/settings.dart';
import 'data_model.dart';

//  Provider for all the noifications
class FcmProvider with ChangeNotifier {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  //  Initialization for FCM
  Future initialize() async {
    print("INITIALIZED");
    //  Initialization for Ios
    await _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );
    _firebaseMessaging.subscribeToTopic("all");

    _firebaseMessaging.configure(
      //  called when app is in foreground and we receive push notification
      //  no notification shown by default, so we show a toast
      onMessage: (Map<String, dynamic> message) async {
        // _storeToFireStore(message);
        print("onMessage : $message");
        Fluttertoast.cancel();
        Fluttertoast.showToast(
          backgroundColor: Colors.yellow[700],
          textColor: Colors.black,
          msg: message["notification"]["title"],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
      },
      //  called when app has been closed completely and it's opened from push notification
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch : $message");
      },
      //  called when app is in the background and it's opened from the push notification
      onResume: (Map<String, dynamic> message) async {
        print("onResume : $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        badge: true,
        alert: true,
      ),
    );
  }

  //  To subscribe to a product when product is added to fav
  Future<void> subscribeToSubject(String subjectId) async {
    await _firebaseMessaging.subscribeToTopic(subjectId);
  }

  //  To un-subscribe to a product when product is removed from fav
  Future<void> unsubscribeFromSubject(String subjectId) async {
    await _firebaseMessaging.unsubscribeFromTopic(subjectId);
  }

  //  Notification to be sent when a fav product is back in stock
  Future<void> sendUpcomingTestNotification(String subjectId, String quizTitle,
      DateTime quizDateTime, String duration) async {
    String dateTime = DateFormat("dd MMM yyyy, HH:mm").format(quizDateTime);
    String title = 'You have an upcoming quiz: $quizTitle';
    String body = 'Start time: $dateTime . Duration: $duration mins';
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$FCM_SERVER_KEY',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': title,
            'body': body,
            "image": DataModel.APP_ICON_PNG
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': '/topics/$subjectId',
        },
      ),
    );
  }

  //  Notification to be sent when a fav product is back in stock
  Future<void> sendUpcomingAssignmentNotification(String subjectId,
      String assignmentTitle, DateTime assignmentDueDate) async {
    String dateTime =
        DateFormat("dd MMM yyyy, HH:mm").format(assignmentDueDate);
    String title = 'You have a new assignment: $assignmentTitle';
    String body = 'Due date: $dateTime ';
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$FCM_SERVER_KEY',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': title,
            'body': body,
            "image": DataModel.APP_ICON_PNG
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': '/topics/$subjectId',
        },
      ),
    );
  }
}
