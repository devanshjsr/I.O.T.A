import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/auth_provider.dart';
import '../models/data_model.dart';
import '../models/shared_preferences.dart';
import '../styles.dart';
import '../widgets/app_drawer.dart';
import '../widgets/edit_profile_bottom_sheet.dart';

class UserProfileScreen extends StatefulWidget {
  static const routeName = "/user_profile_screen";

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  User _user;
  String _mobileNumber = "";
  String _name = "";
  String displayPictureUrl = "";
  static const CAMERA_REQUEST_CODE = 1000;
  static const GALLERY_REQUEST_CODE = 1001;
  File _image;
  bool updatingPhoto;

  @override
  void initState() {
    super.initState();
    updatingPhoto = false;
    try {
      var userType =
          MySharedPreferences.isStudent == true ? "Student" : "Faculty";
      _user = FirebaseAuth.instance.currentUser;
      FirebaseFirestore.instance
          .collection(userType)
          .doc(_user.uid)
          .collection("MyData")
          .get()
          .then((value) {
        value.docs.forEach((element) {
          setState(() {
            _mobileNumber = element.data()["mobileNumber"];
            _name = element.data()["name"];
            if (element.data().containsKey("profile picture"))
              displayPictureUrl = element.data()["profile picture"];
          });
        });
      });
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    void editProfile() {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (_) {
          return EditProfile(
            mobileNumber: _mobileNumber,
          );
        },
      );
    }

    // Delete photo from storage, MyData in cloud firestore and FirebaseAuth.photoUrl
    Future removeProfilePicture(String userType) async {
      //  If no photo to remove
      if (displayPictureUrl == "") {
        Navigator.of(context).pop();
        return;
      }
      Navigator.pop(context);

      setState(() {
        updatingPhoto = true;
      });
      String userId = FirebaseAuth.instance.currentUser.uid;

      //  Firestore
      QuerySnapshot data = await FirebaseFirestore.instance
          .collection(userType)
          .doc(userId)
          .collection("MyData")
          .get();
      String imageLink = data.docs.first.data()["profile picture"];
      await FirebaseFirestore.instance
          .collection(userType)
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection("MyData")
          .doc(data.docs.first.id)
          .update(
        {
          "profile picture": FieldValue.delete(),
        },
      );

      //  Storage
      if (imageLink != null) {
        StorageReference firebaseStorageRef =
            await FirebaseStorage().getReferenceFromUrl(imageLink);
        await firebaseStorageRef.delete();
      }

      //  FirebaseAuth
      await FirebaseAuth.instance.currentUser.updateProfile(photoURL: null);

      setState(() {
        displayPictureUrl = "";
        updatingPhoto = false;
      });
    }

    //  Function to add/ update display picture in storage, MyData in cloud firestore and FirebaseAuth.photoUrl
    Future getImage(int reqCode, String userType) async {
      String _imageUrl;
      Navigator.of(context).pop();

      setState(() {
        updatingPhoto = true;
      });
      final ip = ImagePicker();
      PickedFile image;
      if (reqCode == CAMERA_REQUEST_CODE) {
        image = await ip.getImage(source: ImageSource.camera);
      } else {
        image = await ip.getImage(source: ImageSource.gallery);
      }
      if (image != null) _image = File(image.path);

      if (_image != null) {
        setState(() {
          updatingPhoto = true;
        });
        //  First save image to Firebase Storage and then save it's fetched Url in FireStore

        String fileName = FirebaseAuth.instance.currentUser.uid;
        StorageReference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('Profile Pictures/$fileName');
        StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
        // await uploadTask.onComplete;
        StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

        //  Fetch imageUrl
        _imageUrl = await taskSnapshot.ref.getDownloadURL();

        //  Store at firestore
        QuerySnapshot data = await FirebaseFirestore.instance
            .collection(userType)
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection("MyData")
            .get();
        await FirebaseFirestore.instance
            .collection(userType)
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection("MyData")
            .doc(data.docs.first.id)
            .update(
          {
            "profile picture": _imageUrl,
          },
        );
        //  Store at FirebaseAuth
        await FirebaseAuth.instance.currentUser
            .updateProfile(photoURL: _imageUrl);
      }

      setState(() {
        updatingPhoto = false;
        displayPictureUrl = _imageUrl;
      });
    }

    void editDisplayPicture(Offset offset) {
      String userType;

      if (MySharedPreferences.isStudent) {
        //  student-options
        userType = "Student";
      } else {
        //  faculty-options
        userType = "Faculty";
      }
      double left = offset.dx;
      double top = offset.dy;
      List<PopupMenuEntry<int>> options = [
        PopupMenuItem(
          value: 2,
          child: Column(
            children: [
              Text(
                "Update",
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      getImage(CAMERA_REQUEST_CODE, userType);
                    },
                    icon: Icon(Icons.camera),
                  ),
                  IconButton(
                    onPressed: () {
                      getImage(GALLERY_REQUEST_CODE, userType);
                    },
                    icon: Icon(Icons.photo),
                  ),
                ],
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: GestureDetector(
              onTap: () async {
                removeProfilePicture(userType);
              },
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "Remove",
                ),
              )),
        ),
      ];
      showMenu(
          context: context,
          position: RelativeRect.fromLTRB(left, top - 160, 10, 10),
          items: options);
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: -5,
          title: Text("My profile"),
          actions: [
            IconButton(
              onPressed: () {
                editProfile();
              },
              icon: Icon(Icons.edit),
            ),
          ],
        ),
        body: _mobileNumber == "" || updatingPhoto
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Center(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                            ),
                            displayPictureUrl != "" && displayPictureUrl != null
                                ? CircleAvatar(
                                    radius: 140,
                                    backgroundColor: CustomStyle.secondaryColor,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(140),
                                      child: Image.network(
                                        displayPictureUrl,
                                        fit: BoxFit.fill,
                                        height: 266,
                                        width: 266,
                                        errorBuilder:
                                            (ctx, object, stacktrace) {
                                          return Image.asset(
                                            "assets/images/logo.png",
                                            fit: BoxFit.fill,
                                            height: 266,
                                            width: 266,
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 100,
                                    backgroundColor: CustomStyle.secondaryColor,
                                    child: CircleAvatar(
                                      backgroundColor: CustomStyle.primaryColor,
                                      radius: 94,
                                      child: Text(
                                        _name.substring(0, 2).toUpperCase(),
                                        style: TextStyle(
                                          color: CustomStyle.backgroundColor,
                                          fontSize: 80,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                            GestureDetector(
                              onTapDown: (data) {
                                editDisplayPicture(data.globalPosition);
                              },
                              child: Icon(
                                Icons.edit,
                                size: 30,
                                color: CustomStyle.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                          child: TextFormField(
                            readOnly: true,
                            initialValue: _name,
                            textAlign: TextAlign.start,
                            decoration: CustomStyle.customTextFieldDecoration(
                                labelText: "Name"),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                          child: TextFormField(
                            readOnly: true,
                            initialValue: _user.email,
                            textAlign: TextAlign.start,
                            decoration: CustomStyle.customTextFieldDecoration(
                                labelText: "E-mail"),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 20),
                          child: TextFormField(
                            readOnly: true,
                            initialValue: _mobileNumber,
                            textAlign: TextAlign.start,
                            decoration: CustomStyle.customTextFieldDecoration(
                                labelText: "Mobile Number"),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            OutlinedButton(
                              style: CustomStyle.customOutlinedButtonStyle(),
                              child: Text(
                                DataModel.EDIT_PROFILE,
                                style: CustomStyle.customButtonTextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                editProfile();
                              },
                            ),
                            OutlinedButton(
                              style: CustomStyle.customOutlinedButtonStyle(
                                  isError: true),
                              child: Text(
                                DataModel.SIGN_OUT,
                                style: CustomStyle.customButtonTextStyle(
                                    fontWeight: FontWeight.bold, isError: true),
                              ),
                              onPressed: () {
                                Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .signOutUser(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        drawer: AppDrawer(DataModel.MY_PROFILE),
      ),
    );
  }
}
