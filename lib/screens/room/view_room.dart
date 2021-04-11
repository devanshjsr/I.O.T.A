import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/data_model.dart';
import '../../models/room_model.dart';
import '../../models/shared_preferences.dart';
import '../../models/subject_model.dart';
import '../subjects/subject_tile_shimmer.dart';
import 'room_tile.dart';

class ViewRoom extends StatelessWidget {
  static final routeName = "/viewRoom";
  @override
  Widget build(BuildContext context) {
    Subject subject = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text("View Rooms"),
      ),
      body: MySharedPreferences.isStudent
          ? FutureBuilder(
              future: Provider.of<RoomProvider>(context, listen: false)
                  .fetchMyRooms(subject),
              builder: (ctx, dataSnapShot) {
                if (dataSnapShot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 10,
                    itemBuilder: (ctx, index) => SubjectShimmerTile(),
                  );
                } else if (dataSnapShot.hasError) {
                  return Center(
                    child: Text(DataModel.SOMETHING_WENT_WRONG),
                  );
                } else {
                  return Consumer<RoomProvider>(
                    builder: (ctx, roomData, child) => RefreshIndicator(
                        child: ListView.builder(
                          itemCount: roomData.getMyRooms.length,
                          itemBuilder: (ctx, index) => RoomTile(
                            room: roomData.getMyRooms.toList()[index],
                          ),
                        ),
                        onRefresh: () {
                          return Provider.of<RoomProvider>(context,
                                  listen: false)
                              .fetchMyRooms(subject);
                        }),
                  );
                }
              } //  Using consumer here as if,
              )
          : FutureBuilder(
              future: Provider.of<RoomProvider>(context, listen: false)
                  .fetchAllRooms(subject),
              builder: (ctx, dataSnapShot) {
                if (dataSnapShot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 10,
                    itemBuilder: (ctx, index) => SubjectShimmerTile(),
                  );
                } else if (dataSnapShot.hasError) {
                  return Center(
                    child: Text(DataModel.SOMETHING_WENT_WRONG),
                  );
                } else {
                  return Consumer<RoomProvider>(
                    builder: (ctx, roomData, child) => RefreshIndicator(
                        child: ListView.builder(
                          itemCount: roomData.getAllRooms.length,
                          itemBuilder: (ctx, index) => RoomTile(
                            room: roomData.getAllRooms.toList()[index],
                          ),
                        ),
                        onRefresh: () {
                          return Provider.of<RoomProvider>(context,
                                  listen: false)
                              .fetchAllRooms(subject);
                        }),
                  );
                }
              } //  Using consumer here as if,
              ),
    );
  }
}
