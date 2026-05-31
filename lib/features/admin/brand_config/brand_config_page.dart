import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import '../../data/local/database.dart';
import '../../data/local/database_provider.dart';

// Brand config keys
abstract class BrandKeys {
  static const businessName = 'business_name';
  static const primaryColor = 'primary_color';
  static const logoUrl = 'logo_url';
  static const welcomeMessage = 'welcome_message';
  static const notificationPrefix = 'notification_prefix';
}

// Default brand values
abstract class BrandDefaults {
  static const businessName = 'ColaCero';
  static const primaryColor = 0xFF4F46E5; // Indigo-600
  static const welcomeMessage = 'Selecciona tu motivo y espera cómodamente';
  static const notificationPrefix = 'ColaCero';
}

class BrandConfigPage extends ConsumerStatefulWidget {
  const BrandConfigPage({super.key});

  @override
  ConsumerState<BrandConfigPage> createState() => _BrandConfigPageState();
}

class _BrandConfigPageState extends ConsumerState<BrandConfigPage>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController(text: BrandDefaults.businessName);
  final _welcomeController = TextEditingController(text: BrandDefaults.welcomeMessage);
  final _notifPrefixController = TextEditingController(text: BrandDefaults.notificationPrefix);
  Color _selectedColor = const Color(BrandDefaults.primaryColor);
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasChanges = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  static const _presetColors = [
    Color(0xFF4F46E5), // Indigo
    Color(0xFF2563EB), // Blue
    Color(0xFF0891B2), // Cyan
    Color(0xFF059669), // Emerald
    Color(0xFFD97706), // Amber
    Color(0xFFDC2626), // Red
    Color(0xFF9333EA), // Purple
    Color(0xFFDB2777), // Pink
    Color(0xFF475569), // Slate
    Color(0xFF18181B), // Zinc
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _loadConfig();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _welcomeController.dispose();
    _notifPrefixController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    final db = ref.read(appDatabaseProvider);

    final name = await db.getBrandValue(BrandKeys.businessName);
    final colorHex = await db.getBrandValue(BrandKeys.primaryColor);
    final welcome = await db.getBrandValue(BrandKeys.welcomeMessage);
    final notifPrefix = await db.getBrandValue(BrandKeys.notificationPrefix);

    if (!mounted) return;
    setState(() {
      if (name != null) _nameController.text = name;
      if (colorHex != null) {
        try { _selectedColor = Color(int.parse(colorHex)); } catch (_) {}
      }
      if (welcome != null) _welcomeController.text = welcome;
      if (notifPrefix != null) _notifPrefixController.text = notifPrefix;
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final db = ref.read(appDatabaseProvider);
    await db.setBrandValue(BrandKeys.businessName, _nameController.text.trim());
    await db.setBrandValue(BrandKeys.primaryColor, _selectedColor.value.toString());
    await db.setBrandValue(BrandKeys.welcomeMessage, _welcomeController.text.trim());
    await db.setBrandValue(BrandKeys.notificationPrefix, _notifPrefixController.text.trim());

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _hasChanges = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          const Text('Configuración de marca guardada'),
        ]),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  Future<void> _resetToDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurar valores predeterminados'),
        content: const Text('Esto restablecerá toda la configuración de marca a los valores originales. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Restaurar')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _nameController.text = BrandDefaults.businessName;
      _selectedColor = const Color(BrandDefaults.primaryColor);
      _welcomeController.text = BrandDefaults.welcomeMessage;
      _notifPrefixController.text = BrandDefaults.notificationPrefix;
      _hasChanges = true;
    });
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  /// Simple luminance check for contrast warning
  bool _hasGoodContrast(Color bg) {
    final luminance = bg.computeLuminance();
    return luminance < 0.5; // dark enough for white text
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Configuración de marca'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore_rounded),
            onPressed: _resetToDefaults,
            tooltip: 'Restaurar predeterminados',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: cs.primary))
            : FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Live Preview Card ──
                      Text('Vista previa', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      _BrandPreview(
                        businessName: _nameController.text.isEmpty ? BrandDefaults.businessName : _nameController.text,
                        primaryColor: _selectedColor,
                        welcomeMessage: _welcomeController.text.isEmpty ? BrandDefaults.welcomeMessage : _welcomeController.text,
                      ),
                      const SizedBox(height: 24),

                      // ── Business Name ──
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del negocio',
                          prefixIcon: Icon(Icons.store_outlined),
                        ),
                        onChanged: (_) => _markChanged(),
                      ),
                      const SizedBox(height: 16),

                      // ── Primary Color ──
                      Text('Color de marca', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _presetColors.map((color) {
                          final isSelected = _selectedColor.value == color.value;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedColor = color;
                                _markChanged();
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 2)]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      // Contrast warning
                      if (!_hasGoodContrast(_selectedColor))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(children: [
                            Icon(Icons.warning_amber_rounded, size: 16, color: const Color(0xFFF59E0B)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Este color puede tener bajo contraste con texto blanco',
                                style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFFF59E0B)),
                              ),
                            ),
                          ]),
                        ),
                      const SizedBox(height: 16),

                      // ── Welcome Message ──
                      TextField(
                        controller: _welcomeController,
                        decoration: const InputDecoration(
                          labelText: 'Mensaje de bienvenida',
                          prefixIcon: Icon(Icons.waving_hand_outlined),
                        ),
                        maxLines: 2,
                        onChanged: (_) => _markChanged(),
                      ),
                      const SizedBox(height: 16),

                      // ── Notification Prefix ──
                      TextField(
                        controller: _notifPrefixController,
                        decoration: const InputDecoration(
                          labelText: 'Prefijo de notificaciones',
                          prefixIcon: Icon(Icons.notifications_outlined),
                          hintText: 'Aparece en el título de las notificaciones',
                        ),
                        onChanged: (_) => _markChanged(),
                      ),
                      const SizedBox(height: 32),

                      // ── Save Button ──
                      FilledButton.icon(
                        onPressed: (_isSaving || !_hasChanges) ? null : _save,
                        icon: _isSaving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save_rounded),
                        label: Text(_isSaving ? 'Guardando...' : 'Guardar cambios'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

/// Live preview widget showing how the brand will look
class _BrandPreview extends StatelessWidget {
  final String businessName;
  final Color primaryColor;
  final String welcomeMessage;

  const _BrandPreview({
    required this.businessName,
    required this.primaryColor,
    required this.welcomeMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = primaryColor.computeLuminance() > 0.5
        ? const Color(0xFF18181B)
        : const Color(0xFFFFFFFF);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor,
            primaryColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Column(
          children: [
            // Simulated app bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.confirmation_number_outlined, size: 20, color: textColor),
                ),
                const SizedBox(width: 10),
                Text(
                  businessName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Simulated hero text
            Text(
              'Sacar turno',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              welcomeMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            // Simulated button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Sacar turno',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
