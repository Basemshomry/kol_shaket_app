import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        elevation: 8,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home, color: AppColors.primary),
            label: AppStrings.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.smart_toy_outlined),
            selectedIcon: const Icon(Icons.smart_toy, color: AppColors.primary),
            label: AppStrings.ai,
          ),
          NavigationDestination(
            icon: const Icon(Icons.report_outlined),
            selectedIcon: const Icon(Icons.report, color: AppColors.primary),
            label: AppStrings.reports,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon:
                const Icon(Icons.chat_bubble, color: AppColors.primary),
            label: AppStrings.chats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person, color: AppColors.primary),
            label: AppStrings.profile,
          ),
        ],
      ),
    );
  }
}