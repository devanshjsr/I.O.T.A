import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/data_model.dart';
import '../models/shared_preferences.dart';
import '../screens/user_profile_screen.dart';
import '../styles.dart';

//  Stateful widget to store the details of profile edits in a bottom sheet
//  and then save then to the corresponding user's profile data
class EditProfile extends StatefulWidget {
  final String mobileNumber;
  EditProfile({this.mobileNumber});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  //  form key(used to save review)
  final _formKey = GlobalKey<FormState>();

  String _newMobileNumber;

  //  To save changes
  Future _submitProfileEdit() async {
    final isValid = _formKey.currentState.validate();
    if (isValid) {
      //  trigger onSaved
      _formKey.currentState.save();
      try {
        var userType =
            MySharedPreferences.isStudent == true ? "Student" : "Faculty";
        String docid;
        //  First fetch the document id inside MyData of the particular user
        await FirebaseFirestore.instance
            .collection(userType)
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection("MyData")
            .get()
            .then((value) {
          docid = value.docs.first.id;
        });

        //  Use the fetched documrnt id to update changes
        await FirebaseFirestore.instance
            .collection(userType)
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection("MyData")
            .doc(docid)
            .update({
          "mobileNumber": _newMobileNumber,
        });
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(UserProfileScreen.routeName);
      } catch (error) {
        print(error);
        Fluttertoast.cancel();
        Fluttertoast.showToast(msg: DataModel.SOMETHING_WENT_WRONG);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10),
          child: Container(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 5,
                      color: CustomStyle.primaryColor,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 25),
                      alignment: Alignment.center,
                      child: Text(
                        DataModel.PROFILE_CHANGES_TAKE_TIME,
                        style: TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ),
                    TextFormField(
                      initialValue: widget.mobileNumber,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: CustomStyle.customTextFieldDecoration(
                        labelText: DataModel.MOBILE_NUMBER,
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value.length == 0) {
                          return DataModel.ENTER_MOBILE_NUMBER;
                        } else if (!RegExp(r'(^(?:[+0]9)?[0-9]{10,10}$)')
                            .hasMatch(value)) {
                          return DataModel.ENTER_VALID_MOBILE_NUMBER;
                        }
                        return null;
                      },
                      onSaved: (mobile) => _newMobileNumber = mobile,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    OutlinedButton(
                      style: CustomStyle.customOutlinedButtonStyle(),
                      child: Text(
                        DataModel.SAVE_CHANGES,
                        style: CustomStyle.customButtonTextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        _submitProfileEdit();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
