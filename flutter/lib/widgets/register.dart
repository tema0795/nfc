import 'package:flutter/material.dart';
import 'package:nfc/API/register.dart';

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
  Future<NewUser>? _futureUser;

  AlertDialog registerAlert = AlertDialog(
    title: Text("Регистрация"),
    content: Text("Регистрация прошла успешно!"),
    actions: [
      TextButton(onPressed: () => {}, child: const Text("ОК")),
    ],
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
                    builder: (BuildContext _) => buildFutureBuilder()
                  ),
            ),
          ],
        ),
      ),
    );
  }

  FutureBuilder<NewUser> buildFutureBuilder() {
    _futureUser = NewUser.create(
                    username : login,
                    password: password,
                    password2: confirmPassword,
                  ).register();
    
    return FutureBuilder<NewUser>(
      future: _futureUser,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return registerAlert;
        } else if (snapshot.hasError) {
          return RegErrorAlert(errors: snapshot.error,);
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
class RegErrorAlert extends StatelessWidget {
  const RegErrorAlert({required this.errors, super.key});
  final Map<String, List<String>> errors;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Регистрация"),
      content: Column(children:
       errors.values.expand((list) => list).map((str) => Text(str)).toList()),
      actions: [TextButton(onPressed: () => {}, child: const Text("ОК"))],
    );
  }
}
