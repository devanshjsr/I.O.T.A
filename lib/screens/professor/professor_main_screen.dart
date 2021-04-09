import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/auth_provider.dart';

class ProfessorMainScreen extends StatelessWidget {
  static const routeName = "/professor_main_screen";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 60,
          width: 100,
          child: ElevatedButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false)
                  .signOutUser(context);
            },
            child: Container(
              child: Center(child: Text("SIGN-OUT")),
            ),
          ),
        ),
      ),
    );
  }
}
