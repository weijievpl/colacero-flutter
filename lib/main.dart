import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ColaCeroApp()));
}

class ColaCeroApp extends ConsumerWidget {
  const ColaCeroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'ColaCero',
      debugShowCheckedModeBanner: false,
      theme: ColaCeroTheme.light(),
      darkTheme: ColaCeroTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      locale: const Locale('es'),
    );
  }
}
