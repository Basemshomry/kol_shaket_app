import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    HomeScreen(),
    const Center(
      child: Text(
        'AI Chat',
        style: TextStyle(fontSize: 22),
      ),
    ),
    ReportsScreen(),
    const Center(
      child: Text(
        'Counselor Chat',
        style: TextStyle(fontSize: 22),
      ),
    ),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'בית',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'פניות',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'יועצת',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'פרופיל',
          ),
        ],
      ),
    );
  }
}