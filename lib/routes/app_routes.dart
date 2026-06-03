import 'package:flutter/material.dart';

import '../screens/admin_dashboard_screen.dart';
import '../screens/chats_screen.dart';
import '../screens/counselor_reports_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/register_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String adminDashboard = '/admin-dashboard';
  static const String counselorReports = '/counselor-reports';
  static const String chats = '/chats';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const MainNavigationScreen(),
    adminDashboard: (context) => const AdminDashboardScreen(),
    counselorReports: (context) => const CounselorReportsScreen(),
    chats: (context) => ChatsScreen(),
  };
}