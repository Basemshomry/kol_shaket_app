import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.profile),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.person, size: 90, color: Colors.blue),
                const SizedBox(height: 20),
                languageCard(),
                const SizedBox(height: 20),
                profileItem(AppStrings.firstName, user.firstName),
                profileItem(AppStrings.lastName, user.lastName),
                profileItem(AppStrings.idNumber, user.idNumber),
                profileItem(AppStrings.className, user.className),
                profileItem(AppStrings.role, roleText(user.role)),
                profileItem(
                  AppStrings.status,
                  user.blocked ? AppStrings.blocked : AppStrings.active,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget languageCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedBuilder(
          animation: LanguageService.instance,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.language,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                RadioListTile<String>(
                  value: 'he',
                  groupValue: LanguageService.instance.languageCode,
                  title: Text(AppStrings.hebrew),
                  onChanged: (value) {
                    if (value != null) LanguageService.instance.changeLanguage(value);
                  },
                ),
                RadioListTile<String>(
                  value: 'en',
                  groupValue: LanguageService.instance.languageCode,
                  title: Text(AppStrings.english),
                  onChanged: (value) {
                    if (value != null) LanguageService.instance.changeLanguage(value);
                  },
                ),
                RadioListTile<String>(
                  value: 'ar',
                  groupValue: LanguageService.instance.languageCode,
                  title: Text(AppStrings.arabic),
                  onChanged: (value) {
                    if (value != null) LanguageService.instance.changeLanguage(value);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget profileItem(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}