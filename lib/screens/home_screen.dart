import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../utils/app_page_route.dart';
import 'report_form_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  List<Map<String, dynamic>> reportCategories() {
    return [
      {
        'title': AppStrings.bullying,
        'subtitle': AppStrings.text(
          he: 'דווח על הצקות, איומים או אלימות',
          en: 'Report bullying, threats, or violence',
          ar: 'بلّغ عن تنمّر، تهديدات أو عنف',
        ),
        'icon': Icons.warning_amber_rounded,
        'color': AppColors.error,
      },
      {
        'title': AppStrings.mentalPressure,
        'subtitle': AppStrings.text(
          he: 'שתף תחושות של עומס או לחץ',
          en: 'Share feelings of pressure or stress',
          ar: 'شارك مشاعر الضغط أو التوتر',
        ),
        'icon': Icons.psychology,
        'color': AppColors.warning,
      },
      {
        'title': AppStrings.socialDifficulties,
        'subtitle': AppStrings.text(
          he: 'קושי חברתי? אנחנו כאן לעזור',
          en: 'Social difficulty? We are here to help',
          ar: 'صعوبة اجتماعية؟ نحن هنا للمساعدة',
        ),
        'icon': Icons.groups,
        'color': AppColors.primary,
      },
      {
        'title': AppStrings.distress,
        'subtitle': AppStrings.text(
          he: 'מצב דחוף או תחושת מצוקה',
          en: 'Urgent situation or distress',
          ar: 'حالة طارئة أو ضائقة',
        ),
        'icon': Icons.sos,
        'color': AppColors.error,
      },
      {
        'title': AppStrings.other,
        'subtitle': AppStrings.text(
          he: 'כל נושא אחר שחשוב לשתף',
          en: 'Anything else important to share',
          ar: 'أي موضوع آخر مهم للمشاركة',
        ),
        'icon': Icons.more_horiz,
        'color': AppColors.textSecondary,
      },
    ];
  }

  void openReport(BuildContext context, String category) {
    Navigator.push(
      context,
      AppPageRoute(
        page: ReportFormScreen(category: category),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    await AuthService().logout();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  Widget animatedItem({
    required Widget child,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 800 + (index * 140)),
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

  Widget categoryCard(BuildContext context, Map<String, dynamic> category) {
    final Color color = category['color'];

    return _PressableCard(
      onTap: () => openReport(context, category['title']),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
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
              child: Icon(category['icon'], color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['title'],
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    category['subtitle'],
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = reportCategories();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.logout,
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            animatedItem(
              index: 0,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.health_and_safety_outlined,
                      color: Colors.white,
                      size: 42,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      AppStrings.howCanWeHelp,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.chooseReportType,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              categories.length,
              (index) => animatedItem(
                index: index + 1,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: categoryCard(context, categories[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapCancel: () => setState(() => isPressed = false),
      onTapUp: (_) => setState(() => isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: isPressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}