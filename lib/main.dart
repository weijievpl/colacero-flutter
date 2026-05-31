import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'services/notification_service.dart';
import 'l10n/app_localizations.dart';
import 'shared/widgets/offline_banner.dart';
import 'shared/widgets/onboarding_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
        Locale('pt'),
        Locale('fr'),
        Locale('de'),
      ],
      locale: const Locale('es'),
      builder: (context, child) {
        return OnboardingOverlay(
          child: OfflineBanner(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
