import 'package:flutter/material.dart';
import 'package:iota/models/subject_model.dart';
import 'package:iota/styles.dart';
import 'package:shimmer/shimmer.dart';


class SubjectTile extends StatelessWidget {
  final Subject subject;
  SubjectTile({@required this.subject});
  @override
  Widget build(BuildContext context) {
    //  Method to show options for a subject
    //  Shown options depends on whether the user is student or faculty
    
    return GestureDetector(
      onLongPressStart: (data) {
        
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        decoration: CustomStyle.subjectTileStyle(),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: ListTile(
          onTap: () {
            
          },
          leading: Hero(
            tag: subject.id,
            child: CircleAvatar(
              radius: 35,
              backgroundColor: CustomStyle.secondaryColor,
              child: CircleAvatar(
                backgroundColor: CustomStyle.primaryColor,
                radius: 25,
                child: Text(
                  subject.name.substring(0, 2).toUpperCase(),
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
            subject.name,
            style:
                CustomStyle.customButtonTextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: FutureBuilder(
              future: Subject.getFacultyNameFromFacultyId(subject.facultyId),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      snapshot.data,
                      style: CustomStyle.customButtonTextStyle(size: 14),
                    ),
                  );
                } else {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.grey[100],
                    child: FractionallySizedBox(
                      alignment: Alignment.topLeft,
                      widthFactor: 0.7,
                      child: Container(
                        margin: EdgeInsets.only(top: 5),
                        height: 14,
                        color: CustomStyle.primaryColor,
                      ),
                    ),
                  );
                }
              }),
          trailing: GestureDetector(
            onTapDown: (data) {
            },
            child: Icon(
              Icons.more_vert_rounded,
              size: 35,
              color: CustomStyle.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
