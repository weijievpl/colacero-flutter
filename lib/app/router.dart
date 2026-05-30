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
      ),
      GoRoute(
        path: '/wait/:ticketId',
        builder: (context, state) {
          final ticketId = state.pathParameters['ticketId']!;
          return WaitPage(ticketId: ticketId);
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
    ],
  );
});
