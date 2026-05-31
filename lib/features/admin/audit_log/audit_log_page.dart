import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/local/database.dart';
import '../../../data/local/database_provider.dart';

class AuditLogPage extends ConsumerStatefulWidget {
  const AuditLogPage({super.key});

  @override
  ConsumerState<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends ConsumerState<AuditLogPage>
    with SingleTickerProviderStateMixin {
  List<AuditEvent> _events = [];
  bool _isLoading = true;
  String? _filterType;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  static const _eventLabels = {
    'ticket_created': ('Turno creado', Icons.confirmation_number_outlined, Color(0xFF4F46E5)),
    'ticket_called': ('Turno llamado', Icons.campaign_outlined, Color(0xFFF59E0B)),
    'ticket_served': ('Turno atendido', Icons.check_circle_outline_rounded, Color(0xFF10B981)),
    'ticket_cancelled': ('Turno cancelado', Icons.cancel_outlined, Color(0xFFEF4444)),
    'ticket_no_show': ('No-show', Icons.person_off_outlined, Color(0xFF78716C)),
    'ticket_recovered': ('Turno recuperado', Icons.restore_rounded, Color(0xFF6366F1)),
    'appointment_created': ('Cita creada', Icons.event_available_outlined, Color(0xFF8B5CF6)),
    'appointment_cancelled': ('Cita cancelada', Icons.event_busy_outlined, Color(0xFFEF4444)),
    'sync_completed': ('Sync completada', Icons.sync_rounded, Color(0xFF10B981)),
    'sync_failed': ('Sync fallida', Icons.sync_problem_rounded, Color(0xFFEF4444)),
  };

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _loadEvents();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final db = ref.read(appDatabaseProvider);
    final events = await db.getAuditEvents(limit: 200, eventType: _filterType);
    if (!mounted) return;
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  Future<void> _exportCsv() async {
    HapticFeedback.mediumImpact();
    final buffer = StringBuffer('timestamp,event_type,ticket_id,payload\n');
    for (final e in _events) {
      buffer.writeln('${e.createdAt.toIso8601String()},${e.eventType},${e.ticketId ?? ""},${e.payloadJson ?? ""}');
    }
    // Copy to clipboard as simple export mechanism
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.copy_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text('${_events.length} registros copiados al portapapeles'),
        ]),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dateFormat = DateFormat('dd/MM HH:mm:ss');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Historial de eventos'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            onSelected: (v) {
              setState(() => _filterType = v == 'all' ? null : v);
              _loadEvents();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'all', child: Text('Todos')),
              ...(_eventLabels.entries.map((e) => PopupMenuItem(
                value: e.key,
                child: Row(children: [
                  Icon(e.value.$2, size: 16, color: e.value.$3),
                  const SizedBox(width: 8),
                  Text(e.value.$1),
                ]),
              ))),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _exportCsv,
            tooltip: 'Exportar CSV',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: cs.primary))
            : _events.isEmpty
                ? _buildEmptyState(theme, cs)
                : FadeTransition(
                    opacity: _fadeAnim,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final event = _events[index];
                        final meta = _eventLabels[event.eventType] ?? ('Evento', Icons.circle_outlined, cs.onSurfaceVariant);
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 300 + (index * 30).clamp(0, 600)),
                          curve: Curves.easeOut,
                          builder: (context, val, child) {
                            return Transform.translate(
                              offset: Offset(-20 * (1 - val), 0),
                              child: Opacity(opacity: val, child: child),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: meta.$3.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(meta.$2, size: 18, color: meta.$3),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(meta.$1,
                                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 3),
                                      Row(children: [
                                        Text(dateFormat.format(event.createdAt),
                                            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                                        if (event.ticketId != null) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: cs.surfaceContainerHigh,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text('#${event.ticketId!.substring(0, 6)}',
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
                                          ),
                                        ],
                                      ]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_toggle_off_rounded, size: 48, color: cs.onPrimaryContainer),
          ),
          const SizedBox(height: 20),
          Text('Sin eventos registrados', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Los eventos aparecerán aquí cuando se realicen acciones',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
