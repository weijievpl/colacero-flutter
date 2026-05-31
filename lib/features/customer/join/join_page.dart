import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import '../../../data/local/database.dart';
import '../../../data/local/database_provider.dart';

class JoinPage extends ConsumerStatefulWidget {
  const JoinPage({super.key});

  @override
  ConsumerState<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends ConsumerState<JoinPage>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedReason;
  int _partySize = 1;
  bool _isSubmitting = false;
  late AnimationController _heroAnimCtrl;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;

  static const _reasons = [
    ('information', 'Información', Icons.info_outline),
    ('appointment', 'Cita', Icons.calendar_today_outlined),
    ('complaint', 'Reclamo', Icons.report_gmailerrorred_outlined),
    ('payment', 'Pago', Icons.payment_outlined),
    ('pickup', 'Recogida', Icons.inventory_2_outlined),
    ('other', 'Otro', Icons.more_horiz_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _heroAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heroFade = CurvedAnimation(parent: _heroAnimCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroAnimCtrl, curve: Curves.easeOutCubic));
    _heroAnimCtrl.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _heroAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    // Haptic feedback — satisfying double-tap
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [80, 40, 80]);
    }
    HapticFeedback.mediumImpact();

    try {
      final db = ref.read(appDatabaseProvider);
      final number = await db.getNextNumber();
      final ticketId = const Uuid().v4().substring(0, 12);

      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();

      await db.insertTicket(TicketsCompanion(
        ticketId: Value(ticketId),
        number: Value(number),
        name: name.isEmpty ? const Value.absent() : Value(name),
        reason: _selectedReason == null
            ? const Value.absent()
            : Value(_selectedReason!),
        phone: phone.isEmpty ? const Value.absent() : Value(phone),
        partySize: Value(_partySize),
        ticketStatus: const Value(0), // waiting
        priority: const Value(0),
        isSynced: const Value(false),
      ));

      if (!mounted) return;
      context.go('/wait/$ticketId');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Hero Header ──
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _heroFade,
                child: SlideTransition(
                  position: _heroSlide,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.primaryContainer,
                          cs.secondaryContainer.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.onPrimaryContainer.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.confirmation_number_outlined,
                              size: 36, color: cs.onPrimaryContainer),
                        ),
                        const SizedBox(height: 16),
                        Text('Sacar turno',
                            style: theme.textTheme.headlineMedium?.copyWith(
                                color: cs.onPrimaryContainer)),
                        const SizedBox(height: 6),
                        Text('Selecciona tu motivo y espera cómodamente',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onPrimaryContainer.withValues(alpha: 0.75))),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Form Section ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Name field
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre (opcional)',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 20),

                  // Reason chips — section header
                  Row(
                    children: [
                      Icon(Icons.category_outlined, size: 18, color: cs.primary),
                      const SizedBox(width: 8),
                      Text('Motivo de visita',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(color: cs.onSurface)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _reasons.map((r) {
                      final isSelected = _selectedReason == r.$1;
                      return FilterChip(
                        avatar: Icon(r.$3,
                            size: 16,
                            color: isSelected
                                ? cs.onPrimaryContainer
                                : cs.onSurfaceVariant),
                        label: Text(r.$2),
                        selected: isSelected,
                        onSelected: (_) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedReason = r.$1);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Party size — refined stepper
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.people_outline,
                              size: 20, color: cs.onPrimaryContainer),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Personas',
                                  style: theme.textTheme.labelLarge),
                              Text('$_partySize ${_partySize == 1 ? "persona" : "personas"}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        _StepperButton(
                          icon: Icons.remove,
                          onPressed: _partySize > 1
                              ? () {
                                  HapticFeedback.lightImpact();
                                  setState(() => _partySize--);
                                }
                              : null,
                        ),
                        const SizedBox(width: 12),
                        _StepperButton(
                          icon: Icons.add,
                          onPressed: _partySize < 10
                              ? () {
                                  HapticFeedback.lightImpact();
                                  setState(() => _partySize++);
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Phone field
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono (opcional)',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.arrow_forward_rounded),
                    label: Text(_isSubmitting ? 'Generando...' : 'Sacar turno'),
                  ),
                  const SizedBox(height: 16),

                  // Admin link — subtle
                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.go('/dashboard'),
                      icon: const Icon(Icons.admin_panel_settings_outlined, size: 16),
                      label: const Text('Acceso administrador'),
                      style: TextButton.styleFrom(
                        foregroundColor: cs.onSurfaceVariant,
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Recovery link
                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.go('/recover'),
                      icon: const Icon(Icons.restore_rounded, size: 16),
                      label: const Text('Recuperar turno perdido'),
                      style: TextButton.styleFrom(
                        foregroundColor: cs.primary,
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Appointment link
                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.go('/appointment'),
                      icon: const Icon(Icons.event_outlined, size: 16),
                      label: const Text('Agendar cita'),
                      style: TextButton.styleFrom(
                        foregroundColor: cs.tertiary,
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _StepperButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedOpacity(
        opacity: onPressed == null ? 0.3 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: cs.onSurface),
        ),
      ),
    );
  }
}
