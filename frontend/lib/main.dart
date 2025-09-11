import 'package:flutter/material.dart';
import 'pages/welcome.dart';

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
      ),
      home: const WelcomePage(),
    );
  }
}