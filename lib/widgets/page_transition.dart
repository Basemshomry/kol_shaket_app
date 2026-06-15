import 'package:flutter/material.dart';

class AppPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  AppPageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            const begin = Offset(0.08, 0);
            const end = Offset.zero;

            final slideAnimation = Tween(
              begin: begin,
              end: end,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );

            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
        );
}