import 'package:flutter/material.dart';
import 'package:iota/dialog/custom_dialog.dart';
import 'package:iota/styles.dart';
import 'package:fluttertoast/fluttertoast.dart';
class CustomFAB extends StatefulWidget {
  @override
  _CustomFABState createState() => _CustomFABState();
}

class _CustomFABState extends State<CustomFAB>
    with SingleTickerProviderStateMixin {
  double degreeToRadians(double degree) {
    return degree / 57.295779513;
  }

  AnimationController animationController;
  Animation degOneTranslationAnimation,
      degTwoTranslationAnimation,
      degThreeTranslationAnimation;
  Animation rotationAnimation;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween(begin: 0.0, end: 1.3), weight: 70.0),
      TweenSequenceItem<double>(
          tween: Tween(begin: 1.3, end: 1.0), weight: 30.0)
    ]).animate(animationController);

    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween(begin: 0.0, end: 1.5), weight: 60.0),
      TweenSequenceItem<double>(
          tween: Tween(begin: 1.5, end: 1.0), weight: 40.0)
    ]).animate(animationController);

    degThreeTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween(begin: 0.0, end: 1.7), weight: 20.0),
      TweenSequenceItem<double>(
          tween: Tween(begin: 1.7, end: 1.0), weight: 80.0)
    ]).animate(animationController);

    rotationAnimation = Tween<double>(begin: 180.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));

    super.initState();

    animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void changeFABstate() {
      if (animationController.isCompleted) {
        animationController.reverse();
      } else {
        animationController.forward();
      }
    }

    return Container(
      child: Stack(
        children: [
          Positioned(
            right: 10,
            bottom: 10,
            child: Stack(alignment: AlignmentDirectional.bottomEnd, children: [
              //  Used to enable the onClick behaviour of small btns after they move
              IgnorePointer(
                child: Container(
                  height: 150.0,
                  width: 150.0,
                ),
              ),
              Transform.translate(
                offset: Offset.fromDirection(degreeToRadians(270),
                    degOneTranslationAnimation.value * 100),
                child: Transform(
                  transform: Matrix4.rotationZ(
                      degreeToRadians(rotationAnimation.value))
                    ..scale(degOneTranslationAnimation.value),
                  alignment: Alignment.center,
                  child: CircularButton(
                    color: CustomStyle.secondaryColor,
                    onPressed: () {
                      Fluttertoast.showToast(msg: "Hey");
                      
                    },
                    icon: Icon(Icons.search),
                    height: 50,
                    width: 50,
                    iconSize: 30,
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset.fromDirection(degreeToRadians(225),
                    degTwoTranslationAnimation.value * 100),
                child: Transform(
                  transform: Matrix4.rotationZ(
                      degreeToRadians(rotationAnimation.value))
                    ..scale(degTwoTranslationAnimation.value),
                  alignment: Alignment.center,
                  child: CircularButton(
                    color: CustomStyle.secondaryColor,
                    onPressed: () {
                      //  TODO: Implement barcode for subject search
                      print("CLICKED ON BARCODE");
                      Fluttertoast.showToast(msg: "Coming soon");
                      changeFABstate();
                    },
                    icon: Icon(Icons.qr_code),
                    height: 50,
                    width: 50,
                    iconSize: 30,
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset.fromDirection(degreeToRadians(180),
                    degThreeTranslationAnimation.value * 100),
                child: Transform(
                  transform: Matrix4.rotationZ(
                      degreeToRadians(rotationAnimation.value))
                    ..scale(degThreeTranslationAnimation.value),
                  alignment: Alignment.center,
                  child: CircularButton(
                    color: CustomStyle.secondaryColor,
                    onPressed: () {
                      CustomDialog.showJoinDialog(context);
                      changeFABstate();
                    },
                    icon: Icon(Icons.text_fields),
                    height: 50,
                    width: 50,
                    iconSize: 30,
                  ),
                ),
              ),
              Transform(
                transform:
                    Matrix4.rotationZ(degreeToRadians(rotationAnimation.value)),
                alignment: Alignment.center,
                child: CircularButton(
                  color: CustomStyle.primaryColor,
                  onPressed: () {
                    changeFABstate();
                  },
                  icon: Icon(
                    rotationAnimation.value == 0 ? Icons.remove : Icons.add,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class CircularButton extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Icon icon;
  final Function onPressed;
  final double iconSize;

  CircularButton({
    this.width = 65,
    this.height = 65,
    this.iconSize = 35,
    @required this.color,
    @required this.icon,
    @required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      width: width,
      height: height,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: Colors.white,
        enableFeedback: true,
        iconSize: iconSize,
      ),
    );
  }
}
