import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const KolShaketApp());
}

class KolShaketApp extends StatelessWidget {
  const KolShaketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kol Shaket',
      home: const SplashScreen(),
    );
  }
}