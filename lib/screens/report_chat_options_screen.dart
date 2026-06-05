import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
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
        return AppStrings.counselor;
      case 'teacher':
        return AppStrings.teacher;
      case 'manager':
        return AppStrings.manager;
      default:
        return AppStrings.schoolStaff;
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

  String statusText(String status) {
    switch (status) {
      case 'pending':
        return AppStrings.pending;
      case 'in_progress':
        return AppStrings.inProgress;
      case 'resolved':
        return AppStrings.resolved;
      default:
        return status;
    }
  }

  List<String> chatTypesForUser() {
    if (user.role == 'student') {
      return ['counselor', 'teacher', 'manager'];
    }

    if (user.role == 'teacher') return ['teacher'];
    if (user.role == 'manager') return ['manager'];

    return ['counselor'];
  }

  void openChat(BuildContext context, String chatType) {
    final studentName =
        '${report.studentFirstName} ${report.studentLastName}'.trim();

    final title = user.role == 'student'
        ? '${AppStrings.openChat} ${roleLabel(chatType)}'
        : studentName.isEmpty
            ? AppStrings.chatWithStudent
            : '${AppStrings.openChat} $studentName';

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

        if (count == 0) return const SizedBox.shrink();

        return CircleAvatar(
          radius: 14,
          backgroundColor: Colors.red,
          child: Text(
            '$count',
            style: const TextStyle(color: Colors.white, fontSize: 12),
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
          '${AppStrings.openChat} ${roleLabel(chatType)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(AppStrings.separateSavedChat),
        trailing: unreadBadge(chatType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatTypes = chatTypesForUser();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.chooseChat),
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
                  report.category.isEmpty
                      ? AppStrings.reportWithoutCategory
                      : report.category,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${AppStrings.status}: ${statusText(report.status)} | ${AppStrings.aiSeverity}: ${report.aiSeverity}',
                ),
              ),
            ),
            Text(
              AppStrings.chooseWhoToChatWith,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...chatTypes.map(
              (chatType) => buildChatOption(context, chatType),
            ),
          ],
        ),
      ),
    );
  }
}