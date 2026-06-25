import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../models/app_user.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import '../services/notification_service.dart';
import '../services/realtime_database_service.dart';
import '../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> register() async {
    try {
      setState(() {
        isLoading = true;
      });

      final idNumber = idNumberController.text.trim();
      final password = passwordController.text.trim();

      if (idNumber.isEmpty || password.isEmpty) {
        throw Exception(AppStrings.registerError);
      }

      final approvedStudent =
          await _databaseService.getApprovedStudent(idNumber);

      final approvedAdmin = await _databaseService.getApprovedAdmin(idNumber);

      if (approvedStudent == null && approvedAdmin == null) {
        throw Exception(AppStrings.idNotApproved);
      }

      final bool isStudent = approvedStudent != null;
      final approvedData = isStudent ? approvedStudent : approvedAdmin!;

      final String role =
          isStudent ? 'student' : (approvedData['role'] ?? 'counselor');

      final generatedEmail = '$idNumber@kolshaket.com';

      final credential = await _authService.register(
        email: generatedEmail,
        password: password,
      );

      final user = AppUser(
        uid: credential.user!.uid,
        firstName: approvedData['firstName'] ?? '',
        lastName: approvedData['lastName'] ?? '',
        idNumber: idNumber,
        className: approvedData['className'] ?? '',
        role: role,
        blocked: false,
      );

      await _databaseService.createUser(user);

      NotificationService.instance.saveCurrentUserToken();

      if (!mounted) return;

      if (role == 'student') {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = AppStrings.registerError;

      if (e.code == 'email-already-in-use') {
        message = AppStrings.alreadyRegistered;
      } else if (e.code == 'weak-password') {
        message = AppStrings.weakPassword;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    idNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget buildInput({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.register),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            buildInput(
              hintText: AppStrings.idNumber,
              controller: idNumberController,
            ),
            const SizedBox(height: 16),
            buildInput(
              hintText: AppStrings.password,
              controller: passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
                    text: AppStrings.registerButton,
                    onPressed: register,
                  ),
          ],
        ),
      ),
    );
  }
}