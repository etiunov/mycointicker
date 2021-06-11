import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mycointicker/home_screen.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'dart:io' show Platform;

bool get isIOS => foundation.defaultTargetPlatform == TargetPlatform.iOS;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          navLargeTitleTextStyle: TextStyle(
              fontWeight: FontWeight.bold, color: CupertinoColors.activeBlue),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

// class MyApp extends StatelessWidget {
//   dynamic _getPlatform() {
//     if (Platform.isIOS) {
//       return CupertinoApp(
//         theme: CupertinoThemeData(
//           textTheme: CupertinoTextThemeData(
//             navLargeTitleTextStyle: TextStyle(
//                 fontWeight: FontWeight.bold, color: CupertinoColors.activeBlue),
//           ),
//         ),
//         home: HomeScreen(),
//       );
//     } else if (Platform.isAndroid) {
//       return MaterialApp(
//         theme: ThemeData.dark().copyWith(
//             primaryColor: Colors.lightBlue,
//             scaffoldBackgroundColor: Colors.white),
//         home: HomeScreen(),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _getPlatform();
//   }
// }
