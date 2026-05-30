import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:drift/drift.dart' show Value;
import '../../../data/local/database.dart';
import '../../../data/local/database_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});
  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with TickerProviderStateMixin {
  List<Ticket> _waitingTickets = [];
  int _servedToday = 0;
  bool _isLoading = true;
  late AnimationController _listAnimCtrl;

  @override
  void initState() {
    super.initState();
    _listAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadData();
  }

  @override
  void dispose() {
    _listAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final db = ref.read(appDatabaseProvider);
    final waiting = await db.watchWaitingTickets().first;
    final history = await db.getHistory(limit: 999);
    final today = DateTime.now();
    final servedToday = history.where((t) =>
      t.ticketStatus == 2 &&
      t.servedAt != null &&
      t.servedAt!.day == today.day &&
      t.servedAt!.month == today.month
    ).length;

    if (!mounted) return;
    setState(() {
      _waitingTickets = waiting;
      _servedToday = servedToday;
      _isLoading = false;
    });
    _listAnimCtrl.forward(from: 0.0);
  }

  Future<void> _serveNext() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [50, 30, 50]);
    }
    HapticFeedback.mediumImpact();

    final db = ref.read(appDatabaseProvider);
    if (_waitingTickets.isEmpty) return;

    final next = _waitingTickets.first;
    await db.updateTicket(TicketsCompanion(
      id: Value(next.id),
      ticketId: Value(next.ticketId),
      number: Value(next.number),
      ticketStatus: const Value(2),
      servedAt: Value(DateTime.now()),
      isSynced: const Value(false),
    ));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text('Turno ${next.number.toString().padLeft(2, '0')} atendido',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
    _loadData();
  }

  Future<void> _updateStatus(Ticket ticket, int statusCode) async {
    HapticFeedback.lightImpact();
    final db = ref.read(appDatabaseProvider);
    await db.updateTicket(TicketsCompanion(
      id: Value(ticket.id),
      ticketId: Value(ticket.ticketId),
      number: Value(ticket.number),
      ticketStatus: Value(statusCode),
      isSynced: const Value(false),
    ));
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? _LoadingState(cs: cs)
            : RefreshIndicator(
                onRefresh: _loadData,
                color: cs.primary,
                child: CustomScrollView(
                  slivers: [
                    // ── Header ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Panel Admin',
                                      style: theme.textTheme.headlineMedium),
                                  const SizedBox(height: 4),
                                  Text('Gestión de turnos en tiempo real',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                          color: cs.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _loadData,
                              icon: const Icon(Icons.refresh_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: cs.surfaceContainerLow,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Stats Row ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.people_outline_rounded,
                                label: 'En cola',
                                value: '${_waitingTickets.length}',
                                color: cs.primary,
                                trend: _waitingTickets.length > 5 ? 'Alta demanda' : 'Normal',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.check_circle_outline_rounded,
                                label: 'Atendidos hoy',
                                value: '$_servedToday',
                                color: const Color(0xFF10B981),
                                trend: 'Productividad',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Section Header ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('Cola actual',
                                style: theme.textTheme.titleMedium),
                            const Spacer(),
                            if (_waitingTickets.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_waitingTickets.length} esperando',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onPrimaryContainer,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // ── Ticket List or Empty State ──
                    if (_waitingTickets.isEmpty)
                      SliverToBoxAdapter(
                        child: _EmptyState(theme: theme, cs: cs),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final ticket = _waitingTickets[index];
                              return FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: _listAnimCtrl,
                                  curve: Interval(
                                    index * 0.1.clamp(0.0, 1.0),
                                    (index * 0.1 + 0.3).clamp(0.0, 1.0),
                                    curve: Curves.easeOut,
                                  ),
                                ),
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.1),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: _listAnimCtrl,
                                    curve: Interval(
                                      index * 0.1.clamp(0.0, 1.0),
                                      (index * 0.1 + 0.3).clamp(0.0, 1.0),
                                      curve: Curves.easeOutCubic,
                                    ),
                                  )),
                                  child: _TicketCard(
                                    ticket: ticket,
                                    theme: theme,
                                    cs: cs,
                                    onServe: () => _serveNext(),
                                    onCancel: () => _updateStatus(ticket, 3),
                                    onNoShow: () => _updateStatus(ticket, 4),
                                    isFirst: index == 0,
                                  ),
                                ),
                              );
                            },
                            childCount: _waitingTickets.length,
                          ),
                        ),
                      ),

                    // Bottom spacer for FAB
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: _waitingTickets.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _serveNext,
              icon: const Icon(Icons.call_made_rounded),
              label: const Text('Llamar siguiente'),
              heroTag: 'serve_fab',
            )
          : null,
    );
  }
}

// ── Sub-components ──

class _LoadingState extends StatelessWidget {
  final ColorScheme cs;
  const _LoadingState({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: cs.primary),
          const SizedBox(height: 16),
          Text('Cargando panel...',
              style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme cs;
  const _EmptyState({required this.theme, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inbox_outlined,
                  size: 48, color: cs.onPrimaryContainer),
            ),
            const SizedBox(height: 20),
            Text('No hay turnos en espera',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Los nuevos turnos aparecerán aquí automáticamente',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String trend;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Transform.translate(
          offset: Offset(0, 15 * (1 - val)),
          child: Opacity(opacity: val, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 14),
            Text(value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.0,
                )),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.3,
                )),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(trend,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Ticket ticket;
  final ThemeData theme;
  final ColorScheme cs;
  final VoidCallback onServe;
  final VoidCallback onCancel;
  final VoidCallback onNoShow;
  final bool isFirst;
  const _TicketCard({
    required this.ticket,
    required this.theme,
    required this.cs,
    required this.onServe,
    required this.onCancel,
    required this.onNoShow,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final displayNum = ticket.number.toString().padLeft(2, '0');
    final timeAgo = _formatTimeAgo(ticket.joinedAt);

    return Dismissible(
      key: ValueKey(ticket.ticketId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.close_rounded, color: const Color(0xFFEF4444), size: 24),
            const SizedBox(height: 4),
            Text('Cancelar',
                style: TextStyle(
                    color: const Color(0xFFEF4444),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      onDismissed: (_) => onCancel(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isFirst
              ? cs.primaryContainer.withValues(alpha: 0.15)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: isFirst
              ? Border.all(color: cs.primary.withValues(alpha: 0.2), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            // Number badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: ticket.priority > 0
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                    : cs.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(displayNum,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: ticket.priority > 0
                          ? const Color(0xFFB45309)
                          : cs.onPrimaryContainer,
                    )),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticket.name ?? 'Sin nombre',
                      style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (ticket.reason != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(ticket.reason!,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurfaceVariant)),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (ticket.partySize > 1) ...[
                        Icon(Icons.people_rounded,
                            size: 12, color: cs.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Text('${ticket.partySize}',
                            style: TextStyle(
                                fontSize: 11, color: cs.onSurfaceVariant)),
                        const SizedBox(width: 6),
                      ],
                      Icon(Icons.access_time_rounded,
                          size: 12, color: cs.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text(timeAgo,
                          style: TextStyle(
                              fontSize: 11, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'cancel') onCancel();
                if (v == 'noshow') onNoShow();
              },
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'cancel',
                  child: Row(children: [
                    Icon(Icons.close_rounded,
                        size: 18, color: const Color(0xFFEF4444)),
                    const SizedBox(width: 10),
                    const Text('Cancelar'),
                  ]),
                ),
                PopupMenuItem(
                  value: 'noshow',
                  child: Row(children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 18, color: const Color(0xFFF59E0B)),
                    const SizedBox(width: 10),
                    const Text('No-show'),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    return '${diff.inHours}h${diff.inMinutes % 60}m';
  }
}
