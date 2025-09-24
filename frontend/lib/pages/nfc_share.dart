import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'profile.dart';
import 'bottom_nav.dart';

class NfcSharePage extends StatelessWidget {
  const NfcSharePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060F20),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: SizedBox(
            width: 240,
            height: 240,
            child: SvgPicture.asset(
              'assets/wifi.svg',
              fit: BoxFit.contain,
            ),
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