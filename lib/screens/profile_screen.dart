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

  String selectedLanguageText() {
    switch (LanguageService.instance.languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return 'עברית';
    }
  }

  Widget languageButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: Colors.white),
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

  Widget heroCard(AppUser user) {
    final fullName = '${user.firstName} ${user.lastName}'.trim();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.30),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 54,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            fullName.isEmpty ? '-' : fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${roleText(user.role)} • ${user.className.isEmpty ? '-' : user.className}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget profileItem({
    required IconData icon,
    required String title,
    required String value,
    Color color = AppColors.primary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget languageCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  AppStrings.language,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                selectedLanguageText(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: languageChip('he', AppStrings.hebrew)),
              const SizedBox(width: 8),
              Expanded(child: languageChip('en', 'English')),
              const SizedBox(width: 8),
              Expanded(child: languageChip('ar', 'العربية')),
            ],
          ),
        ],
      ),
    );
  }

  Widget languageChip(String code, String title) {
    final selected = LanguageService.instance.languageCode == code;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        LanguageService.instance.changeLanguage(code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w900,
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
          backgroundColor: AppColors.background,
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
                  heroCard(user),
                  const SizedBox(height: 22),
                  sectionTitle(AppStrings.profile),
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
                    icon: Icons.work_outline_rounded,
                    title: AppStrings.role,
                    value: roleText(user.role),
                  ),
                  profileItem(
                    icon: Icons.verified_user_outlined,
                    title: AppStrings.status,
                    value: user.blocked ? AppStrings.blocked : AppStrings.active,
                    color: user.blocked ? AppColors.error : AppColors.success,
                  ),
                  const SizedBox(height: 10),
                  sectionTitle(AppStrings.language),
                  languageCard(),
                ],
              );
            },
          ),
        );
      },
    );
  }
}