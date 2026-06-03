import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../services/realtime_database_service.dart';

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

  Future<void> markAsRead(NotificationModel notification) async {
    await _databaseService.markNotificationAsRead(
      notification.notificationId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('התראות'),
        ),
        body: StreamBuilder<List<NotificationModel>>(
          stream: _databaseService.getNotifications(),
          builder: (context, snapshot) {
            final notifications = snapshot.data ?? [];

            if (notifications.isEmpty) {
              return const Center(
                child: Text(
                  'אין התראות עדיין',
                  style: TextStyle(fontSize: 18),
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
                    onTap: () => markAsRead(notification),
                    leading: CircleAvatar(
                      backgroundColor: colorForType(notification.type),
                      child: Icon(
                        iconForType(notification.type),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      notification.title,
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
      ),
    );
  }
}