import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'animated_splash.dart';
import 'models/assignment_model.dart';
import 'models/auth_provider.dart';
import 'models/fcm_provider.dart';
import 'models/post_model.dart';
import 'models/room_model.dart';
import 'models/shared_preferences.dart';
import 'models/subject_model.dart';
import 'routes.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/professor/professor_main_screen.dart';
import 'screens/student/student_main_screen.dart';
import 'styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //  multiprovider with several childs change notifier for changes

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SubjectProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AssignmentProvider(),
        ),
        Provider<AuthProvider>(
          create: (_) => AuthProvider(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (ctx) => ctx.read<AuthProvider>().authStateChanges,
        ),
        ChangeNotifierProvider(
          create: (_) => FcmProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PostProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RoomProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "I.O.T.A",
        theme: ThemeData(
          scaffoldBackgroundColor: CustomStyle.backgroundColor,
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          accentColor: Colors.red,
          primaryColor: CustomStyle.secondaryColor,
          fontFamily: "OpenSans",
          highlightColor: Colors.white,
          textTheme: TextTheme(headline6: TextStyle(color: Colors.black)),
        ),
        themeMode: ThemeMode.light,
        home: AnimatedSplash(
          nextScreen: AuthenticationWrapper(),
        ),
        routes: routes,
      ),
    );
  }
}

//  Wrapper to check whether user is authenticated while splash screen is shown
//  Also checks whether user is faculty or student using a FutureBuilder
//  and accordingly directs to StudentMainPage or FacultyMainPage
class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //  initialize the fcm provider
    Provider.of<FcmProvider>(context, listen: false).initialize();
    //  To check whether user is logged in before or not
    final _firebaseUser = context.watch<User>();
    if (_firebaseUser == null)
      return WelcomeScreen();
    else {
      return FutureBuilder<bool>(
        future: MySharedPreferences.isStudentGet(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true)
              return StudentMainScreen();
            else
              return ProfessorMainScreen();
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    }
  }
}
