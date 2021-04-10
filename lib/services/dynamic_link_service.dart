import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../dialog/custom_dialog.dart';
import '../models/data_model.dart';
import '../models/shared_preferences.dart';
import '../models/subject_model.dart';
import '../screens/subjects/subject_bottom_navbar.dart';

class DynamicLinkService {
  //  Method to create a sharable Short Url for a subject
  static Future<Uri> createDynamicLink(Subject subject) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: "http://sharequizapp.page.link",
      link: Uri.parse(
          "http://sharequizapp.page.link/share_subject?subject_code=${subject.subjectCode}"),
      androidParameters: AndroidParameters(
        packageName: "com.example.QuizApp",
        minimumVersion: 0,
        fallbackUrl: Uri.parse("http://www.example.com"),
      ),
      iosParameters: IosParameters(
        bundleId: "com.example.QuizApp",
        minimumVersion: "0",
        fallbackUrl: Uri.parse("http://www.example.com"),
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: subject.name,
        description: "Join my subject",
        imageUrl: Uri.parse(
          DataModel.APP_ICON_PNG,
        ),
      ),
    );

    ShortDynamicLink url = await parameters.buildShortLink();
    return url.shortUrl;
  }

  static void initDynamicLinks(BuildContext context) async {
    //  When app is resumed from background
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      _handleDeepLink(dynamicLink, context);
    }, onError: (OnLinkErrorException e) async {
      Fluttertoast.showToast(msg: "ON LINK ERROR ${e.message}");
    });

    //  When app is started
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    _handleDeepLink(data, context);
  }

  //  If the current user is student, redirect to subject details page
  //  If the current user is faculty
  //  ---If subject is owned by the user, show subject details page
  //  ---If subject is not owned by user, display a toast
  static void _handleDeepLink(
      PendingDynamicLinkData data, BuildContext context) async {
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      print("_handleDynamicLink | deeplink $deepLink");

      var isSubject = deepLink.pathSegments.contains("share_subject");

      if (isSubject) {
        var subjectCode = deepLink.queryParameters["subject_code"];
        if (subjectCode != null) {
          //  Navigate to the subject details page
          Subject subject =
              await SubjectProvider.fetchSubjectUsingCode(subjectCode)
                  .catchError(
            (error) {
              CustomDialog.generalErrorDialog(context: context);
            },
          );
          if (subject == null) {
            CustomDialog.generalErrorDialog(
              context: context,
              content: "Invalid subject code",
            );
          } else {
            if (MySharedPreferences.isStudent) {
              Navigator.of(context).pushNamed(
                SubjectBottomNavBar.routeName,
                arguments: subject,
              );
            } else {
              if (subject.facultyId == FirebaseAuth.instance.currentUser.uid) {
                //  Subject owned by faculty
                Navigator.of(context).pushNamed(
                  SubjectBottomNavBar.routeName,
                  arguments: subject,
                );
              } else {
                CustomDialog.generalErrorDialog(
                  context: context,
                  content: "You do not own this subject",
                );
              }
            }
          }
        }
      }
    }
    //  WITHOUT DEEP LINK
    else {
      print("NOT THROUGH DYNAMIC LINK");
    }
  }
}
