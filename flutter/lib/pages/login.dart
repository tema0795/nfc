import 'package:flutter/material.dart';
import 'package:onymus/const.dart';
import 'package:onymus/widgets/alert.dart';
import 'package:onymus/widgets/appbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String login = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: onymusAppBar,
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(pagePadding),
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
                    builder:
                        (BuildContext c) =>
                            createOKAlert("Вход", "Вход выполнен успешно!", c),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
