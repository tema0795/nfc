import 'package:flutter/material.dart';
import "../const.dart";

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String login = "";
  String password = "";

  AlertDialog loginAlert = AlertDialog(
    title: Text("Вход"),
    content: Text("Вход выполнен успешно!"),
    actions: [TextButton(onPressed: () => {}, child: const Text("ОК"))],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(APP_NAME)),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(PAGE_PADDING),
          shrinkWrap: true,
          children: [
            const Image(image: AssetImage("assets/images/logo.png")),
            TextField(
              decoration: const InputDecoration(hintText: "Логин"),
              onChanged: (value) => setState(() => login = value),
            ),
            TextField(
              decoration: const InputDecoration(hintText: "Пароль"),
              onChanged: (value) => setState(() => password = value),
              obscureText: true,
            ),
            ElevatedButton(
              child: const Text("Войти"),
              onPressed:
                  () => showDialog(
                    context: context,
                    builder: (BuildContext _) => loginAlert,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
