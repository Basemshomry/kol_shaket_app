import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/realtime_database_service.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final RealtimeDatabaseService _databaseService =
      RealtimeDatabaseService();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('הפרופיל שלי'),
        ),
        body: FutureBuilder<AppUser?>(
          future: currentUser == null
              ? Future.value(null)
              : _databaseService.getUserByUid(currentUser.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final user = snapshot.data;

            if (user == null) {
              return const Center(
                child: Text('לא נמצאו פרטי משתמש'),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.person,
                    size: 90,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  profileItem('שם פרטי', user.firstName),
                  profileItem('שם משפחה', user.lastName),
                  profileItem('תעודת זהות', user.idNumber),
                  profileItem('כיתה', user.className),
                  profileItem('תפקיד', user.role),
                  profileItem(
                    'סטטוס',
                    user.blocked ? 'חסום' : 'פעיל',
                  ),
                ],
              ),
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