import 'package:flutter/material.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String avatarUrl = '';

  void _changeAvatar() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.white),
                title: const Text('Выбрать из галереи', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Функция выбора из галереи временно недоступна')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('Сделать фото', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Функция камеры временно недоступна')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Удалить аватар', style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() {
                    avatarUrl = '';
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Аватар удалён')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: _changeAvatar,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: avatarUrl.isEmpty
                            ? const Icon(Icons.person, color: Colors.white, size: 32)
                            : Image.network(avatarUrl, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text('Данные:', style: TextStyle(fontSize: 12, color: Colors.grey[300], fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Text('Фамилия Имя Отчество', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('example@onymus.com', style: TextStyle(fontSize: 14, color: Colors.grey[300])),
                    const SizedBox(height: 8),
                    Text('Разработчик', style: TextStyle(fontSize: 14, color: Colors.grey[300])),
                    const SizedBox(height: 8),
                    Text('Компания Onymus', style: TextStyle(fontSize: 14, color: Colors.grey[300])),
                    const SizedBox(height: 8),
                    Text('Администратор', style: TextStyle(fontSize: 14, color: Colors.grey[300])),
                    const SizedBox(height: 8),
                    Text('История доступа', style: TextStyle(fontSize: 14, color: Colors.grey[300])),
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: Text(
                      'Выйти',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
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