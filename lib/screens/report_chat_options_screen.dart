import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/app_user.dart';
import '../models/report_model.dart';
import '../services/realtime_database_service.dart';
import 'chat_screen.dart';
import '../utils/app_page_route.dart';

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
        return Icons.support_agent_rounded;
      case 'teacher':
        return Icons.school_rounded;
      case 'manager':
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Color roleColor(String chatType) {
    switch (chatType) {
      case 'counselor':
        return AppColors.primary;
      case 'teacher':
        return AppColors.success;
      case 'manager':
        return AppColors.secondary;
      default:
        return AppColors.grey;
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

  Color severityColor(int severity) {
    if (severity >= 8) return AppColors.error;
    if (severity >= 5) return AppColors.warning;
    return AppColors.success;
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
      AppPageRoute(
        page: ChatScreen(
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

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      },
    );
  }

  Widget summaryCard() {
    final severity = report.aiAnalyzed ? report.aiSeverity : report.userSeverity;
    final color = severityColor(severity);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.assignment_rounded,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.category.isEmpty
                      ? AppStrings.reportWithoutCategory
                      : report.category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${AppStrings.status}: ${statusText(report.status)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$severity/10 • ${AppStrings.aiSeverity}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
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

  Widget buildChatOption(BuildContext context, String chatType) {
    final color = roleColor(chatType);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => openChat(context, chatType),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                roleIcon(chatType),
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppStrings.openChat} ${roleLabel(chatType)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    AppStrings.separateSavedChat,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
            unreadBadge(chatType),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatTypes = chatTypesForUser();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.chooseChat),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          summaryCard(),
          const SizedBox(height: 28),
          Text(
            AppStrings.chooseWhoToChatWith,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...chatTypes.map(
            (chatType) => buildChatOption(context, chatType),
          ),
        ],
      ),
    );
  }
}