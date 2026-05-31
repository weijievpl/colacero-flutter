import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import '../../../data/local/database.dart';
import '../../../data/local/database_provider.dart';
import '../../../services/audit_logger.dart';

class AppointmentPage extends ConsumerStatefulWidget {
  const AppointmentPage({super.key});

  @override
  ConsumerState<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends ConsumerState<AppointmentPage>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedReason;
  int _partySize = 1;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;
  String? _error;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  static const _reasons = [
    ('information', 'Información'),
    ('appointment', 'Cita formal'),
    ('complaint', 'Reclamo'),
    ('payment', 'Pago'),
    ('pickup', 'Recogida'),
    ('other', 'Otro'),
  ];

  // Available time slots (9:00 - 17:00, every 30 min)
  static List<TimeOfDay> get _timeSlots {
    return List.generate(16, (i) => TimeOfDay(
      hour: 9 + (i * 30 ~/ 60),
      minute: (i * 30) % 60,
    ));
  }

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = 'El nombre es obligatorio para citas');
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      setState(() => _error = 'Selecciona fecha y hora');
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      final db = ref.read(appDatabaseProvider);
      final scheduledAt = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        _selectedTime!.hour, _selectedTime!.minute,
      );

      // Check conflicts
      final hasConflict = await db.hasConflict(scheduledAt, 30);
      if (hasConflict) {
        setState(() => _error = 'Este horario ya está ocupado. Elige otro.');
        HapticFeedback.heavyImpact();
        return;
      }

      final appointmentId = const Uuid().v4().substring(0, 12);

      await db.insertAppointment(AppointmentsCompanion(
        appointmentId: Value(appointmentId),
        customerName: Value(_nameController.text.trim()),
        phone: _phoneController.text.trim().isEmpty
            ? const Value.absent()
            : Value(_phoneController.text.trim()),
        reason: _selectedReason == null ? const Value.absent() : Value(_selectedReason!),
        scheduledAt: Value(scheduledAt),
        partySize: Value(_partySize),
        notes: _notesController.text.trim().isEmpty
            ? const Value.absent()
            : Value(_notesController.text.trim()),
      ));

      // Log audit event
      final audit = AuditLogger(db);
      await audit.appointmentCreated(appointmentId);

      if (!mounted) return;
      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text('Cita agendada para ${_formatDateTime(scheduledAt)}'),
          ]),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      context.go('/join');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Error al crear cita: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatDateTime(DateTime dt) {
    final months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${dt.day} ${months[dt.month - 1]} · ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/join'),
        ),
        title: const Text('Agendar cita'),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name (required)
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Phone
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Reason
                DropdownButtonFormField<String>(
                  value: _selectedReason,
                  decoration: const InputDecoration(
                    labelText: 'Motivo',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _reasons.map((r) => DropdownMenuItem(
                    value: r.$1,
                    child: Text(r.$2),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedReason = v),
                ),
                const SizedBox(height: 16),

                // Date picker
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, color: cs.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fecha', style: theme.textTheme.labelLarge),
                              Text(
                                _selectedDate != null
                                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                    : 'Seleccionar fecha',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: _selectedDate != null ? cs.onSurface : cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Time slot grid
                Text('Horario disponible', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _timeSlots.map((slot) {
                    final isSelected = _selectedTime == slot;
                    final label = '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}';
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedTime = slot);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Party size
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.people_outline, color: cs.primary),
                      const SizedBox(width: 16),
                      Expanded(child: Text('Personas: $_partySize')),
                      IconButton(
                        onPressed: _partySize > 1 ? () => setState(() => _partySize--) : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      IconButton(
                        onPressed: _partySize < 10 ? () => setState(() => _partySize++) : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Notes
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas adicionales',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),

                // Error
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_error!, style: TextStyle(color: const Color(0xFFEF4444)))),
                      ]),
                    ),
                  ),

                const SizedBox(height: 16),

                // Submit
                FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.event_available_rounded),
                  label: Text(_isSubmitting ? 'Agendando...' : 'Confirmar cita'),
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
