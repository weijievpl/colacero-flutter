import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';

/// Lightweight onboarding overlay. Shows once per install.
class OnboardingOverlay extends StatefulWidget {
  final Widget child;

  const OnboardingOverlay({super.key, required this.child});

  static Future<bool> hasSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_seen') ?? false;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
  }

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  bool _showOnboarding = false;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final seen = await OnboardingOverlay.hasSeen();
    if (!seen && mounted) {
      setState(() => _showOnboarding = true);
    }
  }

  Future<void> _complete() async {
    await OnboardingOverlay.markSeen();
    if (mounted) setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_showOnboarding) return widget.child;

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final pages = [
      _OnboardPage(
        useLogo: true,
        title: l10n.onboardingTitle1,
        subtitle: l10n.onboardingSubtitle1,
      ),
      _OnboardPage(
        icon: Icons.hourglass_bottom_rounded,
        title: l10n.onboardingTitle2,
        subtitle: l10n.onboardingSubtitle2,
      ),
      _OnboardPage(
        icon: Icons.dashboard_customize_rounded,
        title: l10n.onboardingTitle3,
        subtitle: l10n.onboardingSubtitle3,
      ),
    ];

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: Material(
            color: theme.colorScheme.surface.withValues(alpha: 0.97),
            child: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: _complete,
                      child: Text(l10n.skip),
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: pages[_page],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Dots
                        Row(
                          children: List.generate(pages.length, (i) {
                            return Container(
                              margin: const EdgeInsets.only(right: 6),
                              width: i == _page ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: i == _page
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outlineVariant,
                              ),
                            );
                          }),
                        ),
                        // Next / Done
                        FilledButton.icon(
                          onPressed: () {
                            if (_page < pages.length - 1) {
                              setState(() => _page++);
                            } else {
                              _complete();
                            }
                          },
                          icon: Icon(_page < pages.length - 1
                              ? Icons.arrow_forward_rounded
                              : Icons.check_rounded),
                          label: Text(_page < pages.length - 1
                              ? l10n.next
                              : l10n.getStarted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final IconData? icon;
  final bool useLogo;
  final String title;
  final String subtitle;

  const _OnboardPage({
    this.icon,
    this.useLogo = false,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      key: ValueKey(title),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            useLogo
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset('assets/logo.jpg', width: 120, height: 120, fit: BoxFit.cover),
                  )
                : Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primaryContainer,
                    ),
                    child: Icon(icon, size: 48, color: theme.colorScheme.onPrimaryContainer),
                  ),
            const SizedBox(height: 32),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
