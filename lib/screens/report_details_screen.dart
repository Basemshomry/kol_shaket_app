import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/report_model.dart';
import '../services/realtime_database_service.dart';
import 'chat_screen.dart';

class ReportDetailsScreen extends StatelessWidget {
  ReportDetailsScreen({
    super.key,
    required this.report,
  });

  final ReportModel report;
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  String statusText(String status) {
    switch (status) {
      case 'pending':
        return 'ממתין לבדיקה';
      case 'in_progress':
        return 'בטיפול';
      case 'resolved':
        return 'טופל';
      default:
        return status;
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}  '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String roleLabel(String chatType) {
    switch (chatType) {
      case 'counselor':
        return 'יועצת';
      case 'teacher':
        return 'מחנך';
      case 'manager':
        return 'מנהל';
      default:
        return 'צוות';
    }
  }

  String chatTypeForUser(AppUser user) {
    if (user.role == 'teacher') return 'teacher';
    if (user.role == 'manager') return 'manager';
    return 'counselor';
  }

  Future<void> updateStatus(BuildContext context, String status) async {
    await _databaseService.updateReportStatus(
      reportId: report.reportId,
      status: status,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('סטטוס הפנייה עודכן')),
    );
  }

  Widget infoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value.isEmpty ? '-' : value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final studentName =
        '${report.studentFirstName} ${report.studentLastName}'.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('פרטי פנייה'),
        ),
        body: FutureBuilder<AppUser?>(
          future: currentUser == null
              ? Future.value(null)
              : _databaseService.getUserByUid(currentUser.uid),
          builder: (context, snapshot) {
            final appUser = snapshot.data;
            final chatType = appUser == null ? 'counselor' : chatTypeForUser(appUser);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.chat),
                    label: Text('פתח צ׳אט ${roleLabel(chatType)}'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            report: report,
                            chatType: chatType,
                            chatTitle: studentName.isEmpty
                                ? 'צ׳אט עם תלמיד'
                                : 'צ׳אט עם $studentName',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  infoCard('קטגוריה', report.category),
                  infoCard('שם תלמיד', studentName),
                  infoCard('תעודת זהות', report.studentIdNumber),
                  infoCard('כיתה', report.studentClassName),
                  infoCard('תאריך', formatDate(report.createdAt)),
                  infoCard('סטטוס', statusText(report.status)),
                  infoCard('רמת חומרה', report.userSeverity.toString()),
                  infoCard('תיאור הפנייה', report.description),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => updateStatus(context, 'in_progress'),
                    child: const Text('סמן כבטיפול'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => updateStatus(context, 'resolved'),
                    child: const Text('סמן כטופל'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}