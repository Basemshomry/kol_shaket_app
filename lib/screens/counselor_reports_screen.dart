import 'package:flutter/material.dart';

import '../models/report_model.dart';
import '../services/realtime_database_service.dart';
import 'report_details_screen.dart';

class CounselorReportsScreen extends StatefulWidget {
  const CounselorReportsScreen({super.key});

  @override
  State<CounselorReportsScreen> createState() =>
      _CounselorReportsScreenState();
}

class _CounselorReportsScreenState extends State<CounselorReportsScreen> {
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  String selectedStatus = 'all';
  bool highSeverityOnly = false;

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

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year  $hour:$minute';
  }

  List<ReportModel> applyFilters(List<ReportModel> reports) {
    var filtered = reports;

    if (selectedStatus != 'all') {
      filtered = filtered
          .where((report) => report.status == selectedStatus)
          .toList();
    }

    if (highSeverityOnly) {
      filtered = filtered
          .where((report) => report.userSeverity >= 7)
          .toList();
    }

    return filtered;
  }

  void openDetails(ReportModel report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportDetailsScreen(report: report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('כל הפניות'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'סינון לפי סטטוס',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('כל הפניות'),
                      ),
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('ממתין לבדיקה'),
                      ),
                      DropdownMenuItem(
                        value: 'in_progress',
                        child: Text('בטיפול'),
                      ),
                      DropdownMenuItem(
                        value: 'resolved',
                        child: Text('טופל'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: highSeverityOnly,
                    title: const Text('הצג רק פניות חמורות'),
                    subtitle: const Text('רמת חומרה 7 ומעלה'),
                    onChanged: (value) {
                      setState(() {
                        highSeverityOnly = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ReportModel>>(
                stream: _databaseService.getAllReports(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final reports = applyFilters(snapshot.data ?? []);

                  if (reports.isEmpty) {
                    return const Center(
                      child: Text(
                        'אין פניות להצגה',
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
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => openDetails(report),
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
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text('שם תלמיד: ${studentName(report)}'),
                                Text('תעודת זהות: ${report.studentIdNumber}'),
                                Text('כיתה: ${report.studentClassName}'),
                                Text('תאריך: ${formatDate(report.createdAt)}'),
                                const SizedBox(height: 12),
                                Text('תיאור: ${report.description}'),
                                const SizedBox(height: 12),
                                Text(
                                  'רמת חומרה: ${report.userSeverity}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: report.userSeverity >= 7
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'לחץ לפתיחת פרטי הפנייה',
                                  style: TextStyle(
                                    color: Colors.grey,
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
            ),
          ],
        ),
      ),
    );
  }
}