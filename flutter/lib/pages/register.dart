import 'package:flutter/material.dart';
import 'package:onymus/const.dart';
import 'package:onymus/widgets/alert.dart';
import 'package:onymus/widgets/appbar.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String login = "";
  String password = "";
  String confirmPassword = "";

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
            TextField(
              decoration: const InputDecoration(
                hintText: "Подтверждение пароля",
              ),
              onChanged: (value) => setState(() => confirmPassword = value),
              obscureText: true,
            ),
            ElevatedButton(
              child: const Text("Зарегистрироваться"),
              onPressed:
                  () => showDialog(
                    context: context,
                    builder:
                        (BuildContext c) => createOKAlert(
                          "Регистрация",
                          password == confirmPassword
                              ? "Регистрация прошла успешно!"
                              : "Пароли не совпадают!",
                          c,
                        ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
