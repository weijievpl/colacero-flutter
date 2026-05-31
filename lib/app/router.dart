import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/customer/join/join_page.dart';
import '../features/customer/wait/wait_page.dart';
import '../features/customer/recovery/recovery_page.dart';
import '../features/customer/appointment/appointment_page.dart';
import '../features/admin/dashboard/dashboard_page.dart';
import '../features/admin/analytics/analytics_page.dart';
import '../features/admin/audit_log/audit_log_page.dart';
import '../features/admin/brand_config/brand_config_page.dart';
import '../features/admin/auth/operator_pin_gate.dart';

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
        path: '/recover',
        builder: (context, state) => const RecoveryPage(),
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const RecoveryPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideTween = Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
            return SlideTransition(
              position: slideTween,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),
      GoRoute(
        path: '/appointment',
        builder: (context, state) => const AppointmentPage(),
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const AppointmentPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideTween = Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
            return SlideTransition(
              position: slideTween,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => OperatorPinGate(child: const DashboardPage()),
        pageBuilder: (context, state) => CustomTransitionPage(
          child: OperatorPinGate(child: const DashboardPage()),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsPage(),
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const AnalyticsPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: '/audit-log',
        builder: (context, state) => const AuditLogPage(),
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const AuditLogPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: '/brand-config',
        builder: (context, state) => const BrandConfigPage(),
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const BrandConfigPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
    ],
  );
});
