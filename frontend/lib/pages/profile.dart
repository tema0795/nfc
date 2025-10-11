import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'nfc_share.dart';
import 'bottom_nav.dart';
import 'login.dart';

import '../services/api_service.dart';
import '../services/session_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final Future<Map<String, dynamic>?> _profileFuture =
      ApiService().getProfile();

  String _value(dynamic v) {
    if(v == null) return "-";
    final s = v.toString().trim();
    return s;
  }

  Future<void> _logout() async {
    // локальный выход: чистим токены и убираем PIN-гейт
    await ApiService().logout();
    await SessionStorage.setHasPin(false);

    if (!mounted) return;
    // сносим стек и уходим на логин
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF0E1A33),
            title: const Text(
              'Выйти из аккаунта?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Требуется повторный вход по логину/паролю.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Выйти'),
              ),
            ],
          ),
    );

    if (ok == true) {
      await _logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060F20),
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            tooltip: 'Выйти',
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 16,
          ),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _profileFuture,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = snap.data;
              if (data == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Не удалось загрузить профиль',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                );
              }

              final lastName = _value(data['last_name']);
              final firstName = _value(data['first_name']);
              final middle = _value(data['middle_name']);
              final email = _value(data['email']);
              final position = _value(data['position']);
              final org = _value(data['organization']);
              final level = _value(
                data['access_level_label'] ?? data['access_level'],
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: SvgPicture.asset(
                      'assets/account_circle.svg',
                      width: 40,
                      height: 40,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Данные:',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),

                  _ProfileRow(
                    label: 'Фамилия Имя Отчество',
                    value: '$lastName $firstName $middle',
                  ),
                  const SizedBox(height: 12),
                  _ProfileRow(label: 'Почта', value: email),
                  const SizedBox(height: 12),
                  _ProfileRow(label: 'Должность', value: position),
                  const SizedBox(height: 12),
                  _ProfileRow(label: 'Организация', value: org),
                  const SizedBox(height: 12),
                  _ProfileRow(label: 'Уровень доступа', value: level),

                  const Spacer(),
                  // Кнопка выхода внизу
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _confirmLogout,
                      icon: const Icon(Icons.logout),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFED5A5A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      label: const Text(
                        'Выйти',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const NfcSharePage()),
              (route) => false,
            );
          }
        },
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
