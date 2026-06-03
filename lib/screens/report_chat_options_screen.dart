import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/report_model.dart';
import '../services/realtime_database_service.dart';
import 'chat_screen.dart';

class ReportChatOptionsScreen extends StatelessWidget {
  ReportChatOptionsScreen({
    super.key,
    required this.report,
    required this.user,
  });

  final ReportModel report;
  final AppUser user;
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

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

  IconData roleIcon(String chatType) {
    switch (chatType) {
      case 'counselor':
        return Icons.support_agent;
      case 'teacher':
        return Icons.school;
      case 'manager':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  List<String> chatTypesForUser() {
    if (user.role == 'student') {
      return ['counselor', 'teacher', 'manager'];
    }

    if (user.role == 'teacher') {
      return ['teacher'];
    }

    if (user.role == 'manager') {
      return ['manager'];
    }

    return ['counselor'];
  }

  void openChat(BuildContext context, String chatType) {
    final studentName =
        '${report.studentFirstName} ${report.studentLastName}'.trim();

    final title = user.role == 'student'
        ? 'צ׳אט עם ${roleLabel(chatType)}'
        : 'צ׳אט עם ${studentName.isEmpty ? 'תלמיד' : studentName}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          report: report,
          chatType: chatType,
          chatTitle: title,
        ),
      ),
    );
  }

  Widget unreadBadge(String chatType) {
    return StreamBuilder<int>(
      stream: _databaseService.getUnreadMessagesCount(
        reportId: report.reportId,
        chatType: chatType,
      ),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        if (count == 0) {
          return const SizedBox.shrink();
        }

        return CircleAvatar(
          radius: 14,
          backgroundColor: Colors.red,
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        );
      },
    );
  }

  Widget buildChatOption(BuildContext context, String chatType) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: () => openChat(context, chatType),
        leading: CircleAvatar(
          child: Icon(roleIcon(chatType)),
        ),
        title: Text(
          'צ׳אט עם ${roleLabel(chatType)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text('שיחה נפרדת ושמורה'),
        trailing: unreadBadge(chatType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatTypes = chatTypesForUser();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('בחר צ׳אט'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 20),
                child: ListTile(
                  title: Text(
                    report.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'סטטוס: ${report.status} | חומרה: ${report.userSeverity}',
                  ),
                ),
              ),
              const Text(
                'בחר עם מי לפתוח שיחה:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...chatTypes.map(
                (chatType) => buildChatOption(context, chatType),
              ),
            ],
          ),
        ),
      ),
    );
  }
}