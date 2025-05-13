import 'package:flutter/material.dart';
import "widgets/Login.dart";

void main() {
  runApp(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text("Onymus")),
            body: Login(),
        ),
      ),
  );
}