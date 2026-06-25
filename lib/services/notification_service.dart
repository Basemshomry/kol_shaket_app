import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import 'realtime_database_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  GlobalKey<NavigatorState>? _navigatorKey;

  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;

    await _requestPermission();
    await saveCurrentUserToken();
    _listenToTokenRefresh();
    _handleForegroundMessages();
    _handleNotificationClicks();
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> saveCurrentUserToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    await RealtimeDatabaseService().saveFcmToken(
      uid: user.uid,
      token: token,
    );
  }

  void _listenToTokenRefresh() {
    _messaging.onTokenRefresh.listen((token) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await RealtimeDatabaseService().saveFcmToken(
        uid: user.uid,
        token: token,
      );
    });
  }

  void _handleForegroundMessages() {
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Foreground notification: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
    });
  }

  void _handleNotificationClicks() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _openFromPayload(message.data['screen']);
    });

    _messaging.getInitialMessage().then((message) {
      if (message == null) return;
      _openFromPayload(message.data['screen']);
    });
  }

  void _openFromPayload(String? payload) {
    if (payload == null) return;

    final navigator = _navigatorKey?.currentState;
    if (navigator == null) return;

    if (payload == 'notifications') {
      navigator.pushNamed(AppRoutes.adminDashboard);
    } else if (payload == 'chats') {
      navigator.pushNamed(AppRoutes.chats);
    } else if (payload == 'reports') {
      navigator.pushNamed(AppRoutes.counselorReports);
    }
  }
}