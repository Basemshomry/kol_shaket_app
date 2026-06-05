import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/app_user.dart';
import '../models/report_model.dart';
import '../services/realtime_database_service.dart';
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
    if (severity >= 8) return Colors.red;
    if (severity >= 5) return Colors.orange;
    return Colors.green;
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

  Widget infoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget severityCard({
    required String title,
    required int severity,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          '$severity / 10',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: severityColor(severity),
          ),
        ),
      ),
    );
  }

  Widget aiCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: report.aiSeverity >= 8
          ? Colors.red.shade50
          : report.aiSeverity >= 5
              ? Colors.orange.shade50
              : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.aiAnalysis,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('${AppStrings.analyzed}: ${report.aiAnalyzed ? AppStrings.yes : AppStrings.no}'),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.aiSeverity}: ${report.aiSeverity} / 10',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: severityColor(report.aiSeverity),
              ),
            ),
            const SizedBox(height: 8),
            Text('${AppStrings.aiRiskLevel}: ${report.aiRiskLevel.isEmpty ? '-' : report.aiRiskLevel}'),
            const SizedBox(height: 12),
            Text(
              '${AppStrings.summary}:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(report.aiSummary.isEmpty ? '-' : report.aiSummary),
            const SizedBox(height: 12),
            Text(
              '${AppStrings.recommendation}:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(report.aiRecommendation.isEmpty ? '-' : report.aiRecommendation),
          ],
        ),
      ),
    );
  }

  Widget locationCard() {
    final hasLocation = report.latitude != null && report.longitude != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        leading: const Icon(Icons.location_on),
        title: Text(AppStrings.location),
        subtitle: Text(
          hasLocation
              ? 'Latitude: ${report.latitude}\nLongitude: ${report.longitude}'
              : AppStrings.noLocationSaved,
        ),
        isThreeLine: hasLocation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final studentName =
        '${report.studentFirstName} ${report.studentLastName}'.trim();

    return Scaffold(
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.chat),
                  label: Text('${AppStrings.openChat} ${roleLabel(chatType)}'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          report: report,
                          chatType: chatType,
                          chatTitle: studentName.isEmpty
                              ? AppStrings.chatWithStudent
                              : '${AppStrings.openChat} $studentName',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                aiCard(),
                severityCard(
                  title: AppStrings.studentSeverity,
                  severity: report.userSeverity,
                ),
                severityCard(
                  title: AppStrings.aiSeverity,
                  severity: report.aiSeverity,
                ),
                locationCard(),
                infoCard(AppStrings.category, report.category),
                infoCard(AppStrings.firstName, studentName),
                infoCard(AppStrings.idNumber, report.studentIdNumber),
                infoCard(AppStrings.className, report.studentClassName),
                infoCard(AppStrings.date, formatDate(report.createdAt)),
                infoCard(AppStrings.status, statusText(report.status)),
                infoCard(AppStrings.reportDescription, report.description),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => updateStatus(context, 'in_progress'),
                  child: Text(AppStrings.markInProgress),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => updateStatus(context, 'resolved'),
                  child: Text(AppStrings.markResolved),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}