
import 'package:flutter/cupertino.dart';
import 'package:iota/models/room_model.dart';

class MemberRoom{
  String id;
  String name;
  String email;
  Room room;
  MemberRoom({
    @required this.id,
    @required this.name,
    @required this.email,
    @required this.room,
    });
}