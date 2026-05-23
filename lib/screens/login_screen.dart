import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Success'),
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
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
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            buildInput(
              hintText: 'ID Number',
              controller: idNumberController,
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
                    text: 'Login',
                    onPressed: login,
                  ),
          ],
        ),
      ),
    );
  }
}