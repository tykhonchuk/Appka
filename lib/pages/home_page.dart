import 'package:appka/pages/family_page.dart';
import 'package:appka/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'home_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.initialIndex});
  final int? initialIndex;

  @override
  State<HomePage> createState() => _HomePageState();

  // Dodaj statyczną metodę do łatwego dostępu przez context
  static _HomePageState? of(BuildContext context) =>
      context.findAncestorStateOfType<_HomePageState>();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomeTab(),
    FamilyPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = (widget.initialIndex ?? 0).clamp(0, _pages.length - 1);
  }

  void setIndex(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setIndex(i),
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
