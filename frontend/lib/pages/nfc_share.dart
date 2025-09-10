import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/polling_options.dart';
import 'package:nfc_manager/ndef_record.dart';

class NfcSharePage extends StatefulWidget {
  const NfcSharePage({super.key});

  @override
  State<NfcSharePage> createState() => _NfcSharePageState();
}

class _NfcSharePageState extends State<NfcSharePage> {
  String _status = "Ожидание NFC-метки...";
  late NfcManager _nfcManager;

  @override
  void initState() {
    super.initState();
    _nfcManager = NfcManager.instance;
    _startNfcSession();
  }

  @override
  void dispose() {
    _nfcManager.stopSession();
    super.dispose();
  }

  Future<void> _startNfcSession() async {
    try {
      bool isAvailable = await _nfcManager.isAvailable();

      if (!isAvailable) {
        setState(() {
          _status = "NFC недоступен или выключен";
        });
        return;
      }

      await _nfcManager.startSession(
        pollingOptions: PollingOptions.all(), // ← Обязательно!
        onDiscovered: (NfcTag tag) async {
          final ndef = Ndef.from(tag);
          if (ndef == null || !ndef.isWritable) {
            setState(() {
              _status = "Метка не поддерживает запись";
            });
            return;
          }

          // Данные для записи
          final userData = "ФИО: Иванов Иван Иванович\nДолжность: Разработчик\nУровень доступа: Администратор";

          await ndef.write(NdefMessage([
            NdefRecord.text(userData),
          ]));

          setState(() {
            _status = "Данные успешно записаны!";
          });

          // Остановить сессию через 2 секунды
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pop(context);
        },
      );
    } catch (e) {
      setState(() {
        _status = "Ошибка: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A1328),
              Color(0xFF0D1B45),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.nfc, size: 80, color: Colors.white),
                const SizedBox(height: 30),
                Text(
                  _status,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Отмена',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}