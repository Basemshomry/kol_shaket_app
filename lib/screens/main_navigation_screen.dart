import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import 'chats_screen.dart';
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

  late final List<Widget> screens = [
    HomeScreen(),
    Center(
      child: Text(
        AppStrings.ai,
        style: const TextStyle(fontSize: 22),
      ),
    ),
    ReportsScreen(),
    ChatsScreen(),
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.smart_toy),
            label: AppStrings.ai,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.report),
            label: AppStrings.reports,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat),
            label: AppStrings.chats,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppStrings.profile,
          ),
        ],
      ),
    );
  }
}