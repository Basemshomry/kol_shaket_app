import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/report_model.dart';
import '../services/realtime_database_service.dart';
import 'chat_screen.dart';

class ReportsScreen extends StatelessWidget {
  ReportsScreen({super.key});

  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
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

  void openCounselorChat(BuildContext context, ReportModel report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
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
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count ${AppStrings.newMessages}',
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.myReports),
      ),
      body: StreamBuilder<List<ReportModel>>(
        stream: _databaseService.getMyReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data ?? [];

          if (reports.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noReportsYet,
                style: const TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              final severity =
                  report.aiAnalyzed ? report.aiSeverity : report.userSeverity;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => openCounselorChat(context, report),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                report.category.isEmpty
                                    ? AppStrings.reportWithoutCategory
                                    : report.category,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: getStatusColor(report.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                getStatusText(report.status),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        unreadBadge(report.reportId),
                        const SizedBox(height: 12),
                        Text(
                          report.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${AppStrings.aiSeverity}: $severity',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: severity >= 7 ? Colors.red : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.clickToOpenCounselorChat,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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