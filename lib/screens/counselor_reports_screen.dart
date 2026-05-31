import 'package:flutter/material.dart';

import '../models/report_model.dart';
import '../services/realtime_database_service.dart';

class CounselorReportsScreen extends StatelessWidget {
  CounselorReportsScreen({super.key});

  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  Future<void> updateStatus(String reportId, String status) async {
    await _databaseService.updateReportStatus(
      reportId: reportId,
      status: status,
    );
  }

  String statusText(String status) {
    switch (status) {
      case 'pending':
        return 'ממתין לבדיקה';
      case 'in_progress':
        return 'בטיפול';
      case 'resolved':
        return 'טופל';
      default:
        return status;
    }
  }

  Color statusColor(String status) {
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

  String studentName(ReportModel report) {
    final fullName =
        '${report.studentFirstName} ${report.studentLastName}'.trim();

    return fullName.isEmpty ? 'תלמיד לא ידוע' : fullName;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('כל הפניות'),
        ),
        body: StreamBuilder<List<ReportModel>>(
          stream: _databaseService.getAllReports(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final reports = snapshot.data ?? [];

            if (reports.isEmpty) {
              return const Center(
                child: Text(
                  'אין פניות עדיין',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                report.category,
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
                                color: statusColor(report.status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                statusText(report.status),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('שם תלמיד: ${studentName(report)}'),
                        Text('תעודת זהות: ${report.studentIdNumber.isEmpty ? '-' : report.studentIdNumber}'),
                        Text('כיתה: ${report.studentClassName.isEmpty ? '-' : report.studentClassName}'),
                        const SizedBox(height: 12),
                        Text('תיאור: ${report.description}'),
                        const SizedBox(height: 12),
                        Text('רמת חומרה: ${report.userSeverity}'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => updateStatus(
                                  report.reportId,
                                  'in_progress',
                                ),
                                child: const Text('בטיפול'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => updateStatus(
                                  report.reportId,
                                  'resolved',
                                ),
                                child: const Text('טופל'),
                              ),
                            ),
                          ],
                        ),
                      ],
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