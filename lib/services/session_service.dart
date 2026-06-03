import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../routes/app_routes.dart';

class SessionService extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const SessionService({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<SessionService> createState() => _SessionServiceState();
}

class _SessionServiceState extends State<SessionService>
    with WidgetsBindingObserver {
  Timer? _timer;
  StreamSubscription<User?>? _authSubscription;

  DateTime? _pausedAt;

  // לבדיקה:
  static const Duration logoutDuration = Duration(minutes: 10);

  // אחרי בדיקה תחזיר ל:
  // static const Duration logoutDuration = Duration(minutes: 10);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        resetTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  void resetTimer() {
    _timer?.cancel();

    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }

    _timer = Timer(logoutDuration, logoutUser);
  }

  Future<void> logoutUser() async {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }

    await FirebaseAuth.instance.signOut();

    _timer?.cancel();

    widget.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (FirebaseAuth.instance.currentUser == null) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _pausedAt = DateTime.now();
    }

    if (state == AppLifecycleState.resumed) {
      if (_pausedAt != null) {
        final timeAway = DateTime.now().difference(_pausedAt!);

        if (timeAway >= logoutDuration) {
          logoutUser();
          return;
        }
      }

      resetTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _authSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => resetTimer(),
      onPointerMove: (_) => resetTimer(),
      onPointerSignal: (_) => resetTimer(),
      child: widget.child,
    );
  }
}