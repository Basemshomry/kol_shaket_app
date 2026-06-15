import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/report_model.dart';
import '../services/realtime_database_service.dart';

class StatisticsScreen extends StatelessWidget {
  StatisticsScreen({super.key});

  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  Color severityColor(int severity) {
    if (severity >= 8) return AppColors.error;
    if (severity >= 5) return AppColors.warning;
    return AppColors.success;
  }

  Widget statCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 7),
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
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget heroCard(int total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
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
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.text(
                    he: 'סטטיסטיקות',
                    en: 'Statistics',
                    ar: 'إحصائيات',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.text(
                    he: 'סה״כ $total פניות במערכת',
                    en: '$total total reports in the system',
                    ar: '$total توجهات في النظام',
                  ),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget severityBar({
    required String title,
    required int value,
    required int total,
    required Color color,
  }) {
    final percent = total == 0 ? 0.0 : value / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$value',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.text(
            he: 'סטטיסטיקות',
            en: 'Statistics',
            ar: 'إحصائيات',
          ),
        ),
      ),
      body: StreamBuilder<List<ReportModel>>(
        stream: _databaseService.getAllReports(),
        builder: (context, snapshot) {
          final reports = snapshot.data ?? [];

          final severe = reports.where((r) {
            final severity = r.aiAnalyzed ? r.aiSeverity : r.userSeverity;
            return severity >= 7;
          }).length;

          final low = reports.where((r) {
            final severity = r.aiAnalyzed ? r.aiSeverity : r.userSeverity;
            return severity <= 4;
          }).length;

          final medium = reports.where((r) {
            final severity = r.aiAnalyzed ? r.aiSeverity : r.userSeverity;
            return severity >= 5 && severity <= 7;
          }).length;

          final inProgress =
              reports.where((r) => r.status == 'in_progress').length;

          final resolved =
              reports.where((r) => r.status == 'resolved').length;

          final pending = reports.where((r) => r.status == 'pending').length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              heroCard(reports.length),
              statCard(
                title: AppStrings.totalReports,
                value: reports.length,
                icon: Icons.list_alt_rounded,
                color: AppColors.primary,
              ),
              statCard(
                title: AppStrings.severeReports,
                value: severe,
                icon: Icons.warning_amber_rounded,
                color: AppColors.error,
              ),
              statCard(
                title: AppStrings.inProgress,
                value: inProgress,
                icon: Icons.pending_actions_rounded,
                color: AppColors.warning,
              ),
              statCard(
                title: AppStrings.resolved,
                value: resolved,
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
              ),
              const SizedBox(height: 10),
              severityBar(
                title: AppStrings.pending,
                value: pending,
                total: reports.length,
                color: AppColors.warning,
              ),
              severityBar(
                title: AppStrings.text(
                  he: 'חומרה נמוכה',
                  en: 'Low severity',
                  ar: 'خطورة منخفضة',
                ),
                value: low,
                total: reports.length,
                color: AppColors.success,
              ),
              severityBar(
                title: AppStrings.text(
                  he: 'חומרה בינונית',
                  en: 'Medium severity',
                  ar: 'خطورة متوسطة',
                ),
                value: medium,
                total: reports.length,
                color: AppColors.warning,
              ),
              severityBar(
                title: AppStrings.text(
                  he: 'חומרה גבוהה',
                  en: 'High severity',
                  ar: 'خطورة عالية',
                ),
                value: severe,
                total: reports.length,
                color: AppColors.error,
              ),
            ],
          );
        },
      ),
    );
  }
}