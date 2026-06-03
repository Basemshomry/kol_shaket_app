import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/realtime_database_service.dart';
import '../widgets/custom_button.dart';
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
        const SnackBar(content: Text('המשתמש נוסף לרשימה המאושרת')),
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

  @override
  void dispose() {
    idController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    classController.dispose();
    super.dispose();
  }

  Widget buildInput({
    required String hintText,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('מערכת ניהול'),
          actions: [
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
              CustomButton(
                text: 'צפייה בכל הפניות',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.counselorReports);
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'כל הצ׳אטים',
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
                    text: count == 0 ? 'התראות' : 'התראות ($count)',
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
              const SizedBox(height: 30),
              const Text(
                'הוספת משתמש מאושר',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: 'סוג משתמש',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'student',
                    child: Text('תלמיד'),
                  ),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('צוות בית הספר'),
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
                hintText: 'תעודת זהות',
                controller: idController,
              ),
              const SizedBox(height: 16),
              buildInput(
                hintText: 'שם פרטי',
                controller: firstNameController,
              ),
              const SizedBox(height: 16),
              buildInput(
                hintText: 'שם משפחה',
                controller: lastNameController,
              ),
              const SizedBox(height: 16),
              if (selectedType == 'admin')
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'תפקיד',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'counselor',
                      child: Text('יועצת'),
                    ),
                    DropdownMenuItem(
                      value: 'manager',
                      child: Text('מנהל'),
                    ),
                    DropdownMenuItem(
                      value: 'teacher',
                      child: Text('מחנך'),
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
                  hintText:
                      selectedType == 'student' ? 'כיתה' : 'כיתה של המחנך',
                  controller: classController,
                ),
              const SizedBox(height: 30),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: 'הוסף לרשימה המאושרת',
                      onPressed: addApprovedUser,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}