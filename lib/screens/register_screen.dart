import 'package:flutter/material.dart';

import '../models/app_user.dart';
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

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController idNumberController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> register() async {
    try {
      setState(() {
        isLoading = true;
      });

      final credential = await _authService.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = AppUser(
        uid: credential.user!.uid,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        idNumber: idNumberController.text.trim(),
        className: classController.text.trim(),
        role: 'student',
        blocked: false,
      );

      await _databaseService.createUser(user);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration Success'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
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
    firstNameController.dispose();
    lastNameController.dispose();
    idNumberController.dispose();
    classController.dispose();
    emailController.dispose();
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
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            buildInput(
              hintText: 'First Name',
              controller: firstNameController,
            ),

            const SizedBox(height: 16),

            buildInput(
              hintText: 'Last Name',
              controller: lastNameController,
            ),

            const SizedBox(height: 16),

            buildInput(
              hintText: 'ID Number',
              controller: idNumberController,
            ),

            const SizedBox(height: 16),

            buildInput(
              hintText: 'Class',
              controller: classController,
            ),

            const SizedBox(height: 16),

            buildInput(
              hintText: 'Email',
              controller: emailController,
            ),

            const SizedBox(height: 16),

            buildInput(
              hintText: 'Password',
              controller: passwordController,
              obscureText: true,
            ),

            const SizedBox(height: 30),

            isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
                    text: 'Register',
                    onPressed: register,
                  ),
          ],
        ),
      ),
    );
  }
}