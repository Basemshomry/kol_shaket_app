import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'services/language_service.dart';
import 'services/session_service.dart';
import 'theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LanguageService.instance.loadLanguage();

  runApp(const KolShaketApp());
}

class KolShaketApp extends StatelessWidget {
  const KolShaketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LanguageService.instance,
      builder: (context, _) {
        return SessionService(
          navigatorKey: navigatorKey,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Kol Shaket',
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.login,
            routes: AppRoutes.routes,
            builder: (context, child) {
              return Directionality(
                textDirection: LanguageService.instance.isRtl
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child ?? const SizedBox(),
              );
            },
          ),
        );
      },
    );
  }
}