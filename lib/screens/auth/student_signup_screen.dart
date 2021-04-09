import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/auth_provider.dart';
import '../../models/data_model.dart';
import '../../styles.dart';
import '../student/student_main_screen.dart';
import 'login_screen.dart';

//  Sigup screen to create an id for student
class StudentSignUpScreen extends StatelessWidget {
  static const routeName = "/student_signup_screen";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: CustomStyle.backgroundColor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: CustomStyle.customElevatedButtonStyle(),
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(LoginScreen.routeName);
                      },
                      child: Text(
                        DataModel.LOGIN,
                        style: CustomStyle.customButtonTextStyle(
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: StudentSignupAuthCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentSignupAuthCard extends StatefulWidget {
  const StudentSignupAuthCard({
    Key key,
  }) : super(key: key);

  @override
  _StudentSignupAuthCardState createState() => _StudentSignupAuthCardState();
}

class _StudentSignupAuthCardState extends State<StudentSignupAuthCard> {
  //  teddy animation type
  String animationType = "idle";

  final GlobalKey<FormState> _formKey = GlobalKey();
  //  Map to store all user data
  Map<String, String> _authData = {
    'name': '',
    'email': '',
    'mobileNumber': '',
    'password': '',
    'branch': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  String dropDownValue = "CSE";

  static List<String> branchNames = [
    "CSE",
    "IT",
    "ECE",
    "EE",
    "ME",
    "CHEM",
    "Civil",
    "PIE",
    "Bio-Tech",
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid data
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
      animationType = "idle";
    });
    // Sign user up
    final signUpResult = await context
        .read<AuthProvider>()
        .signUpWithEmailAndPassword(_authData, context, true);
    if (signUpResult == "Signed Up") {
      setState(() {
        animationType = "success";
      });
      Future.delayed(Duration(seconds: 1)).then((value) {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed(StudentMainScreen.routeName);
      });
    } else {
      setState(() {
        animationType = "fail";
        Future.delayed(Duration(seconds: 2)).then((value) {
          setState(() {
            animationType = "idle";
          });
        });
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  //  All the TextFormFields inside a form with appropriate validations
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(
              child: CircleAvatar(
                radius: 88,
                backgroundColor: CustomStyle.secondaryColor,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 85,
                  child: ClipOval(
                    child: FlareActor(
                      "assets/teddy.flr",
                      alignment: Alignment.center,
                      fit: BoxFit.contain,
                      animation: animationType,
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              CircularProgressIndicator(
                backgroundColor: CustomStyle.primaryColor,
              )
            else
              FloatingActionButton(
                onPressed: () {
                  _submit();
                },
                backgroundColor: CustomStyle.primaryColor,
                child: Icon(
                  Icons.arrow_forward,
                  color: Theme.of(context).highlightColor,
                  size: 30,
                ),
              ),
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 15, bottom: 10),
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    decoration: CustomStyle.customTextFieldDecoration(
                        labelText: DataModel.NAME),
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null ||
                          value.trim() == "" ||
                          value.length < 3) {
                        return DataModel.INVALID_NAME;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['name'] = value;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    decoration: CustomStyle.customTextFieldDecoration(
                        labelText: DataModel.EMAIL),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (!RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        return DataModel.INVALID_EMAIL;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['email'] = value;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: CustomStyle.customTextFieldDecoration(
                        labelText: DataModel.MOBILE_NUMBER),
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
                    onSaved: (value) {
                      _authData['mobileNumber'] = value;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: CustomStyle.primaryColor, width: 2)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Branch:",
                            style: TextStyle(
                              color: CustomStyle.primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Spacer(),
                        DropdownButton<String>(
                            value: dropDownValue,
                            icon: const Icon(Icons.arrow_drop_down),
                            iconSize: 35,
                            elevation: 20,
                            style: const TextStyle(
                                color: CustomStyle.primaryColor, fontSize: 18),
                            onChanged: (newValue) {
                              setState(() {
                                _authData['branch'] = newValue;
                                dropDownValue = newValue;
                              });
                            },
                            items: branchNames.map<DropdownMenuItem<String>>(
                              (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              },
                            ).toList()),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: CustomStyle.customTextFieldDecoration(
                        labelText: DataModel.PASSWORD),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value.isEmpty || value.length < 6) {
                        return DataModel.PASSWORD_MIN_LENGTH_LIMIT_ERROR;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['password'] = value;
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    // style: TextStyle(fontSize: 10),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: CustomStyle.customTextFieldDecoration(
                        labelText: DataModel.CONFIRM_PASSWORD),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return DataModel.PASSWORD_DONT_MATCH;
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(FocusNode()),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
