import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dialog/custom_dialog.dart';
import '../../models/auth_provider.dart';
import '../../models/data_model.dart';
import '../../screens/auth/signup_type_screen.dart';
import '../../styles.dart';
import '../professor/professor_main_screen.dart';
import '../student/student_main_screen.dart';

//  Screen to login with email and password
class LoginScreen extends StatelessWidget {
  static const routeName = "/login_screen";
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
                margin: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: CustomStyle.customElevatedButtonStyle(),
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(SignupTypeScreen.routeName);
                      },
                      child: Text(
                        DataModel.SIGNUP,
                        style: CustomStyle.customButtonTextStyle(
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: LoginAuthCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginAuthCard extends StatefulWidget {
  const LoginAuthCard({
    Key key,
  }) : super(key: key);

  @override
  _LoginAuthCardState createState() => _LoginAuthCardState();
}

class _LoginAuthCardState extends State<LoginAuthCard> {
  //  teddy animation type
  String animationType = "idle";

  final GlobalKey<FormState> _formKey = GlobalKey();
  //  Map to store all user data
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;

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

    //  Login user
    //  Redirect user to student/faculty homepage depending upon the loginResult
    final loginResult = await context
        .read<AuthProvider>()
        .loginWithEmailAndPassword(
            _authData["email"], _authData["password"], context);
    setState(() {
      _isLoading = false;
    });
    if (loginResult == "Student") {
      setState(() {
        animationType = "success";
      });
      Future.delayed(Duration(seconds: 1)).then((value) {
        Navigator.pop(context);
        Navigator.of(context).pushReplacementNamed(StudentMainScreen.routeName);
      });
    } else if (loginResult == "Faculty") {
      setState(() {
        animationType = "success";
      });
      Future.delayed(Duration(seconds: 1)).then((value) {
        Navigator.pop(context);
        Navigator.of(context)
            .pushReplacementNamed(ProfessorMainScreen.routeName);
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
  }

  @override
  //  All the TextFormFields inside a form with appropriate validations
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: CircleAvatar(
              radius: 88,
              backgroundColor: CustomStyle.secondaryColor,
              child: CircleAvatar(
                radius: 85,
                backgroundColor: Colors.white,
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
        ),
        Container(
          margin: EdgeInsets.only(top: 25),
          child: Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
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
                          labelText: DataModel.PASSWORD),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
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
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  CustomDialog.resetPasswordDialog(context);
                },
                child: Text(
                  DataModel.FORGOT_PASSWORD,
                  style: CustomStyle.customButtonTextStyle(
                    fontWeight: FontWeight.bold,
                    color: CustomStyle.secondaryColor,
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
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
