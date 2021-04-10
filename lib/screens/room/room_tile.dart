
import 'package:flutter/material.dart';
import 'package:iota/dialog/custom_dialog.dart';
import 'package:iota/models/room_model.dart';
import 'package:iota/models/shared_preferences.dart';
import 'package:iota/styles.dart';
class RoomTile extends StatelessWidget {
  final Room room;
  RoomTile({@required this.room});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        decoration: CustomStyle.subjectTileStyle(),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: ListTile(
          onTap: () {
            //room features to be implemented 
          },
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
            style: CustomStyle.customButtonTextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            room.des,
            style: CustomStyle.customButtonTextStyle(fontWeight: FontWeight.bold),
          ),
        
          trailing: 
          MySharedPreferences.isStudent ? SizedBox(width : 2) : GestureDetector(
            onTapDown: (data){
              CustomDialog.showRoomOptionDialog(context, data.globalPosition,room);
            },
            child : Icon(
            Icons.more_vert,
            size: 35,
            color: CustomStyle.primaryColor,
          ),
          ),
        ),
      ),
    );
  }
}