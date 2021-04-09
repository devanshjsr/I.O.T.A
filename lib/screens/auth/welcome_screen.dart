import 'package:flutter/material.dart';

import '../../models/data_model.dart';
import '../../models/welcome_slider_model.dart';
import '../../screens/auth/login_screen.dart';
import '../../widgets/welcome_slider_tile.dart';

class WelcomeScreen extends StatefulWidget {
  static const routeName = '/welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List<WelcomeSliderModel> welcomeSlides = [];
  //  Integer to keep track of current slide
  int slideIndex = 0;
  PageController controller;

  //  Widget to get grey dots to indicate page numbrer (between SKIP and NEXT)
  Widget _buildPageIndicator(bool isCurrentPage) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.0),
      height: isCurrentPage ? 10.0 : 6.0,
      width: isCurrentPage ? 10.0 : 6.0,
      decoration: BoxDecoration(
        color: isCurrentPage ? Colors.grey : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    welcomeSlides = getSlides();
    controller = PageController();
  }

  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery.of(context).padding;
    var deviceHeight =
        MediaQuery.of(context).size.height - padding.top - padding.bottom;

    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: deviceHeight - 50,
          child: PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                slideIndex = index;
              });
            },
            children: <Widget>[
              for (var i in welcomeSlides)
                WelcomeSliderTile(
                  imagePath: i.getImageAssetPath(),
                  title: i.getTitle(),
                  desc: i.getDesc(),
                ),
            ],
          ),
        ),
        bottomSheet: slideIndex != welcomeSlides.length - 1
            ? Container(
                height: deviceHeight / 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(16),
                      ),
                      onPressed: () {
                        controller.animateToPage(welcomeSlides.length - 1,
                            duration: Duration(milliseconds: 800),
                            curve: Curves.decelerate);
                      },
                      child: Text(
                        "SKIP",
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          fontSize: deviceHeight / 40,
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          for (int i = 0; i < welcomeSlides.length; i++)
                            i == slideIndex
                                ? _buildPageIndicator(true)
                                : _buildPageIndicator(false),
                        ],
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.all(16),
                      ),
                      onPressed: () {
                        controller.animateToPage(slideIndex + 1,
                            duration: Duration(milliseconds: 200),
                            curve: Curves.linear);
                      },
                      child: Text(
                        "NEXT",
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          fontSize: deviceHeight / 40,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(LoginScreen.routeName);
                },
                child: Container(
                  height: deviceHeight / 12,
                  color: Colors.blue[700],
                  alignment: Alignment.center,
                  child: Text(
                    DataModel.GET_STARTED_NOW,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: deviceHeight / 42,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
