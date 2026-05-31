import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/realtime_database_service.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    try {
      setState(() {
        isLoading = true;
      });

      final generatedEmail =
          '${idNumberController.text.trim()}@kolshaket.com';

      await _authService.login(
        email: generatedEmail,
        password: passwordController.text.trim(),
      );

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('User not found');
      }

      final appUser = await _databaseService.getUserByUid(currentUser.uid);

      if (!mounted) return;

      if (appUser == null) {
        throw Exception('User data not found');
      }

      if (appUser.blocked) {
        await _authService.logout();
        throw Exception('המשתמש חסום');
      }

      if (appUser.role == 'student') {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('תעודת זהות או סיסמה לא נכונים'),
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
          title: const Text('התחברות'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 50),
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
                      text: 'התחבר',
                      onPressed: login,
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.register);
                },
                child: const Text('אין לך חשבון? הירשם'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}