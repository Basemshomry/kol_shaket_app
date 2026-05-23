import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static Map<String, WidgetBuilder> routes = {
    login: (context) => LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    home: (context) => HomeScreen(),
  };
}