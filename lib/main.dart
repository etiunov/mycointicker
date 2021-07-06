import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mycointicker/home_screen.dart';
import 'package:flutter/foundation.dart' as foundation;

bool get isIOS => foundation.defaultTargetPlatform == TargetPlatform.iOS;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        brightness: null,
        primaryColor: CupertinoColors.activeBlue,
        primaryContrastingColor: CupertinoColors.black,
        barBackgroundColor: CupertinoDynamicColor.withBrightness(
          color: Color(0xF0F9F9F9),
          darkColor: Color(0xF01D1D1D),
        ),
        scaffoldBackgroundColor: CupertinoColors.white,
        textTheme: CupertinoTextThemeData(
          primaryColor: CupertinoColors.white,
          textStyle: TextStyle(color: CupertinoColors.black),
          actionTextStyle: TextStyle(color: CupertinoColors.activeBlue),
          tabLabelTextStyle: TextStyle(color: CupertinoColors.activeBlue),
          navTitleTextStyle: TextStyle(
              fontWeight: FontWeight.bold, color: CupertinoColors.black),
          navActionTextStyle: TextStyle(
              fontWeight: FontWeight.bold, color: CupertinoColors.activeBlue),
          pickerTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: CupertinoColors.darkBackgroundGray),
          dateTimePickerTextStyle: TextStyle(
              fontWeight: FontWeight.bold, color: CupertinoColors.activeBlue),
          navLargeTitleTextStyle: TextStyle(
              fontWeight: FontWeight.bold, color: CupertinoColors.activeBlue),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
