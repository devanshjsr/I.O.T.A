import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../styles.dart';

//  Class with a static method to view student profile using student id
class StudentProfileView {
  static void showStudentProfile(String studentId, BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return Dialog(
            child: Container(
              height: 400,
              width: 300,
              child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection("Student")
                    .doc(studentId)
                    .collection("MyData")
                    .get(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data.docs.isEmpty == true) {
                      return Container(
                        alignment: Alignment.center,
                        child: Text("Could not fetch profile"),
                      );
                    }
                    return Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          color: CustomStyle.primaryColor,
                          height: 40,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text(
                            "STUDENT PROFILE",
                            style: TextStyle(
                                color: CustomStyle.textLight,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        (snapshot.data.docs[0] as QueryDocumentSnapshot)
                                .data()
                                .containsKey("profile picture")
                            ? CircleAvatar(
                                radius: 60,
                                backgroundColor: CustomStyle.secondaryColor,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(55),
                                  child: Image.network(
                                    snapshot.data.docs[0]["profile picture"],
                                    fit: BoxFit.fill,
                                    height: 110,
                                    width: 110,
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                radius: 60,
                                backgroundColor: CustomStyle.secondaryColor,
                                child: CircleAvatar(
                                  backgroundColor: CustomStyle.primaryColor,
                                  radius: 55,
                                  child: Text(
                                    snapshot.data.docs[0]["name"]
                                        .substring(0, 2)
                                        .toUpperCase(),
                                    style: TextStyle(
                                        color: CustomStyle.backgroundColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2),
                                  ),
                                ),
                              ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.fromLTRB(10, 15, 10, 5),
                          child: TextFormField(
                            readOnly: true,
                            initialValue: snapshot.data.docs[0]["name"],
                            textAlign: TextAlign.start,
                            decoration: CustomStyle.customTextFieldDecoration(
                                labelText: "Name"),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                          child: TextFormField(
                            readOnly: true,
                            initialValue: snapshot.data.docs[0]["email"],
                            textAlign: TextAlign.start,
                            decoration: CustomStyle.customTextFieldDecoration(
                                labelText: "E-mail"),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                          child: TextFormField(
                            readOnly: true,
                            initialValue: snapshot.data.docs[0]["mobileNumber"],
                            textAlign: TextAlign.start,
                            decoration: CustomStyle.customTextFieldDecoration(
                                labelText: "Mobile Number"),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          );
        });
  }
}
