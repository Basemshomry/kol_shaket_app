import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const KolShaketApp());
}

class KolShaketApp extends StatelessWidget {
  const KolShaketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kol Shaket',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.adminDashboard,
      routes: AppRoutes.routes,
    );
  }
}