import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_nav.dart';
import 'dart:io' show exit;

class PinCodePage extends StatefulWidget {
  const PinCodePage({super.key});

  @override
  State<PinCodePage> createState() => _PinCodePageState();
}

class _PinCodePageState extends State<PinCodePage> {
  String _pin = "";
  String? _confirmPin;

  void _addDigit(String digit) {
    if (_pin.length < 4) {
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

  void _exit() {
    exit(0);
  }

  Future<void> _handlePinEntered() async {
    final prefs = await SharedPreferences.getInstance();
    final isPinSet = prefs.getBool('pin_set') ?? false;

    if (!isPinSet) {
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
          await prefs.setString('user_pin', _pin);
          await prefs.setBool('pin_set', true);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PIN успешно установлен!')),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BottomNavPage()),
            );
          }
        } else {
          setState(() {
            _pin = "";
            _confirmPin = null;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PIN не совпадает. Попробуйте снова.')),
            );
          }
        }
      }
    } else {
      final savedPin = prefs.getString('user_pin');
      if (_pin == savedPin) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Вход выполнен!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavPage()),
          );
        }
      } else {
        setState(() {
          _pin = "";
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Неверный PIN')),
          );
        }
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
                _confirmPin == null
                    ? 'Создайте PIN-код'
                    : 'Подтвердите PIN',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Введите 4 цифры',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
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
                    children: [1, 2, 3].map((digit) {
                      return _buildKey(digit.toString());
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [4, 5, 6].map((digit) {
                      return _buildKey(digit.toString());
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [7, 8, 9].map((digit) {
                      return _buildKey(digit.toString());
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: TextButton(
                          onPressed: _exit,
                          child: Text(
                            'Выйти',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),

                      _buildKey("0"),

                      SizedBox(
                        width: 72,
                        height: 72,
                        child: IconButton(
                          onPressed: _deleteDigit,
                          icon: Icon(Icons.arrow_back,
                              color: _pin.isNotEmpty ? Colors.white : Colors.white.withOpacity(0.5)),
                          iconSize: 28,
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