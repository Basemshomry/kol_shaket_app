import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../services/realtime_database_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();
  final TextEditingController searchController = TextEditingController();

  String searchQuery = '';
  bool isLoading = true;

  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> admins = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadUsers() async {
    setState(() => isLoading = true);

    final loadedStudents = await _databaseService.getApprovedStudents();
    final loadedAdmins = await _databaseService.getApprovedAdmins();

    if (!mounted) return;

    setState(() {
      students = loadedStudents;
      admins = loadedAdmins;
      isLoading = false;
    });
  }

  String valueOf(Map<String, dynamic> user, String key) {
    return (user[key] ?? '').toString();
  }

  List<Map<String, dynamic>> filteredStudents() {
    final query = searchQuery.trim().toLowerCase();

    return students.where((user) {
      final text =
          '${valueOf(user, 'firstName')} ${valueOf(user, 'lastName')} ${valueOf(user, 'idNumber')} ${valueOf(user, 'className')}'
              .toLowerCase();

      return text.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> filteredAdmins(String role) {
    final query = searchQuery.trim().toLowerCase();

    return admins.where((user) {
      final text =
          '${valueOf(user, 'firstName')} ${valueOf(user, 'lastName')} ${valueOf(user, 'idNumber')} ${valueOf(user, 'className')} ${valueOf(user, 'role')}'
              .toLowerCase();

      return valueOf(user, 'role') == role && text.contains(query);
    }).toList();
  }

  Future<void> confirmDelete({
    required String idNumber,
    required bool isStudent,
  }) async {
    if (idNumber.isEmpty) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppStrings.delete),
          content: Text(
            AppStrings.text(
              he: 'האם אתה בטוח שברצונך למחוק משתמש זה?',
              en: 'Are you sure you want to delete this user?',
              ar: 'هل أنت متأكد أنك تريد حذف هذا المستخدم؟',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppStrings.delete),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    if (isStudent) {
      await _databaseService.deleteApprovedStudent(idNumber);
    } else {
      await _databaseService.deleteApprovedAdmin(idNumber);
    }

    await loadUsers();
  }

  Widget searchBox() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: AppStrings.text(
          he: 'חיפוש לפי שם, תעודת זהות או כיתה',
          en: 'Search by name, ID or class',
          ar: 'ابحث حسب الاسم، الهوية أو الصف',
        ),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: searchQuery.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  searchController.clear();
                  setState(() => searchQuery = '');
                },
              ),
      ),
      onChanged: (value) {
        setState(() => searchQuery = value);
      },
    );
  }

  Widget sectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        '$title ($count)',
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget userCard({
    required Map<String, dynamic> user,
    required bool isStudent,
  }) {
    final firstName = valueOf(user, 'firstName');
    final lastName = valueOf(user, 'lastName');
    final idNumber = valueOf(user, 'idNumber');
    final className = valueOf(user, 'className');
    final role = valueOf(user, 'role');
    final name = '$firstName $lastName'.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            child: Icon(
              isStudent ? Icons.school_rounded : Icons.work_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? '-' : name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${AppStrings.idNumber}: ${idNumber.isEmpty ? '-' : idNumber}'),
                if (className.isNotEmpty)
                  Text('${AppStrings.className}: $className'),
                if (!isStudent)
                  Text('${AppStrings.role}: ${role.isEmpty ? '-' : role}'),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () {
              confirmDelete(
                idNumber: idNumber,
                isStudent: isStudent,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget usersSection({
    required String title,
    required List<Map<String, dynamic>> users,
    required bool isStudent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        sectionTitle(title, users.length),
        if (users.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              AppStrings.text(
                he: 'אין משתמשים להצגה',
                en: 'No users to show',
                ar: 'لا يوجد مستخدمون للعرض',
              ),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ...users.map(
          (user) => userCard(
            user: user,
            isStudent: isStudent,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudentList = filteredStudents();
    final teachers = filteredAdmins('teacher');
    final counselors = filteredAdmins('counselor');
    final managers = filteredAdmins('manager');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.text(
            he: 'ניהול משתמשים',
            en: 'User Management',
            ar: 'إدارة المستخدمين',
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadUsers,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  searchBox(),
                  usersSection(
                    title: AppStrings.student,
                    users: filteredStudentList,
                    isStudent: true,
                  ),
                  usersSection(
                    title: AppStrings.teacher,
                    users: teachers,
                    isStudent: false,
                  ),
                  usersSection(
                    title: AppStrings.counselor,
                    users: counselors,
                    isStudent: false,
                  ),
                  usersSection(
                    title: AppStrings.manager,
                    users: managers,
                    isStudent: false,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
