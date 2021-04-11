import 'package:flutter/material.dart';

//  Custom style for app

class CustomStyle {
  //  color-scheme
  static const Color primaryColor = Color(0xFF283c63);
  static Color secondaryColor = Color(0xFFf67280);
  static Color backgroundColor = Colors.blueGrey[50];
  static Color errorColor = Colors.red[700];
  static Color textLight = Colors.white;

  //  style for outlinedButton
  //  set isError = true for error color (default = false)
  static ButtonStyle customTextButtonStyle({bool isError = false}) =>
      TextButton.styleFrom(
        primary: Colors.white,
        side: BorderSide(width: 2, color: isError ? errorColor : primaryColor),
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      );

  //  style for outlinedButton
  //  set isError = true for error color (default = false)
  static ButtonStyle customOutlinedButtonStyle({bool isError = false}) =>
      ElevatedButton.styleFrom(
        primary: Colors.white,
        side: BorderSide(width: 2, color: isError ? errorColor : primaryColor),
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      );

  //  style for ElevatedButton
  //  set isError = true for error color (default = false)
  static ButtonStyle customElevatedButtonStyle({
    bool isError = false,
    double radius = 10,
  }) =>
      ElevatedButton.styleFrom(
        primary: isError ? errorColor : primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  //  style for the text for button
  //  set isError = true for error color (default = false)
  //  default fontSize = 16
  static TextStyle customButtonTextStyle({
    isError = false,
    double size = 16,
    Color color = primaryColor,
    FontWeight fontWeight = FontWeight.w500,
  }) =>
      TextStyle(
        color: isError ? errorColor : color,
        fontWeight: fontWeight,
        fontSize: size,
      );
  //  style for TextFields and TextFormFields
  //  set required labelText and hintText

  static InputDecoration customTextFieldDecoration({
    String labelText = "Label",
    String hintText = "",
    Icon prefixIcon,
    IconButton suffixIconBtn,
  }) =>
      InputDecoration(
        fillColor: Colors.white,
        filled: true,
        contentPadding: EdgeInsets.all(16),
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIconBtn,
        labelStyle: TextStyle(color: primaryColor),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: secondaryColor, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      );

  static BoxDecoration subjectTileStyle() => BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: CustomStyle.primaryColor.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 8), // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
        color: Colors.white,
      );

  static BoxDecoration quizTileStyle({bool isOngoing = true}) => BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: CustomStyle.primaryColor.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 8), // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
        color: isOngoing ? Colors.white : Colors.grey[350],
      );
}
