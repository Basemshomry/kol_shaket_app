import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/report_model.dart';
import '../services/realtime_database_service.dart';
import '../utils/app_page_route.dart';
import 'chat_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  Key refreshKey = UniqueKey();

  Future<void> refreshReports() async {
    setState(() {
      refreshKey = UniqueKey();
    });

    await Future.delayed(const Duration(milliseconds: 500));
  }

  Color getStatusColor(String status) {
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

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'in_progress':
        return Icons.pending_actions_rounded;
      case 'resolved':
        return Icons.check_circle_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String getStatusText(String status) {
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

  IconData categoryIcon(String category) {
    if (category == AppStrings.bullying) {
      return Icons.warning_amber_rounded;
    }
    if (category == AppStrings.mentalPressure) {
      return Icons.psychology_rounded;
    }
    if (category == AppStrings.socialDifficulties) {
      return Icons.groups_rounded;
    }
    if (category == AppStrings.distress) {
      return Icons.sos_rounded;
    }
    return Icons.more_horiz_rounded;
  }

  void openCounselorChat(BuildContext context, ReportModel report) {
    Navigator.push(
      context,
      AppPageRoute(
        page: ChatScreen(
          report: report,
          chatType: 'counselor',
          chatTitle: '${AppStrings.openChat} ${AppStrings.counselor}',
        ),
      ),
    );
  }

  Widget unreadBadge(String reportId) {
    return StreamBuilder<int>(
      stream: _databaseService.getUnreadMessagesCount(
        reportId: reportId,
        chatType: 'counselor',
      ),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        if (count == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count ${AppStrings.newMessages}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      },
    );
  }

  Widget emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(30),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        Column(
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
                Icons.assignment_outlined,
                size: 42,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppStrings.noReportsYet,
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
                he: 'פניות שתשלח יופיעו כאן',
                en: 'Reports you send will appear here',
                ar: 'التوجهات التي ترسلها ستظهر هنا',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget statusBadge(ReportModel report) {
    final color = getStatusColor(report.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(getStatusIcon(report.status), color: color, size: 16),
          const SizedBox(width: 5),
          Text(
            getStatusText(report.status),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget reportCard(BuildContext context, ReportModel report) {
    final severity =
        report.aiAnalyzed ? report.aiSeverity : report.userSeverity;
    final categoryTitle = report.category.isEmpty
        ? AppStrings.reportWithoutCategory
        : report.category;
    final color = severityColor(severity);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => openCounselorChat(context, report),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
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
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    categoryIcon(categoryTitle),
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryTitle,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        report.description.isEmpty ? '-' : report.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                statusBadge(report),
                const SizedBox(width: 8),
                unreadBadge(report.reportId),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(Icons.monitor_heart_outlined, color: color, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${AppStrings.aiSeverity}: $severity / 10',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.clickToOpenCounselorChat,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget headerCard(int count) {
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
            Icons.assignment_rounded,
            color: Colors.white,
            size: 38,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.myReports,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 23,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  AppStrings.text(
                    he: '$count פניות שנשלחו',
                    en: '$count sent reports',
                    ar: '$count توجهات مرسلة',
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

  Widget reportsList(List<ReportModel> reports) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 18),
      itemCount: reports.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return headerCard(reports.length);
        }

        final report = reports[index - 1];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: reportCard(context, report),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.myReports),
      ),
      body: RefreshIndicator(
        onRefresh: refreshReports,
        child: StreamBuilder<List<ReportModel>>(
          key: refreshKey,
          stream: _databaseService.getMyReports(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 250),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }

            final reports = snapshot.data ?? [];

            if (reports.isEmpty) {
              return emptyState();
            }

            return reportsList(reports);
          },
        ),
      ),
    );
  }
}
