import 'package:flutter/material.dart';
import "../const.dart";

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String login = "";
  String password = "";
  String confirmPassword = "";

  AlertDialog registerAlert = AlertDialog(
    title: Text("Регистрация"),
    content: Text("Регистрация прошла успешно!"),
    actions: [TextButton(onPressed: () => {}, child: const Text("ОК"))],
  );

  AlertDialog passwordAlert = AlertDialog(
    title: Text("Регистрация"),
    content: Text("Пароли не совпадают!"),
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
                        (BuildContext _) =>
                            password == confirmPassword
                                ? registerAlert
                                : passwordAlert,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
