import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/caller_model.dart';
import '../../models/shared_preferences.dart';
import '../../models/subject_model.dart';
import '../../services/call.dart';
import '../../services/token.dart';
import '../../styles.dart';

class CreateChannel extends StatefulWidget {
  static const routeName = '/create_channel';
  @override
  _CreateChannelState createState() => _CreateChannelState();
}

class _CreateChannelState extends State<CreateChannel> {
  String channelName = '';
  Subject subject;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    subject = ModalRoute.of(context).settings.arguments;
    // print('Upd here : $subject');
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CustomStyle.primaryColor),
            backgroundColor: CustomStyle.secondaryColor,
          ))
        : Scaffold(
            appBar: AppBar(
              title: Text('Create a Channel'),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    decoration: CustomStyle.customTextFieldDecoration(
                        labelText: 'Channel Name'),
                    onChanged: (val) {
                      setState(() {
                        channelName = val;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: ElevatedButton(
                    onPressed: () => onJoin(),
                    child: Text(
                      'Create',
                      style: CustomStyle.customButtonTextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: CustomStyle.customElevatedButtonStyle(),
                  ),
                )
              ],
            ),
          );
  }

  Future<void> onJoin() async {
    setState(() {
      isLoading = true;
    });
    if (channelName.isNotEmpty) {
      String token = '';

      final db = FirebaseFirestore.instance;
      final snapshot = await db
          .collection('channels')
          .where('name', isEqualTo: channelName)
          .get();

      final snapshotAtSubj = await db
          .collection('Subjects')
          // .where('subject_name', isEqualTo: subject.name)
          .get();

      // empty snapshot i.e. no record will fetch 0 length snapshot
      // to check if the token is already generated or not
      if (snapshot.size == 0) {
        final result = await generateToken(channelName: channelName);
        print('Generated token for ' + channelName + ' : ' + result.token);
        token = result.token;
        // print(token);
        db
            .collection('channels')
            .doc(channelName)
            .set({"name": channelName, "token": token});
      } else {
        snapshot.docs.forEach((doc) {
          // print(doc.data()['token']);
          token = doc.data()['token'];
        });
      }

      // adding the channel Name in the subjects collection
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

      chnls.add(channelName);
      db.collection('Subjects').doc(docId).update({"channels": chnls});

      //to map firebase uid with agora uid
      final caller = Caller(
        callerFirebaseUid: FirebaseAuth.instance.currentUser.uid,
        channelName: channelName,
        isStudent: MySharedPreferences.isStudent,
        callerAgoraUid: null,
      );
      Map<String, dynamic> callMap = caller.toMap(caller);

      //add user data to live channels
      await db
          .collection('channels')
          .doc('live')
          .collection(channelName)
          .add(callMap);

      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      // push video page with given channel name and token

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            channelName: channelName,
            token: token,
          ),
        ),
      );
    }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}
