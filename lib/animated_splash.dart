import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'styles.dart';

//  Animated splash screen to be shown when opening app
class AnimatedSplash extends StatelessWidget {
  @required
  final Widget nextScreen;
  AnimatedSplash({this.nextScreen});
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 3500,
      splashIconSize: 300,
      animationDuration: Duration(milliseconds: 800),
      centered: true,
      curve: Curves.easeInCubic,
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset(
            "assets/splash.gif",
            fit: BoxFit.contain,
            width: 300,
          ),
          Text(
            "I.O.T.A.",
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: CustomStyle.primaryColor,
                letterSpacing: 5,
                shadows: [
                  Shadow(
                      blurRadius: 15,
                      color: Colors.green[300],
                      offset: Offset(0, 5))
                ]),
          ),
          SizedBox(height: 15),
          Shimmer.fromColors(
            period: Duration(seconds: 1),
            baseColor: Colors.green[300],
            highlightColor: CustomStyle.primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  height: 15.0,
                  width: 15.0,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  height: 15.0,
                  width: 15.0,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  height: 15.0,
                  width: 15.0,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.white,
      nextScreen: nextScreen,
    );
  }
}
