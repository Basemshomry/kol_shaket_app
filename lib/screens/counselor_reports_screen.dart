import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/app_user.dart';
import '../models/report_model.dart';
import '../services/realtime_database_service.dart';
import 'report_details_screen.dart';
import '../utils/app_page_route.dart';

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
    return fullName.isEmpty ? AppStrings.unknownStudent : fullName;
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}  '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  List<ReportModel> applyFilters(List<ReportModel> reports) {
    var filtered = reports;

    if (selectedStatus != 'all') {
      filtered =
          filtered.where((report) => report.status == selectedStatus).toList();
    }

    if (highSeverityOnly) {
      filtered = filtered.where((report) {
        final severity = report.aiAnalyzed ? report.aiSeverity : report.userSeverity;
        return severity >= 7;
      }).toList();
    }

    return filtered;
  }

  void openDetails(ReportModel report) {
    Navigator.push(
      context,
      AppPageRoute(
        page: ReportDetailsScreen(report: report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.allReports),
      ),
      body: FutureBuilder<AppUser?>(
        future: currentUser == null
            ? Future.value(null)
            : _databaseService.getUserByUid(currentUser.uid),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final appUser = userSnapshot.data;

          if (appUser == null) {
            return Center(child: Text(AppStrings.noUserData));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (appUser.role == 'teacher')
                      Text(
                        '${AppStrings.className}: ${appUser.className}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        labelText: AppStrings.filterByStatus,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text(AppStrings.allStatuses),
                        ),
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text(AppStrings.pending),
                        ),
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text(AppStrings.inProgress),
                        ),
                        DropdownMenuItem(
                          value: 'resolved',
                          child: Text(AppStrings.resolved),
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
                      title: Text(AppStrings.highSeverityOnly),
                      subtitle: Text(AppStrings.severitySevenAndUp),
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
                  stream: _databaseService.getReportsForUser(appUser),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final reports = applyFilters(snapshot.data ?? []);

                    if (reports.isEmpty) {
                      return Center(
                        child: Text(
                          AppStrings.noReportsToShow,
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
                                          color: statusColor(report.status),
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                  Text('${AppStrings.firstName}: ${studentName(report)}'),
                                  Text('${AppStrings.idNumber}: ${report.studentIdNumber}'),
                                  Text('${AppStrings.className}: ${report.studentClassName}'),
                                  Text('${AppStrings.date}: ${formatDate(report.createdAt)}'),
                                  const SizedBox(height: 12),
                                  Text('${AppStrings.reportDescription}: ${report.description}'),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${AppStrings.aiSeverity}: $severity',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: severity >= 7
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    AppStrings.tapToOpenDetails,
                                    style: const TextStyle(color: Colors.grey),
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
          );
        },
      ),
    );
  }
}