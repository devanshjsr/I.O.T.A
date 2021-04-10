import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/room_model.dart';
import '../../styles.dart';
import 'member_room.dart';

class MemberRoomTile extends StatelessWidget {
  final MemberRoom memberRoom;
  final type;
  MemberRoomTile({@required this.memberRoom, @required this.type});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        decoration: CustomStyle.subjectTileStyle(),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: ListTile(
          leading: Hero(
            tag: memberRoom.id,
            child: CircleAvatar(
              radius: 35,
              backgroundColor: CustomStyle.secondaryColor,
              child: CircleAvatar(
                backgroundColor: CustomStyle.primaryColor,
                radius: 25,
                child: Text(
                  memberRoom.name.substring(0, 2).toUpperCase(),
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
            memberRoom.name,
            style:
                CustomStyle.customButtonTextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            memberRoom.email,
            style: CustomStyle.customButtonTextStyle(size: 13),
          ),
          trailing: type == "add"
              ? CircleAvatar(
                  backgroundColor: Colors.green,
                  child: IconButton(
                      color: Colors.white,
                      onPressed: () {
                        Provider.of<RoomProvider>(context, listen: false)
                            .addMember(memberRoom.room, memberRoom.id);
                      },
                      icon: Icon(Icons.add)),
                )
              : CircleAvatar(
                  backgroundColor: Colors.red,
                  child: IconButton(
                      onPressed: () {
                        Provider.of<RoomProvider>(context, listen: false)
                            .removeMember(memberRoom.room, memberRoom.id);
                      },
                      icon: Icon(
                        Icons.delete_outline_outlined,
                        color: Colors.white,
                      )),
                ),
        ),
      ),
    );
  }
}
