import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final AuthService _authService = AuthService();

  Future<void> logout(BuildContext context) async {
    await _authService.logout();

    if (!context.mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kol Shaket'),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to Kol Shaket',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}