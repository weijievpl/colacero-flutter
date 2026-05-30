import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../data/local/database.dart';
import '../../../data/local/database_provider.dart';

class WaitPage extends ConsumerStatefulWidget {
  final String ticketId;
  const WaitPage({super.key, required this.ticketId});

  @override
  ConsumerState<WaitPage> createState() => _WaitPageState();
}

class _WaitPageState extends ConsumerState<WaitPage> {
  Ticket? _ticket;
  int _position = 0;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  Future<void> _loadTicket() async {
    final db = ref.read(appDatabaseProvider);
    final ticket = await db.getTicketByTicketId(widget.ticketId);
    if (!mounted || ticket == null) return;

    setState(() => _ticket = ticket);

    _sub = db.watchWaitingTickets().listen((tickets) {
      if (!mounted || _ticket == null) return;
      if (_ticket!.ticketStatus != 0) return; // waiting
      final pos = tickets.where((t) =>
        t.priority > _ticket!.priority ||
        (t.priority == _ticket!.priority && t.joinedAt.isBefore(_ticket!.joinedAt))
      ).length + 1;
      setState(() => _position = pos);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ticket = _ticket;

    if (ticket == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }

    final isServed = ticket.ticketStatus == 2; // served
    final isCancelled = ticket.ticketStatus == 3 || ticket.ticketStatus == 4; // cancelled or noShow
    final displayNum = ticket.number.toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: Text(isServed ? '¡Atendido!' : isCancelled ? 'Cancelado' : 'Tu turno')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            if (isServed) _StatusBanner(icon: Icons.check_circle, text: 'Has sido atendido. ¡Gracias!', color: Colors.green),
            if (isCancelled) _StatusBanner(icon: Icons.warning_amber, text: 'Tu turno ha sido cancelado.', color: Colors.orange),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.2), width: 2)),
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 40), child: Column(children: [
                Text('TU NÚMERO', style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 2, color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Text(displayNum, style: theme.textTheme.displayLarge?.copyWith(fontSize: 96, fontWeight: FontWeight.w800, color: theme.colorScheme.primary, height: 1)),
                if (ticket.partySize > 1) ...[const SizedBox(height: 12), Chip(avatar: Icon(Icons.people, size: 16, color: theme.colorScheme.primary), label: Text('${ticket.partySize} personas'))],
              ])),
            ),
            const SizedBox(height: 16),
            if (ticket.ticketStatus == 0) ...[ // waiting
              Row(children: [
                Expanded(child: _InfoCard(icon: Icons.queue_play_next, label: 'Posición', value: '$_position', color: theme.colorScheme.tertiary)),
                const SizedBox(width: 12),
                Expanded(child: _InfoCard(icon: Icons.access_time, label: 'Espera est.', value: '~${_position * 5} min', color: theme.colorScheme.secondary)),
              ]),
              const SizedBox(height: 16),
            ],
            Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
              QrImageView(data: 'colacero:${ticket.ticketId}:${ticket.number}', version: QrVersions.auto, size: 160, backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.roundedRect, color: Color(0xFF6366F1)),
                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.roundedRect, color: Color(0xFF1E1B4B))),
              const SizedBox(height: 12),
              Text('Escanea para compartir tu estado', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ]))),
            const SizedBox(height: 24),
            OutlinedButton.icon(onPressed: () => context.go('/join'), icon: const Icon(Icons.home_outlined), label: const Text('Volver al inicio'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48))),
          ]),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final MaterialColor color;
  const _StatusBanner({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.shade200)),
      child: Row(children: [Icon(icon, color: color.shade700), const SizedBox(width: 12), Expanded(child: Text(text, style: TextStyle(color: color.shade900, fontWeight: FontWeight.w600)))]));
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(elevation: 0, color: color.withValues(alpha: 0.08), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Icon(icon, color: color), const SizedBox(height: 8),
      Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
    ])));
  }
}
