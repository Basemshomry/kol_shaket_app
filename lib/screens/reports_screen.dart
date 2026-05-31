import 'package:flutter/material.dart';

import '../models/report_model.dart';
import '../services/realtime_database_service.dart';

class ReportsScreen extends StatelessWidget {
  ReportsScreen({super.key});

  final RealtimeDatabaseService _databaseService =
      RealtimeDatabaseService();

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;

      case 'reviewed':
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
        return 'ממתין לבדיקה';

      case 'reviewed':
        return 'נבדק';

      case 'resolved':
        return 'טופל';

      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('הפניות שלי'),
        ),
        body: StreamBuilder<List<ReportModel>>(
          stream: _databaseService.getMyReports(),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final reports = snapshot.data ?? [];

            if (reports.isEmpty) {
              return const Center(
                child: Text(
                  'עדיין לא שלחת פניות',
                  style: TextStyle(
                    fontSize: 18,
                  ),
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
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                report.category,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: getStatusColor(
                                  report.status,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),
                              ),
                              child: Text(
                                getStatusText(
                                  report.status,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          report.description,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'רמת חומרה: ${report.userSeverity}',
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