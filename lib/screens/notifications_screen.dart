import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/notification_model.dart';
import '../models/report_model.dart';
import '../services/realtime_database_service.dart';
import 'chat_screen.dart';
import 'report_details_screen.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}  '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  IconData iconForType(String type) {
    switch (type) {
      case 'new_report':
        return Icons.report;
      case 'new_message':
        return Icons.chat;
      case 'high_severity':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  Color colorForType(String type) {
    switch (type) {
      case 'new_report':
        return Colors.orange;
      case 'new_message':
        return Colors.blue;
      case 'high_severity':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<ReportModel?> findReport(String reportId) async {
    final reports = await _databaseService.getAllReports().first;
    for (final report in reports) {
      if (report.reportId == reportId) return report;
    }
    return null;
  }

  Future<void> handleTap(
    BuildContext context,
    NotificationModel notification,
  ) async {
    await _databaseService.markNotificationAsRead(
      notification.notificationId,
    );

    final report = await findReport(notification.reportId);

    if (report == null || !context.mounted) return;

    if (notification.type == 'new_message') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            report: report,
            chatType: 'counselor',
            chatTitle: AppStrings.chats,
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportDetailsScreen(report: report),
      ),
    );
  }

  String titleText(NotificationModel notification) {
    switch (notification.type) {
      case 'new_report':
        return AppStrings.newReport;
      case 'new_message':
        return AppStrings.newMessage;
      case 'high_severity':
        return AppStrings.severeReportNew;
      default:
        return notification.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.notifications),
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _databaseService.getNotifications(),
        builder: (context, snapshot) {
          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noNotificationsYet,
                style: const TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: notification.read ? Colors.white : Colors.blue.shade50,
                child: ListTile(
                  onTap: () => handleTap(context, notification),
                  leading: CircleAvatar(
                    backgroundColor: colorForType(notification.type),
                    child: Icon(
                      iconForType(notification.type),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    titleText(notification),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${notification.body}\n${formatDate(notification.createdAt)}',
                  ),
                  isThreeLine: true,
                  trailing: notification.read
                      ? const Icon(Icons.done)
                      : const Icon(
                          Icons.circle,
                          color: Colors.red,
                          size: 12,
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}