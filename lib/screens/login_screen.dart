import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import '../services/notification_service.dart';
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
      setState(() => isLoading = true);

      final idNumber = idNumberController.text.trim();
      final password = passwordController.text.trim();

      if (idNumber.isEmpty || password.isEmpty) {
        throw Exception(AppStrings.wrongLogin);
      }

      final generatedEmail = '$idNumber@kolshaket.com';

      await _authService.login(
        email: generatedEmail,
        password: password,
      );

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('User not found');
      }

      final appUser = await _databaseService.getUserByUid(currentUser.uid);

      if (!mounted) return;

      if (appUser == null) {
        await _authService.logout();
        throw Exception('User data not found');
      }

      if (appUser.blocked) {
        await _authService.logout();
        throw Exception(AppStrings.userBlocked);
      }

      NotificationService.instance.saveCurrentUserToken();

      if (appUser.role == 'student') {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    idNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget animatedItem({
    required Widget child,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 900 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 35 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget buildInput({
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textDirection:
          LanguageService.instance.isRtl ? TextDirection.rtl : TextDirection.ltr,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary),
        hintText: hintText,
      ),
    );
  }

  Widget languageButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: AppColors.primary),
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LanguageService.instance,
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: languageButton(),
                  ),
                  const SizedBox(height: 30),
                  animatedItem(
                    delay: 0,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        size: 46,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  animatedItem(
                    delay: 120,
                    child: Text(
                      AppStrings.appName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  animatedItem(
                    delay: 220,
                    child: Text(
                      AppStrings.text(
                        he: 'מקום בטוח לשיתוף וקבלת עזרה',
                        en: 'A safe place to share and get help',
                        ar: 'مكان آمن للمشاركة وطلب المساعدة',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 42),
                  animatedItem(
                    delay: 320,
                    child: buildInput(
                      hintText: AppStrings.idNumber,
                      controller: idNumberController,
                      icon: Icons.badge_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),
                  animatedItem(
                    delay: 420,
                    child: buildInput(
                      hintText: AppStrings.password,
                      controller: passwordController,
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 28),
                  animatedItem(
                    delay: 520,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: AppStrings.loginButton,
                            icon: Icons.login,
                            onPressed: login,
                          ),
                  ),
                  const SizedBox(height: 18),
                  animatedItem(
                    delay: 620,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: Text(AppStrings.noAccountRegister),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}