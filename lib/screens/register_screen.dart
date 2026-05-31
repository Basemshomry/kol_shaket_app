import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
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

      final approvedStudent =
          await _databaseService.getApprovedStudent(idNumber);

      final approvedAdmin = await _databaseService.getApprovedAdmin(idNumber);

      if (approvedStudent == null && approvedAdmin == null) {
        throw Exception('תעודת הזהות לא נמצאת ברשימת בית הספר');
      }

      final bool isStudent = approvedStudent != null;
      final approvedData = isStudent ? approvedStudent : approvedAdmin!;

      final String role = isStudent
          ? 'student'
          : (approvedData['role'] ?? 'counselor');

      final generatedEmail = '$idNumber@kolshaket.com';

      final credential = await _authService.register(
        email: generatedEmail,
        password: passwordController.text.trim(),
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

      if (!mounted) return;

      if (role == 'student') {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'אירעה שגיאה בהרשמה';

      if (e.code == 'email-already-in-use') {
        message = 'משתמש עם תעודת זהות זו כבר רשום במערכת';
      } else if (e.code == 'weak-password') {
        message = 'הסיסמה חייבת להכיל לפחות 6 תווים';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
          title: const Text('הרשמה'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              buildInput(
                hintText: 'תעודת זהות',
                controller: idNumberController,
              ),
              const SizedBox(height: 16),
              buildInput(
                hintText: 'סיסמה',
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      text: 'הירשם',
                      onPressed: register,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}