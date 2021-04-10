import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';
import 'package:provider/provider.dart';
import '../../models/data_model.dart';
import '../../models/subject_model.dart';
import '../../styles.dart';

class AddSubjects extends StatefulWidget {
  static final routeName = "/addSubjects";

  @override
  _AddSubjectsState createState() => _AddSubjectsState();
}

class _AddSubjectsState extends State<AddSubjects> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, String> _subjects = {
    'subject_name': "",
    'faculty_id': "",
    'des': "",
    'subject_code': "",
    'branch': "",
  };

  final Map<String, String> _professor = {
    'subject_code': "",
    'subject_name': "",
  };
  var isLoading = false;
  final String uid = FirebaseAuth.instance.currentUser.uid;

  final randomId = randomAlphaNumeric(6);

  @override
  Widget build(BuildContext context) {
    //_subjects['professor_name'] = (String) FirebaseFirestore.instance.collection("Faculty").doc(Uid).getC;
    _subjects['faculty_id'] = uid;
    _subjects['subject_code'] = randomId;
    _professor['subject_code'] = randomId;

    //method to add new subject

    void addSubject() async {
    final isValid = _formKey.currentState.validate();
    if (isValid) {
      _formKey.currentState.save();
      try{
      setState(() {
        isLoading = true;
      });

      Provider.of<SubjectProvider>(context,listen : false).addSubject(_professor,_subjects,uid);

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(
          msg: DataModel.SUBJECT_TOAST,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

          Navigator.of(context).pop();
    }
    catch(error){
    throw error;
    }
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
                      "Enter subject details:",
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
                        labelText: DataModel.SUBJECT_NAME),
                    validator: (value) {
                      if (value == null || value.trim() == "")
                        return DataModel.REQUIRED;
                      return null;
                    },
                    onSaved: (value) {
                      _subjects['subject_name'] = value;
                      _professor['subject_name'] = value;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.name,
                    decoration: CustomStyle.customTextFieldDecoration(
                        labelText: DataModel.SUBJECT_DESCRIPTION),
                    validator: (value) {
                      if (value == null || value.trim() == "")
                        return DataModel.REQUIRED;
                      if (value.length < 20)
                        return DataModel.INVALID_DESCRIPTION;
                      return null;
                    },
                    onSaved: (value) {
                      _subjects['des'] = value;
                    },
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  MultiSelect(
                    autovalidate: true,
                    titleText: DataModel.BRANCH,
                    validator: (value) {
                      if (value == null) {
                        return DataModel.INVALID_BRANCH;
                      }
                      return null;
                    },
                    
                    textField: 'display',
                    valueField: 'value',
                    filterable: true,
                    value: null,
                    required: true,
                    onSaved: (values) {
                      List branches = values;
                      String tmp = "";
                      branches.forEach((element) {
                        tmp += element + ",";
                      });
                      String str = tmp.substring(0, tmp.length - 1);
                      _subjects['branch'] = str;
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  if(isLoading==false)
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: CustomStyle.customElevatedButtonStyle(),
                      onPressed: () {
                        addSubject();
                      },
                      child: Text(
                        DataModel.ADD_SUBJECT,
                        style: CustomStyle.customButtonTextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if(isLoading==true)
                  Center(
                    child: CircularProgressIndicator(),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
