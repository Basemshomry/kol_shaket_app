import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import '../services/realtime_database_service.dart';
import '../utils/app_page_route.dart';
import '../widgets/custom_button.dart';
import 'excel_import_screen.dart';
import 'notifications_screen.dart';
import 'statistics_screen.dart';
import 'user_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AuthService _authService = AuthService();
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  late final Stream<int> unreadNotificationsStream;

  final TextEditingController idController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  String selectedType = 'student';
  String selectedRole = 'counselor';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    unreadNotificationsStream =
        _databaseService.getUnreadNotificationsCount().asBroadcastStream();
  }

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
      if (mounted) setState(() => isLoading = false);
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
      AppPageRoute(page: const ExcelImportScreen()),
    );
  }

  void openStatistics() {
    Navigator.push(
      context,
      AppPageRoute(page: StatisticsScreen()),
    );
  }

  void openUserManagement() {
    Navigator.push(
      context,
      AppPageRoute(page: const UserManagementScreen()),
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
      icon: const Icon(Icons.language, color: Colors.white),
      onSelected: (value) {
        LanguageService.instance.changeLanguage(value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'he', child: Text(AppStrings.hebrew)),
        PopupMenuItem(value: 'en', child: Text(AppStrings.english)),
        PopupMenuItem(value: 'ar', child: Text(AppStrings.arabic)),
      ],
    );
  }

  Widget heroCard() {
    return Container(
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
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.adminSystem,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.text(
                    he: 'ניהול פניות, משתמשים והתראות',
                    en: 'Manage reports, users and notifications',
                    ar: 'إدارة التوجهات والمستخدمين والإشعارات',
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

  Widget actionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Widget? badge,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
            if (badge != null) badge,
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 21,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget buildInput({
    required String hintText,
    required TextEditingController controller,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      textDirection:
          LanguageService.instance.isRtl ? TextDirection.rtl : TextDirection.ltr,
      decoration: InputDecoration(
        prefixIcon:
            icon == null ? null : Icon(icon, color: AppColors.primary),
        hintText: hintText,
      ),
    );
  }

  Widget formCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.addApprovedUserManual,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: selectedType,
            decoration: InputDecoration(
              labelText: AppStrings.userType,
              prefixIcon: const Icon(Icons.group_add_rounded),
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
          const SizedBox(height: 14),
          buildInput(
            hintText: AppStrings.idNumber,
            controller: idController,
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 14),
          buildInput(
            hintText: AppStrings.firstName,
            controller: firstNameController,
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),
          buildInput(
            hintText: AppStrings.lastName,
            controller: lastNameController,
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),
          if (selectedType == 'admin')
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: InputDecoration(
                labelText: AppStrings.role,
                prefixIcon: const Icon(Icons.work_outline_rounded),
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
          if (selectedType == 'admin') const SizedBox(height: 14),
          if (shouldShowClassField)
            buildInput(
              hintText: selectedType == 'student'
                  ? AppStrings.className
                  : AppStrings.teacherClass,
              controller: classController,
              icon: Icons.school_outlined,
            ),
          const SizedBox(height: 22),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomButton(
                  text: AppStrings.addToApprovedList,
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: addApprovedUser,
                ),
        ],
      ),
    );
  }

  Widget notificationsButton() {
    return StreamBuilder<int>(
      stream: unreadNotificationsStream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return actionCard(
          title: AppStrings.notifications,
          icon: Icons.notifications_active_rounded,
          color: AppColors.warning,
          badge: count == 0
              ? null
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
                ),
          onTap: () {
            Navigator.push(
              context,
              AppPageRoute(page: NotificationsScreen()),
            );
          },
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
          backgroundColor: AppColors.background,
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
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              heroCard(),
              const SizedBox(height: 24),
              sectionTitle(
                AppStrings.text(
                  he: 'פעולות מהירות',
                  en: 'Quick Actions',
                  ar: 'إجراءات سريعة',
                ),
              ),
              actionCard(
                title: AppStrings.text(
                  he: 'ניהול משתמשים',
                  en: 'User Management',
                  ar: 'إدارة المستخدمين',
                ),
                icon: Icons.people_alt_rounded,
                color: AppColors.primary,
                onTap: openUserManagement,
              ),
              actionCard(
                title: AppStrings.text(
                  he: 'סטטיסטיקות',
                  en: 'Statistics',
                  ar: 'إحصائيات',
                ),
                icon: Icons.bar_chart_rounded,
                color: AppColors.success,
                onTap: openStatistics,
              ),
              actionCard(
                title: AppStrings.viewAllReports,
                icon: Icons.assignment_rounded,
                color: AppColors.primary,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.counselorReports);
                },
              ),
              actionCard(
                title: AppStrings.allChats,
                icon: Icons.forum_rounded,
                color: AppColors.success,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.chats);
                },
              ),
              notificationsButton(),
              actionCard(
                title: AppStrings.excelImport,
                icon: Icons.table_chart_rounded,
                color: AppColors.secondary,
                onTap: openExcelImport,
              ),
              const SizedBox(height: 24),
              formCard(),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}