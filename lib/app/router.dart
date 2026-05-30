import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/customer/join/join_page.dart';
import '../features/customer/wait/wait_page.dart';
import '../features/admin/dashboard/dashboard_page.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/join',
    routes: [
      GoRoute(
        path: '/join',
        builder: (context, state) => const JoinPage(),
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const JoinPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: '/wait/:ticketId',
        builder: (context, state) {
          final ticketId = state.pathParameters['ticketId']!;
          return WaitPage(ticketId: ticketId);
        },
        pageBuilder: (context, state) {
          final ticketId = state.pathParameters['ticketId']!;
          return CustomTransitionPage(
            child: WaitPage(ticketId: ticketId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Slide up + fade — like a bottom sheet reveal
              final slideTween = Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
              return SlideTransition(
                position: slideTween,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          );
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const DashboardPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Shared element style — scale + fade
            final scaleTween = Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
            return ScaleTransition(
              scale: scaleTween,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),
    ],
  );
});
