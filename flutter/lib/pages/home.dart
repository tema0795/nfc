import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onymus/const.dart';
import 'package:onymus/pages/login.dart';
import 'package:onymus/pages/register.dart';
import 'package:onymus/widgets/appbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: onymusAppBar,
      body: Center(
        child: Column(
          spacing: pageSpacing,
          //padding: EdgeInsets.all(pagePadding),
          //shrinkWrap: true,
          children: [
            SvgPicture.asset("assets/images/logo.svg"),
            //const Image(image: AssetImage("assets/images/logo.png")),
            const Text(
              "Приветствую в $appName!",
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
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      ),
                ),
                ElevatedButton(
                  child: const Text("Войти"),
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
