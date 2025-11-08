import 'package:appka/pages/family_page.dart';
import 'package:appka/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'home_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeTab(),
    FamilyPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // ← zmienia ekran w zależności od zakładki
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: "Rodzina"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Użytkownik"),
        ],
      ),
    );
  }
}
