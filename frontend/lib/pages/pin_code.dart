import 'package:flutter/material.dart';
import 'nfc_share.dart';

class PinCodePage extends StatefulWidget {
  const PinCodePage({super.key});

  @override
  State<PinCodePage> createState() => _PinCodePageState();
}

class _PinCodePageState extends State<PinCodePage> {
  String _pin = "";
  String? _confirmPin;

  void _addDigit(String digit) {
    if (_pin.length < 4 && RegExp(r'^[0-9]$').hasMatch(digit)) {
      setState(() {
        _pin += digit;
      });
      if (_pin.length == 4) {
        _handlePinEntered();
      }
    }
  }

  void _deleteDigit() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _handlePinEntered() {
    if (_confirmPin == null) {
      // Первый ввод — запоминаем
      setState(() {
        _confirmPin = _pin;
        _pin = "";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Повторите PIN для подтверждения')),
      );
    } else {
      // Второй ввод — проверяем
      if (_pin == _confirmPin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN верный!')),
        );
        // После PIN → NFC
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NfcSharePage()),
        );
      } else {
        setState(() {
          _pin = "";
          _confirmPin = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN не совпадает')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _confirmPin == null ? 'Введите PIN' : 'Подтвердите PIN',
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
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _pin.length
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 50),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['1', '2', '3'].map((digit) => _buildKey(digit)).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['4', '5', '6'].map((digit) => _buildKey(digit)).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['7', '8', '9'].map((digit) => _buildKey(digit)).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 72, height: 72),
                      _buildKey("0"),
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: IconButton(
                          onPressed: _deleteDigit,
                          icon: const Icon(Icons.backspace, color: Colors.white),
                          iconSize: 36,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
        onPressed: () => _addDigit(digit),
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
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}