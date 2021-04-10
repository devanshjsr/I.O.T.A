import 'package:flutter/material.dart';
import 'package:iota/assignment/view_assignment.dart';
import 'package:iota/assignment/view_assignment_argument.dart';
import 'package:iota/assignment/view_submission.dart';
import 'package:iota/dialog/custom_dialog.dart';
import 'package:iota/models/assignment_model.dart';
import 'package:iota/models/shared_preferences.dart';
import 'package:iota/styles.dart';
class AssignmentTile extends StatelessWidget {
  final Assignment assignment;
  final String type;
  AssignmentTile({@required this.assignment, @required this.type});

  @override
  Widget build(BuildContext context) {
    viewAssignment() {
      if (MySharedPreferences.isStudent)
        Navigator.of(context).pushNamed(ViewAssignment.routeName,
            arguments: AssignmentArgument(assignment: assignment, type: type));
      else {
        Navigator.of(context)
            .pushNamed(ViewSubmission.routeName, arguments: assignment);
      }
    }

    assignmentOptions(Offset offset) {
        CustomDialog.showAssignmentDialog(context, offset, assignment,type);
    }

    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        decoration: CustomStyle.subjectTileStyle(),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: ListTile(
          onTap: () {
            viewAssignment();
            print(assignment.url);
          },
          leading: Hero(
            tag: assignment.id,
            child: CircleAvatar(
              radius: 35,
              backgroundColor: CustomStyle.secondaryColor,
              child: CircleAvatar(
                backgroundColor: CustomStyle.primaryColor,
                radius: 25,
                child: Text(
                  assignment.name.substring(0, 2).toUpperCase(),
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
            assignment.name,
            style:
                CustomStyle.customButtonTextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Due Date :  " + assignment.dueDate,
            style: CustomStyle.customButtonTextStyle(size: 14),
          ),
          trailing: MySharedPreferences.isStudent
              ? SizedBox(width: 5)
              : GestureDetector(
                  onTapDown: (data) {
                    assignmentOptions(data.globalPosition);
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
