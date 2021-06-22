import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heart_beat_monitor/constants/theme.dart';
import 'package:heart_beat_monitor/pages/home_page/screen.dart';

void main() {
  runApp(MyApp());

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
    statusBarColor: Colors.transparent,
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heart monitor',
      home: HomePage(),
      theme: themeData,
      debugShowCheckedModeBanner: false,
    );
  }
}
