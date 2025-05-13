import 'package:flutter/material.dart';
import "./widgets/login.dart";
import "./widgets/register.dart";
import "./const.dart";

class Home extends StatelessWidget {
  const Home({super.key});

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
            const Text(
              "Приветствую в $APP_NAME!",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const Text(
              "Это быстрое и удобное средство для доступа к зданиям!",
              textAlign: TextAlign.center,
            ),
            ListView(
              shrinkWrap: true,
              children: [
                ElevatedButton(
                  child: const Text("Зарегистрироваться"),
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const Register()),
                      ),
                ),
                ElevatedButton(
                  child: const Text("Войти"),
                  onPressed:
                      () => Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => const Login())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      title: APP_NAME,
      home: Home(),
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    ),
  );
}
