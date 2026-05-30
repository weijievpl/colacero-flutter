import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import 'package:uuid/uuid.dart';
import '../../../data/local/database.dart';
import '../../../data/local/database_provider.dart';

class JoinPage extends ConsumerStatefulWidget {
  const JoinPage({super.key});

  @override
  ConsumerState<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends ConsumerState<JoinPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedReason;
  int _partySize = 1;
  bool _isSubmitting = false;

  static const _reasons = [
    ('information', 'Información'),
    ('appointment', 'Cita'),
    ('complaint', 'Reclamo'),
    ('payment', 'Pago'),
    ('pickup', 'Recogida'),
    ('other', 'Otro'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(pattern: [100, 50, 100]);
      }

      final db = ref.read(appDatabaseProvider);
      final number = await db.getNextNumber();
      final ticketId = const Uuid().v4().substring(0, 12);

      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();

      await db.insertTicket(TicketsCompanion(
        ticketId: Value(ticketId),
        number: Value(number),
        name: name.isEmpty ? const Value.absent() : Value(name),
        reason: _selectedReason == null ? const Value.absent() : Value(_selectedReason!),
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

    return Scaffold(
      appBar: AppBar(title: const Text('ColaCero')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.secondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Icon(Icons.confirmation_number_outlined, size: 48, color: theme.colorScheme.onPrimaryContainer),
                    const SizedBox(height: 12),
                    Text('Sacar turno', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
                    const SizedBox(height: 4),
                    Text('Selecciona tu motivo y espera cómodamente', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre (opcional)', prefixIcon: Icon(Icons.person_outline)), textCapitalization: TextCapitalization.words),
              const SizedBox(height: 16),
              Text('Motivo', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: _reasons.map((r) {
                final isSelected = _selectedReason == r.$1;
                return FilterChip(label: Text(r.$2), selected: isSelected, onSelected: (_) => setState(() => _selectedReason = r.$1));
              }).toList()),
              const SizedBox(height: 16),
              Row(children: [
                Icon(Icons.people_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Personas: $_partySize', style: theme.textTheme.titleMedium),
                const Spacer(),
                IconButton.outlined(onPressed: _partySize > 1 ? () => setState(() => _partySize--) : null, icon: const Icon(Icons.remove)),
                const SizedBox(width: 8),
                IconButton.outlined(onPressed: _partySize < 10 ? () => setState(() => _partySize++) : null, icon: const Icon(Icons.add)),
              ]),
              const SizedBox(height: 16),
              TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Teléfono (opcional)', prefixIcon: Icon(Icons.phone_outlined)), keyboardType: TextInputType.phone),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.arrow_forward),
                label: Text(_isSubmitting ? 'Generando...' : 'Sacar turno'),
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: () => context.go('/dashboard'), child: const Text('Acceso administrador')),
            ],
          ),
        ),
      ),
    );
  }
}
