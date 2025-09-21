import 'package:flutter/material.dart';
import 'nfc_share.dart';
import 'profile.dart';

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  State<BottomNavPage> createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const NfcSharePage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: theme.colorScheme.background,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
        unselectedLabelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.nfc, color: _selectedIndex == 0 ? theme.colorScheme.primary : null),
            label: 'Раздача',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: _selectedIndex == 1 ? theme.colorScheme.primary : null),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}