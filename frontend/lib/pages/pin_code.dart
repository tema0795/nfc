import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/device_service.dart';
import 'nfc_share.dart';

enum PinCodeMode { setup, verify }

class PinCodePage extends StatefulWidget {
  const PinCodePage({super.key, this.mode = PinCodeMode.setup});

  final PinCodeMode mode;

  @override
  State<PinCodePage> createState() => _PinCodePageState();
}

class _PinCodePageState extends State<PinCodePage> {
  String _pin = "";
  String? _confirmPin; // используется только в setup-режиме
  bool _busy = false;
  String? _error;
  late Future<String> _deviceIdFuture;

  @override
  void initState() {
    super.initState();
    _deviceIdFuture = DeviceService.getOrCreateDeviceId();
  }

  void _addDigit(String digit) {
    if (_busy) return;
    if (_pin.length < 4 && RegExp(r'^\d$').hasMatch(digit)) {
      setState(() => _pin += digit);
      if (_pin.length == 4) _handlePinEntered();
    }
  }

  void _deleteDigit() {
    if (_busy) return;
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  Future<void> _handlePinEntered() async {
    setState(() {
      _error = null;
      _busy = true;
    });

    try {
      if (widget.mode == PinCodeMode.verify) {
        // Вход по PIN
        final deviceId = await _deviceIdFuture;
        final ok = await ApiService().verifyPin(deviceId, _pin);
        if (ok) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Вход по PIN выполнен')));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const NfcSharePage()),
          );
        } else {
          setState(() => _error = 'Неверный PIN или истёк доступ');
          _resetPinOnly();
        }
      } else {
        // Установка PIN (двухэтапное подтверждение)
        if (_confirmPin == null) {
          setState(() {
            _confirmPin = _pin;
            _pin = "";
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Повторите PIN для подтверждения')),
            );
          }
        } else {
          if (_pin == _confirmPin) {
            final deviceId = await _deviceIdFuture;
            final ok = await ApiService().setPin(_pin, deviceId: deviceId);
            if (ok) {
              if (!mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('PIN сохранён')));
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const NfcSharePage()),
              );
            } else {
              setState(() => _error = 'Не удалось сохранить PIN. Повторите.');
              _resetAll();
            }
          } else {
            setState(() => _error = 'PIN не совпадает');
            _resetAll();
          }
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _resetPinOnly() {
    setState(() => _pin = "");
  }

  void _resetAll() {
    setState(() {
      _pin = "";
      _confirmPin = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSetup = widget.mode == PinCodeMode.setup;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isSetup
                    ? (_confirmPin == null ? 'Введите PIN' : 'Подтвердите PIN')
                    : 'Введите PIN для входа',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Введите 4 цифры',
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 30),

              // Индикаторы точек
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          index < _pin.length
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 50),

              // Клавиатура
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['1', '2', '3'].map(_buildKey).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['4', '5', '6'].map(_buildKey).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['7', '8', '9'].map(_buildKey).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 72, height: 72),
                      _buildKey('0'),
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: IconButton(
                          onPressed: _busy ? null : _deleteDigit,
                          icon: const Icon(
                            Icons.backspace,
                            color: Colors.white,
                          ),
                          iconSize: 36,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_busy) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String digit) {
    return SizedBox(
      width: 72,
      height: 72,
      child: ElevatedButton(
        onPressed: _busy ? null : () => _addDigit(digit),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Text(
          digit,
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
