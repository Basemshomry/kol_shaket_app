import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/app_user.dart';
import '../models/report_model.dart';
import '../services/realtime_database_service.dart';
import '../utils/app_page_route.dart';
import '../widgets/severity_progress_bar.dart';
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
        return AppStrings.pending;
      case 'in_progress':
        return AppStrings.inProgress;
      case 'resolved':
        return AppStrings.resolved;
      default:
        return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'in_progress':
        return AppColors.primary;
      case 'resolved':
        return AppColors.success;
      default:
        return AppColors.grey;
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
        return AppStrings.counselor;
      case 'teacher':
        return AppStrings.teacher;
      case 'manager':
        return AppStrings.manager;
      default:
        return AppStrings.schoolStaff;
    }
  }

  String chatTypeForUser(AppUser user) {
    if (user.role == 'teacher') return 'teacher';
    if (user.role == 'manager') return 'manager';
    return 'counselor';
  }

  Color severityColor(int severity) {
    if (severity >= 8) return AppColors.error;
    if (severity >= 5) return AppColors.warning;
    return AppColors.success;
  }

  Future<void> updateStatus(BuildContext context, String status) async {
    await _databaseService.updateReportStatus(
      reportId: report.reportId,
      status: status,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.statusUpdated)),
    );
  }

  Widget heroCard() {
    final severity = report.aiAnalyzed ? report.aiSeverity : report.userSeverity;
    final color = severityColor(severity);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.assignment_rounded,
            color: Colors.white,
            size: 42,
          ),
          const SizedBox(height: 18),
          Text(
            report.category.isEmpty
                ? AppStrings.reportWithoutCategory
                : report.category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText(report.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$severity/10',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget aiCard() {
    final color = severityColor(report.aiSeverity);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  AppStrings.aiAnalysis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SeverityProgressBar(
            severity: report.aiSeverity,
            title: AppStrings.aiSeverity,
          ),
          const SizedBox(height: 16),
          detailLine(
            icon: Icons.check_circle_outline_rounded,
            title: AppStrings.analyzed,
            value: report.aiAnalyzed ? AppStrings.yes : AppStrings.no,
          ),
          detailLine(
            icon: Icons.warning_amber_rounded,
            title: AppStrings.aiRiskLevel,
            value: report.aiRiskLevel.isEmpty ? '-' : report.aiRiskLevel,
            valueColor: color,
          ),
          const SizedBox(height: 12),
          textBlock(AppStrings.summary, report.aiSummary),
          const SizedBox(height: 12),
          textBlock(AppStrings.recommendation, report.aiRecommendation),
        ],
      ),
    );
  }

  Widget textBlock(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget detailLine({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget severitySmallCards() {
    return Row(
      children: [
        Expanded(
          child: miniSeverityCard(
            title: AppStrings.studentSeverity,
            severity: report.userSeverity,
            color: severityColor(report.userSeverity),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: miniSeverityCard(
            title: AppStrings.aiSeverity,
            severity: report.aiSeverity,
            color: severityColor(report.aiSeverity),
          ),
        ),
      ],
    );
  }

  Widget miniSeverityCard({
    required String title,
    required int severity,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        children: [
          Text(
            '$severity/10',
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget locationCard() {
    final hasLocation = report.latitude != null && report.longitude != null;

    return infoCard(
      icon: Icons.location_on_outlined,
      title: AppStrings.location,
      value: hasLocation
          ? 'Latitude: ${report.latitude}\nLongitude: ${report.longitude}'
          : AppStrings.noLocationSaved,
    );
  }

  Widget statusTimeline() {
    final currentIndex = report.status == 'resolved'
        ? 2
        : report.status == 'in_progress'
            ? 1
            : 0;

    final items = [
      {
        'title': AppStrings.pending,
        'icon': Icons.hourglass_top_rounded,
      },
      {
        'title': AppStrings.inProgress,
        'icon': Icons.pending_actions_rounded,
      },
      {
        'title': AppStrings.resolved,
        'icon': Icons.check_circle_rounded,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final active = index <= currentIndex;
          final color = active ? AppColors.primary : AppColors.grey;

          return Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: active
                      ? AppColors.primaryLight
                      : AppColors.border,
                  child: Icon(
                    items[index]['icon'] as IconData,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  items[index]['title'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget statusActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => updateStatus(context, 'in_progress'),
            icon: const Icon(Icons.pending_actions_rounded),
            label: Text(AppStrings.markInProgress),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => updateStatus(context, 'resolved'),
            icon: const Icon(Icons.check_circle_rounded),
            label: Text(AppStrings.markResolved),
          ),
        ),
      ],
    );
  }

  Widget chatButton(
    BuildContext context,
    String chatType,
    String studentName,
  ) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.chat_bubble_rounded),
      label: Text('${AppStrings.openChat} ${roleLabel(chatType)}'),
      onPressed: () {
        Navigator.push(
          context,
          AppPageRoute(
            page: ChatScreen(
              report: report,
              chatType: chatType,
              chatTitle: studentName.isEmpty
                  ? AppStrings.chatWithStudent
                  : '${AppStrings.openChat} $studentName',
            ),
          ),
        );
      },
    );
  }

  Widget studentInfo(String studentName) {
    return Column(
      children: [
        infoCard(
          icon: Icons.person_outline,
          title: AppStrings.firstName,
          value: studentName,
        ),
        infoCard(
          icon: Icons.badge_outlined,
          title: AppStrings.idNumber,
          value: report.studentIdNumber,
        ),
        infoCard(
          icon: Icons.school_outlined,
          title: AppStrings.className,
          value: report.studentClassName,
        ),
      ],
    );
  }

  Widget reportInfo() {
    return Column(
      children: [
        infoCard(
          icon: Icons.category_outlined,
          title: AppStrings.category,
          value: report.category,
        ),
        infoCard(
          icon: Icons.calendar_today_outlined,
          title: AppStrings.date,
          value: formatDate(report.createdAt),
        ),
        infoCard(
          icon: Icons.flag_outlined,
          title: AppStrings.status,
          value: statusText(report.status),
        ),
        textBlock(AppStrings.reportDescription, report.description),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final studentName =
        '${report.studentFirstName} ${report.studentLastName}'.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.reportDetails),
      ),
      body: FutureBuilder<AppUser?>(
        future: currentUser == null
            ? Future.value(null)
            : _databaseService.getUserByUid(currentUser.uid),
        builder: (context, snapshot) {
          final appUser = snapshot.data;
          final chatType =
              appUser == null ? 'counselor' : chatTypeForUser(appUser);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              heroCard(),
              const SizedBox(height: 18),
              chatButton(context, chatType, studentName),
              const SizedBox(height: 18),
              sectionTitle(
                AppStrings.text(
                  he: 'מצב טיפול',
                  en: 'Report Progress',
                  ar: 'تقدّم المعالجة',
                ),
                Icons.timeline_rounded,
              ),
              statusTimeline(),
              const SizedBox(height: 18),
              sectionTitle(AppStrings.aiAnalysis, Icons.smart_toy_rounded),
              aiCard(),
              const SizedBox(height: 14),
              severitySmallCards(),
              const SizedBox(height: 18),
              sectionTitle(
                AppStrings.text(
                  he: 'פרטי תלמיד',
                  en: 'Student Information',
                  ar: 'معلومات الطالب',
                ),
                Icons.person_rounded,
              ),
              studentInfo(studentName),
              const SizedBox(height: 8),
              sectionTitle(
                AppStrings.text(
                  he: 'פרטי הפנייה',
                  en: 'Report Information',
                  ar: 'معلومات التوجه',
                ),
                Icons.assignment_rounded,
              ),
              reportInfo(),
              const SizedBox(height: 8),
              sectionTitle(AppStrings.location, Icons.location_on_rounded),
              locationCard(),
              const SizedBox(height: 18),
              sectionTitle(
                AppStrings.text(
                  he: 'עדכון סטטוס',
                  en: 'Update Status',
                  ar: 'تحديث الحالة',
                ),
                Icons.edit_note_rounded,
              ),
              statusActions(context),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}