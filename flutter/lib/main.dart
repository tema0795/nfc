import 'package:flutter/material.dart';
import 'package:onymus/const.dart';
import 'package:onymus/pages/home.dart';

void main() {
  runApp(
    MaterialApp(
      title: appName,
      home: HomePage(),
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    ),
  );
}
