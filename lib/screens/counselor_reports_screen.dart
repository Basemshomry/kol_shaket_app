import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/app_user.dart';
import '../models/report_model.dart';
import '../services/realtime_database_service.dart';
import '../utils/app_page_route.dart';
import 'report_details_screen.dart';

class CounselorReportsScreen extends StatefulWidget {
  const CounselorReportsScreen({super.key});

  @override
  State<CounselorReportsScreen> createState() =>
      _CounselorReportsScreenState();
}

class _CounselorReportsScreenState extends State<CounselorReportsScreen> {
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();
  final TextEditingController searchController = TextEditingController();

  String selectedStatus = 'all';
  bool highSeverityOnly = false;
  String searchQuery = '';
  String tempSearchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
        final severity =
            report.aiAnalyzed ? report.aiSeverity : report.userSeverity;
        return severity >= 7;
      }).toList();
    }

    final query = searchQuery.trim().toLowerCase();

    if (query.isNotEmpty) {
      filtered = filtered.where((report) {
        final name = studentName(report).toLowerCase();
        final id = report.studentIdNumber.toLowerCase();
        final className = report.studentClassName.toLowerCase();
        final category = report.category.toLowerCase();
        final description = report.description.toLowerCase();

        return name.contains(query) ||
            id.contains(query) ||
            className.contains(query) ||
            category.contains(query) ||
            description.contains(query);
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

    Widget searchBox() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: AppStrings.text(
          he: 'חיפוש לפי שם, תעודת זהות, כיתה או נושא',
          en: 'Search by name, ID, class or category',
          ar: 'ابحث حسب الاسم، الهوية، الصف أو الموضوع',
        ),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              searchQuery = searchController.text.trim();
            });
          },
        ),
      ),
      onSubmitted: (value) {
        setState(() {
          searchQuery = value.trim();
        });
      },
    );
  }

  Widget statusFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          filterChip(AppStrings.allStatuses, 'all'),
          filterChip(AppStrings.pending, 'pending'),
          filterChip(AppStrings.inProgress, 'in_progress'),
          filterChip(AppStrings.resolved, 'resolved'),
        ],
      ),
    );
  }

  Widget filterChip(String label, String value) {
    final selected = selectedStatus == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => selectedStatus = value);
        },
        selectedColor: AppColors.primaryLight,
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget highSeveritySwitch() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        value: highSeverityOnly,
        activeColor: AppColors.error,
        title: Text(
          AppStrings.highSeverityOnly,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(AppStrings.severitySevenAndUp),
        onChanged: (value) {
          setState(() => highSeverityOnly = value);
        },
      ),
    );
  }

  Widget filtersPanel(AppUser appUser) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (appUser.role == 'teacher') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${AppStrings.className}: ${appUser.className}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          searchBox(),
          const SizedBox(height: 12),
          statusFilters(),
          highSeveritySwitch(),
        ],
      ),
    );
  }

  Widget emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
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
                color: AppColors.primary,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppStrings.noReportsToShow,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget reportCard(ReportModel report) {
    final severity = report.aiAnalyzed ? report.aiSeverity : report.userSeverity;
    final color = severityColor(severity);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => openDetails(report),
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
                    Icons.assignment_rounded,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    report.category.isEmpty
                        ? AppStrings.reportWithoutCategory
                        : report.category,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor(report.status).withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusText(report.status),
                    style: TextStyle(
                      color: statusColor(report.status),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
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
            Text(
              report.description.isEmpty
                  ? '-'
                  : report.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${AppStrings.aiSeverity}: $severity / 10',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.tapToOpenDetails,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 450));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
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
              filtersPanel(appUser),
              Expanded(
                child: StreamBuilder<List<ReportModel>>(
                  stream: _databaseService.getReportsForUser(appUser),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final reports = applyFilters(snapshot.data ?? []);

                    if (reports.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: refresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.45,
                              child: emptyState(),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: refresh,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          return reportCard(reports[index]);
                        },
                      ),
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