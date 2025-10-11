import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'pages/pin_code.dart';
import 'services/session_storage.dart';
import 'services/device_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<Widget> _startFuture = _decideStart();

  Future<Widget> _decideStart() async {
    // гарантируем, что deviceId существует
    await DeviceService.getOrCreateDeviceId();

    final hasPin = await SessionStorage.getHasPin();
    if (hasPin) {
      // если на этом устройстве уже настроен PIN — сразу просим ввести его
      return const PinCodePage(mode: PinCodeMode.verify);
    }
    // иначе стандартный логин/пароль
    return const LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _startFuture,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snap.data!;
      },
    );
  }
}
