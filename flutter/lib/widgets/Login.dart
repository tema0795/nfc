import 'dart:io';

import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String login = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(hintText: "Логин"),
            onChanged: (value) => setState(() => login = value),
          ),
          TextField(
            decoration: InputDecoration(hintText: "Пароль"),
            onChanged: (value) => setState(() => password = value),
          ),
          MaterialButton(
              child: Text("Войти"),
              onPressed: () => stdout.writeln("$login - $password"),
          ),
        ],
      ),
    );
  }
}
