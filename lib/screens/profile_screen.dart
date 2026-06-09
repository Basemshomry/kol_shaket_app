import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/app_user.dart';
import '../services/language_service.dart';
import '../services/realtime_database_service.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  String roleText(String role) {
    switch (role) {
      case 'student':
        return AppStrings.student;
      case 'counselor':
        return AppStrings.counselor;
      case 'teacher':
        return AppStrings.teacher;
      case 'manager':
        return AppStrings.manager;
      default:
        return role;
    }
  }

  Widget languageButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: AppColors.primary),
      onSelected: (value) {
        LanguageService.instance.changeLanguage(value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'he', child: Text(AppStrings.hebrew)),
        PopupMenuItem(value: 'en', child: Text(AppStrings.english)),
        PopupMenuItem(value: 'ar', child: Text(AppStrings.arabic)),
      ],
    );
  }

  Widget profileItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return AnimatedBuilder(
      animation: LanguageService.instance,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.profile),
            actions: [languageButton()],
          ),
          body: FutureBuilder<AppUser?>(
            future: currentUser == null
                ? Future.value(null)
                : _databaseService.getUserByUid(currentUser.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final user = snapshot.data;

              if (user == null) {
                return Center(child: Text(AppStrings.noUserData));
              }

              return ListView(
                padding: const EdgeInsets.all(22),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${user.firstName} ${user.lastName}'.trim(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${roleText(user.role)} • ${user.className.isEmpty ? '-' : user.className}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  profileItem(
                    icon: Icons.badge_outlined,
                    title: AppStrings.idNumber,
                    value: user.idNumber,
                  ),
                  profileItem(
                    icon: Icons.school_outlined,
                    title: AppStrings.className,
                    value: user.className,
                  ),
                  profileItem(
                    icon: Icons.work_outline,
                    title: AppStrings.role,
                    value: roleText(user.role),
                  ),
                  profileItem(
                    icon: Icons.verified_user_outlined,
                    title: AppStrings.status,
                    value: user.blocked ? AppStrings.blocked : AppStrings.active,
                  ),
                  profileItem(
                    icon: Icons.language,
                    title: AppStrings.language,
                    value: AppStrings.text(
                      he: 'עברית',
                      en: 'English',
                      ar: 'العربية',
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}