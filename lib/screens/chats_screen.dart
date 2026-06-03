import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/report_model.dart';
import '../services/realtime_database_service.dart';
import 'report_chat_options_screen.dart';

class ChatsScreen extends StatelessWidget {
  ChatsScreen({super.key});

  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  void openChatOptions(
    BuildContext context,
    ReportModel report,
    AppUser user,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportChatOptionsScreen(
          report: report,
          user: user,
        ),
      ),
    );
  }

  String reportTitle(ReportModel report) {
    return report.category.isEmpty ? 'פנייה ללא קטגוריה' : report.category;
  }

  String reportSubtitle(AppUser user, ReportModel report) {
    if (user.role == 'student') {
      return 'סטטוס: ${report.status} | חומרה: ${report.userSeverity}';
    }

    final studentName =
        '${report.studentFirstName} ${report.studentLastName}'.trim();

    return '${studentName.isEmpty ? 'תלמיד לא ידוע' : studentName} | כיתה: ${report.studentClassName}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('צ׳אטים'),
        ),
        body: FutureBuilder<AppUser?>(
          future: currentUser == null
              ? Future.value(null)
              : _databaseService.getUserByUid(currentUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final appUser = userSnapshot.data;

            if (appUser == null) {
              return const Center(child: Text('לא נמצאו פרטי משתמש'));
            }

            return StreamBuilder<List<ReportModel>>(
              stream: _databaseService.getReportsForUser(appUser),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reports = snapshot.data ?? [];

                if (reports.isEmpty) {
                  return const Center(
                    child: Text(
                      'אין צ׳אטים עדיין',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        onTap: () => openChatOptions(
                          context,
                          report,
                          appUser,
                        ),
                        leading: CircleAvatar(
                          child: Text(
                            report.category.isEmpty
                                ? '?'
                                : report.category.characters.first,
                          ),
                        ),
                        title: Text(
                          reportTitle(report),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(reportSubtitle(appUser, report)),
                        trailing: const Icon(Icons.arrow_back_ios),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}