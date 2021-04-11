import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../models/data_model.dart';
import '../../models/room_model.dart';
import '../../models/subject_model.dart';
import '../../services/token.dart';
import '../../styles.dart';

class CreateRoom extends StatelessWidget {
  static final routeName = "/createRoom";
  @override
  Widget build(BuildContext context) {
    Subject subject = ModalRoute.of(context).settings.arguments;
    Map<String, String> _room = {
      "room name": "",
      "room description": "",
    };
    final _formKey = GlobalKey<FormState>();

    Future addRoom() async {
      bool valid = _formKey.currentState.validate();
      if (valid) {
        _formKey.currentState.save();
        await Provider.of<RoomProvider>(context, listen: false)
            .addRoom(subject, _room);

        Fluttertoast.showToast(
            msg: DataModel.ROOM_TOAST,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);

        Navigator.of(context).pop();

        // create room channel entry in database with token generation
        String token = '';
        String channelName = _room['room name'];
        final db = FirebaseFirestore.instance;
        final result = await generateToken(channelName: channelName);
        print('Generated token for ' + channelName + ' : ' + result.token);
        token = result.token;
        // print(token);
        db
            .collection('RoomChannels')
            .doc(channelName)
            .set({"name": channelName, "token": token});
      }
    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Enter Room details : ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CustomStyle.primaryColor,
                      ),
                    ),
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    decoration: CustomStyle.customTextFieldDecoration(
                        labelText: DataModel.ROOM_NAME),
                    validator: (value) {
                      if (value == null || value.trim() == "")
                        return DataModel.REQUIRED;
                      return null;
                    },
                    onSaved: (value) {
                      _room["room name"] = value;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.name,
                    decoration: CustomStyle.customTextFieldDecoration(
                        labelText: DataModel.ROOM_DESC),
                    validator: (value) {
                      if (value == null || value.trim() == "")
                        return DataModel.REQUIRED;

                      return null;
                    },
                    onSaved: (value) {
                      _room["room description"] = value;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: CustomStyle.customElevatedButtonStyle(),
                      onPressed: () {
                        addRoom();
                      },
                      child: Text(
                        DataModel.NEXT,
                        style: CustomStyle.customButtonTextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
