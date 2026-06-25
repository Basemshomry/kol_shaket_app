import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/app_user.dart';
import '../models/report_model.dart';
import '../services/realtime_database_service.dart';
import '../utils/app_page_route.dart';
import 'report_details_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  Key refreshKey = UniqueKey();

  Future<void> refreshChats() async {
    setState(() {
      refreshKey = UniqueKey();
    });

    await Future.delayed(const Duration(milliseconds: 500));
  }

  void openReportDetails(
    BuildContext context,
    ReportModel report,
  ) {
    Navigator.push(
      context,
      AppPageRoute(
        page: ReportDetailsScreen(
          report: report,
        ),
      ),
    );
  }

  String reportTitle(ReportModel report) {
    return report.category.isEmpty
        ? AppStrings.reportWithoutCategory
        : report.category;
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

  String reportSubtitle(AppUser user, ReportModel report) {
    if (user.role == 'student') {
      return '${AppStrings.status}: ${statusText(report.status)}';
    }

    final studentName =
        '${report.studentFirstName} ${report.studentLastName}'.trim();

    return '${studentName.isEmpty ? AppStrings.unknownStudent : studentName} • ${AppStrings.className}: ${report.studentClassName}';
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
                Icons.chat_bubble_outline_rounded,
                size: 42,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppStrings.noChatsYet,
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
                he: 'צ׳אטים יופיעו כאן אחרי שליחת פנייה',
                en: 'Chats will appear here after sending a report',
                ar: 'ستظهر المحادثات هنا بعد إرسال توجه',
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
            Icons.forum_rounded,
            color: Colors.white,
            size: 38,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.chats,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 23,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  AppStrings.text(
                    he: '$count שיחות פעילות',
                    en: '$count active chats',
                    ar: '$count محادثات فعالة',
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

  Widget unreadBadge(String reportId) {
    return StreamBuilder<int>(
      stream: _databaseService.getUnreadMessagesCount(
        reportId: reportId,
        chatType: 'counselor',
      ),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        if (count == 0) {
          return const SizedBox.shrink();
        }

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

  Widget chatCard(
    BuildContext context,
    ReportModel report,
    AppUser user,
  ) {
    final title = reportTitle(report);
    final severity =
        report.aiAnalyzed ? report.aiSeverity : report.userSeverity;
    final color = severityColor(severity);
    final status = statusColor(report.status);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => openReportDetails(context, report),
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
                categoryIcon(title),
                color: color,
                size: 30,
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
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      unreadBadge(report.reportId),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reportSubtitle(user, report),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: status.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusText(report.status),
                          style: TextStyle(
                            color: status,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$severity/10',
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
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

  Widget chatsList(List<ReportModel> reports, AppUser appUser) {
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
          child: chatCard(context, report, appUser),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.chats),
      ),
      body: RefreshIndicator(
        onRefresh: refreshChats,
        child: FutureBuilder<AppUser?>(
          key: refreshKey,
          future: currentUser == null
              ? Future.value(null)
              : _databaseService.getUserByUid(currentUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 250),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }

            final appUser = userSnapshot.data;

            if (appUser == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.28),
                  Center(child: Text(AppStrings.noUserData)),
                ],
              );
            }

            return StreamBuilder<List<ReportModel>>(
              stream: _databaseService.getReportsForUser(appUser),
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

                return chatsList(reports, appUser);
              },
            );
          },
        ),
      ),
    );
  }
}
