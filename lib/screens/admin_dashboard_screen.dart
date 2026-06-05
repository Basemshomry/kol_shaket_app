import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/report_model.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import '../services/realtime_database_service.dart';
import '../widgets/custom_button.dart';
import 'excel_import_screen.dart';
import 'notifications_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AuthService _authService = AuthService();
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  final TextEditingController idController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  String selectedType = 'student';
  String selectedRole = 'counselor';
  bool isLoading = false;

  bool get shouldShowClassField {
    return selectedType == 'student' || selectedRole == 'teacher';
  }

  Future<void> addApprovedUser() async {
    try {
      setState(() => isLoading = true);

      if (selectedType == 'student') {
        await _databaseService.addApprovedStudent(
          idNumber: idController.text.trim(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          className: classController.text.trim(),
        );
      } else {
        await _databaseService.addApprovedAdmin(
          idNumber: idController.text.trim(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          role: selectedRole,
          className:
              selectedRole == 'teacher' ? classController.text.trim() : '',
        );
      }

      idController.clear();
      firstNameController.clear();
      lastNameController.clear();
      classController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.approvedUserAdded)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  void openExcelImport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ExcelImportScreen(),
      ),
    );
  }

  @override
  void dispose() {
    idController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    classController.dispose();
    super.dispose();
  }

  Widget languageButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (value) {
        LanguageService.instance.changeLanguage(value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'he',
          child: Text(AppStrings.hebrew),
        ),
        PopupMenuItem(
          value: 'en',
          child: Text(AppStrings.english),
        ),
        PopupMenuItem(
          value: 'ar',
          child: Text(AppStrings.arabic),
        ),
      ],
    );
  }

  Widget buildInput({
    required String hintText,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      textDirection:
          LanguageService.instance.isRtl ? TextDirection.rtl : TextDirection.ltr,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget statCard(String title, int value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(
          '$value',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget statsSection() {
    return StreamBuilder<List<ReportModel>>(
      stream: _databaseService.getAllReports(),
      builder: (context, snapshot) {
        final reports = snapshot.data ?? [];
        final severe = reports.where((r) {
          final severity = r.aiAnalyzed ? r.aiSeverity : r.userSeverity;
          return severity >= 7;
        }).length;
        final inProgress =
            reports.where((r) => r.status == 'in_progress').length;
        final resolved = reports.where((r) => r.status == 'resolved').length;

        return Column(
          children: [
            statCard(AppStrings.totalReports, reports.length, Icons.list_alt),
            statCard(AppStrings.severeReports, severe, Icons.warning),
            statCard(AppStrings.inProgress, inProgress, Icons.pending_actions),
            statCard(AppStrings.resolved, resolved, Icons.check_circle),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LanguageService.instance,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.adminSystem),
            actions: [
              languageButton(),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: logout,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                statsSection(),
                const SizedBox(height: 20),
                CustomButton(
                  text: AppStrings.viewAllReports,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.counselorReports);
                  },
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: AppStrings.allChats,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.chats);
                  },
                ),
                const SizedBox(height: 12),
                StreamBuilder<int>(
                  stream: _databaseService.getUnreadNotificationsCount(),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;

                    return CustomButton(
                      text: count == 0
                          ? AppStrings.notifications
                          : '${AppStrings.notifications} ($count)',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotificationsScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: AppStrings.excelImport,
                  onPressed: openExcelImport,
                ),
                const SizedBox(height: 30),
                Text(
                  AppStrings.addApprovedUserManual,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: AppStrings.userType,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'student',
                      child: Text(AppStrings.student),
                    ),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text(AppStrings.adminStaff),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                      if (selectedType == 'student') {
                        selectedRole = 'counselor';
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                buildInput(
                  hintText: AppStrings.idNumber,
                  controller: idController,
                ),
                const SizedBox(height: 16),
                buildInput(
                  hintText: AppStrings.firstName,
                  controller: firstNameController,
                ),
                const SizedBox(height: 16),
                buildInput(
                  hintText: AppStrings.lastName,
                  controller: lastNameController,
                ),
                const SizedBox(height: 16),
                if (selectedType == 'admin')
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: AppStrings.role,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'counselor',
                        child: Text(AppStrings.counselor),
                      ),
                      DropdownMenuItem(
                        value: 'manager',
                        child: Text(AppStrings.manager),
                      ),
                      DropdownMenuItem(
                        value: 'teacher',
                        child: Text(AppStrings.teacher),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                if (selectedType == 'admin') const SizedBox(height: 16),
                if (shouldShowClassField)
                  buildInput(
                    hintText: selectedType == 'student'
                        ? AppStrings.className
                        : AppStrings.teacherClass,
                    controller: classController,
                  ),
                const SizedBox(height: 30),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        text: AppStrings.addToApprovedList,
                        onPressed: addApprovedUser,
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}