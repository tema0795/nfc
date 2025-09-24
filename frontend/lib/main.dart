import 'package:flutter/material.dart';
import 'pages/login.dart';

void main() {
  runApp(const OnymusApp());
}

class OnymusApp extends StatelessWidget {
  const OnymusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Onymus',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      home: const LoginPage(),
    );
  }
}