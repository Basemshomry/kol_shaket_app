import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/notification_model.dart';
import '../models/report_model.dart';
import '../services/realtime_database_service.dart';
import 'chat_screen.dart';
import 'report_details_screen.dart';
import '../utils/app_page_route.dart';

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
        return Icons.assignment_rounded;
      case 'new_message':
        return Icons.chat_bubble_rounded;
      case 'high_severity':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color colorForType(String type) {
    switch (type) {
      case 'new_report':
        return AppColors.warning;
      case 'new_message':
        return AppColors.primary;
      case 'high_severity':
        return AppColors.error;
      default:
        return AppColors.grey;
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
        AppPageRoute(
          page: ChatScreen(
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
      AppPageRoute(
        page: ReportDetailsScreen(report: report),
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

  Widget emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppStrings.noNotificationsYet,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.text(
                he: 'עדכונים חשובים יופיעו כאן',
                en: 'Important updates will appear here',
                ar: 'ستظهر التحديثات المهمة هنا',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget headerCard(int unreadCount, int totalCount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_rounded,
            color: Colors.white,
            size: 38,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.notifications,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 23,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  AppStrings.text(
                    he: '$unreadCount לא נקראו מתוך $totalCount',
                    en: '$unreadCount unread of $totalCount',
                    ar: '$unreadCount غير مقروءة من أصل $totalCount',
                  ),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget notificationCard(
    BuildContext context,
    NotificationModel notification,
  ) {
    final color = colorForType(notification.type);
    final unread = !notification.read;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => handleTap(context, notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: unread ? color.withValues(alpha: 0.06) : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: unread ? color.withValues(alpha: 0.30) : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                iconForType(notification.type),
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          titleText(notification),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (unread)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formatDate(notification.createdAt),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15,
                        color: unread ? color : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.notifications),
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: _databaseService.getNotifications(),
        builder: (context, snapshot) {
          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return emptyState();
          }

          final unreadCount =
              notifications.where((notification) => !notification.read).length;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 18),
            itemCount: notifications.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return headerCard(unreadCount, notifications.length);
              }

              final notification = notifications[index - 1];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: notificationCard(context, notification),
              );
            },
          );
        },
      ),
    );
  }
}