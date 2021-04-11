import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../dialog/custom_dialog.dart';
import '../../models/room_model.dart';
import '../../models/shared_preferences.dart';
import '../../services/roomcall.dart';
import '../../styles.dart';

class RoomTile extends StatelessWidget {
  Room room;
  RoomTile({@required this.room});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        decoration: CustomStyle.subjectTileStyle(),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: ListTile(
          onTap: () => onJoin(context),
          leading: Hero(
            tag: room.id,
            child: CircleAvatar(
              radius: 35,
              backgroundColor: CustomStyle.secondaryColor,
              child: CircleAvatar(
                backgroundColor: CustomStyle.primaryColor,
                radius: 25,
                child: Text(
                  room.name.substring(0, 2).toUpperCase(),
                  style: TextStyle(
                      color: CustomStyle.backgroundColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2),
                ),
              ),
            ),
          ),
          title: Text(
            room.name,
            style:
                CustomStyle.customButtonTextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            room.des,
            style:
                CustomStyle.customButtonTextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: MySharedPreferences.isStudent
              ? SizedBox(width: 2)
              : GestureDetector(
                  onTapDown: (data) {
                    CustomDialog.showRoomOptionDialog(
                        context, data.globalPosition, room);
                  },
                  child: Icon(
                    Icons.more_vert,
                    size: 35,
                    color: CustomStyle.primaryColor,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> onJoin(BuildContext ctx) async {
    String channelName = room.name;
    if (channelName.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      print('Hello');

      final db = FirebaseFirestore.instance;
      final snapshot = await db
          .collection('RoomChannels')
          .where('name', isEqualTo: channelName)
          .get();
      String token = '';
      snapshot.docs.forEach((doc) {
        token = doc.data()['token'];
      });
      // push video page with given channel name and token
      await Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (context) => RoomCallPage(
              channelName: channelName,
              token: token,
            ),
          ));
    }
  }

  Future<void> _handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    print(status);
  }
}
