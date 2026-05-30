import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import '../../../data/local/database.dart';
import '../../../data/local/database_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});
  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  List<Ticket> _waitingTickets = [];
  int _servedToday = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = ref.read(appDatabaseProvider);
    final waiting = await db.watchWaitingTickets().first;
    final history = await db.getHistory(limit: 999);
    final today = DateTime.now();
    final servedToday = history.where((t) =>
      t.ticketStatus == 2 && // served
      t.servedAt != null &&
      t.servedAt!.day == today.day &&
      t.servedAt!.month == today.month
    ).length;

    if (!mounted) return;
    setState(() { _waitingTickets = waiting; _servedToday = servedToday; _isLoading = false; });
  }

  Future<void> _serveNext() async {
    if (await Vibration.hasVibrator() ?? false) Vibration.vibrate(pattern: [50, 30, 50]);
    final db = ref.read(appDatabaseProvider);
    if (_waitingTickets.isEmpty) return;

    final next = _waitingTickets.first;
    await db.updateTicket(TicketsCompanion(
      id: Value(next.id),
      ticketId: Value(next.ticketId),
      number: Value(next.number),
      ticketStatus: const Value(2), // served
      servedAt: Value(DateTime.now()),
      isSynced: const Value(false),
    ));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Turno ${next.number.toString().padLeft(2, '0')} atendido'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
    _loadData();
  }

  Future<void> _updateStatus(Ticket ticket, int statusCode) async {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Admin'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData)]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            Expanded(child: _StatCard(icon: Icons.people_outline, label: 'En cola', value: '${_waitingTickets.length}', color: theme.colorScheme.primary)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(icon: Icons.check_circle_outline, label: 'Hoy', value: '$_servedToday', color: Colors.green)),
          ]),
          const SizedBox(height: 20),
          Row(children: [Text('Cola actual', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), const Spacer(), if (_waitingTickets.isNotEmpty) Chip(label: Text('${_waitingTickets.length} esperando'), visualDensity: VisualDensity.compact)]),
          const SizedBox(height: 12),
          if (_waitingTickets.isEmpty)
            Card(child: Padding(padding: const EdgeInsets.all(32), child: Center(child: Column(children: [Icon(Icons.inbox_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)), const SizedBox(height: 12), Text('No hay turnos en espera', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant))]))))
          else
            ..._waitingTickets.map((ticket) => Dismissible(
              key: ValueKey(ticket.ticketId), direction: DismissDirection.endToStart,
              background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.close, color: Colors.red.shade700), Text('Cancelar', style: TextStyle(color: Colors.red.shade700, fontSize: 12))])),
              onDismissed: (_) => _updateStatus(ticket, 3), // cancelled
              child: Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
                leading: CircleAvatar(backgroundColor: ticket.priority > 0 ? Colors.orange.shade100 : theme.colorScheme.primaryContainer,
                  child: Text(ticket.number.toString().padLeft(2, '0'), style: TextStyle(fontWeight: FontWeight.bold, color: ticket.priority > 0 ? Colors.orange.shade900 : theme.colorScheme.onPrimaryContainer))),
                title: Text(ticket.name ?? 'Sin nombre'),
                subtitle: Row(children: [if (ticket.reason != null) Container(margin: const EdgeInsets.only(right: 6), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)), child: Text(ticket.reason!, style: const TextStyle(fontSize: 10))), if (ticket.partySize > 1) Text('👥 ${ticket.partySize}', style: const TextStyle(fontSize: 11))]),
                trailing: PopupMenuButton<String>(onSelected: (v) { if (v == 'cancel') _updateStatus(ticket, 3); if (v == 'noshow') _updateStatus(ticket, 4); },
                  itemBuilder: (_) => [const PopupMenuItem(value: 'cancel', child: Text('❌ Cancelar')), const PopupMenuItem(value: 'noshow', child: Text('⚠️ No-show'))]),
              )),
            )),
          const SizedBox(height: 80),
        ]),
      ),
      floatingActionButton: _waitingTickets.isNotEmpty ? FloatingActionButton.extended(onPressed: _serveNext, icon: const Icon(Icons.call_made), label: const Text('Llamar siguiente')) : null,
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String label; final String value; final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(elevation: 0, color: color.withValues(alpha: 0.08), child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Icon(icon, color: color, size: 28), const SizedBox(height: 8),
      Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: color)),
      Text(label, style: TextStyle(fontSize: 13, color: color.withValues(alpha: 0.8))),
    ])));
  }
}
