import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';

import 'profile.dart';
import 'bottom_nav.dart';
import '../services/api_service.dart';
import '../services/device_service.dart';

class NfcSharePage extends StatefulWidget {
  const NfcSharePage({super.key});

  @override
  State<NfcSharePage> createState() => _NfcSharePageState();
}

class _NfcSharePageState extends State<NfcSharePage> {
  bool _busy = false;
  String? _status;

  Future<void> _startNfcFlow() async {
    setState(() {
      _busy = true;
      _status = null;
    });

    try {
      final deviceId = await DeviceService.getOrCreateDeviceId();
      final tokenResp = await ApiService().getNfcToken(deviceId);
      if (!mounted) return;
      if (tokenResp == null || tokenResp['token'] == null) {
        setState(() => _status = 'Не удалось получить токен для NFC');
        return;
      }
      final token = tokenResp['token'] as String;

      // 3) Ожидаем поднесение метки и читаем её UID
      String? tagUidHex;

      await NfcManager.instance.startSession(
        // Для начала можно ограничиться iso14443 и iso15693, чтобы не требовать FeliCa entitlement на iOS
        pollingOptions: {
          NfcPollingOption.iso14443, // NFC-A/B
          NfcPollingOption.iso15693, // NFC-V
          // NfcPollingOption.iso18092, // NFC-F (FeliCa) — добавь при необходимости и оформи entitlement на iOS
        },
        onDiscovered: (NfcTag tag) async {
          try {
            tagUidHex = _extractUidHex(tag);
          } catch (e) {
            tagUidHex = null;
          } finally {
            // Завершаем сессию как только получили (или не получили) UID
            await NfcManager.instance.stopSession();
          }
        },
      );

      if (!mounted) return;

      if (tagUidHex == null) {
        setState(() => _status = 'Не удалось прочитать UID метки');
        return;
      }

      // 4) Верификация на сервере
      final ok = await ApiService().verifyNfc(
        deviceId: deviceId,
        token: token,
        tagUid: tagUidHex!,
      );

      if (!mounted) return;
      setState(() {
        _status = ok ? 'Успешно: метка подтверждена' : 'Ошибка верификации NFC';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Ошибка: $e');
    } finally {
      if (!mounted) return;
      setState(() => _busy = false);
    }
  }

  /// Достаём UID в hex (верхний регистр) кроссплатформенно.
  /// v4: используем платформенные обёртки Android/iOS.
  String? _extractUidHex(NfcTag tag) {
    Uint8List? id;

    // ANDROID: быстрый доступ к UID
    final android = NfcTagAndroid.from(tag);
    if (android?.id != null) {
      id = android!.id;
    }

    // iOS: MiFare (ISO14443-A), ISO15693, FeliCa (ISO18092)
    if (id == null) {
      final mifare = MiFareIos.from(tag);
      if (mifare?.identifier != null) id = mifare!.identifier;
    }
    if (id == null) {
      final iso15693 = Iso15693Ios.from(tag);
      if (iso15693?.identifier != null) id = iso15693!.identifier;
    }
    if (id == null) {
      final felica = FeliCaIos.from(tag);
      // FeliCa имеет два идентификатора: IDm (уникальный ID карты) и PMm (производственный параметр)
      if (felica?.currentIDm != null) id = felica!.currentIDm;
    }

    if (id == null) return null;

    return id
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join('')
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060F20),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 240,
                height: 240,
                child: SvgPicture.asset('assets/wifi.svg', fit: BoxFit.contain),
              ),
              const SizedBox(height: 16),
              const Text(
                'Приложите устройство к NFC-метке',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Данные будут переданы автоматически',
                style: TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _busy ? null : _startNfcFlow,
                child: const Text('Сканировать NFC'),
              ),
              if (_busy) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
              if (_status != null) ...[
                const SizedBox(height: 12),
                Text(_status!, style: const TextStyle(color: Colors.white70)),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
              (route) => false,
            );
          }
        },
      ),
    );
  }
}
