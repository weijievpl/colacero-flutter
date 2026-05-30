import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:drift/drift.dart' show Value;
import '../../../data/local/database.dart';
import '../../../data/local/database_provider.dart';

class WaitPage extends ConsumerStatefulWidget {
  final String ticketId;
  const WaitPage({super.key, required this.ticketId});

  @override
  ConsumerState<WaitPage> createState() => _WaitPageState();
}

class _WaitPageState extends ConsumerState<WaitPage>
    with TickerProviderStateMixin {
  Ticket? _ticket;
  int _position = 0;
  StreamSubscription? _sub;
  late AnimationController _numberAnimCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _numberScale;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _numberAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _numberScale = CurvedAnimation(
      parent: _numberAnimCtrl,
      curve: Curves.elasticOut,
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _loadTicket();
  }

  Future<void> _loadTicket() async {
    final db = ref.read(appDatabaseProvider);
    final ticket = await db.getTicketByTicketId(widget.ticketId);
    if (!mounted || ticket == null) return;

    setState(() => _ticket = ticket);
    _numberAnimCtrl.forward();

    _sub = db.watchWaitingTickets().listen((tickets) {
      if (!mounted || _ticket == null) return;
      if (_ticket!.ticketStatus != 0) return;
      final pos = tickets.where((t) =>
        t.priority > _ticket!.priority ||
        (t.priority == _ticket!.priority && t.joinedAt.isBefore(_ticket!.joinedAt))
      ).length + 1;
      if (pos != _position) {
        HapticFeedback.selectionClick();
        setState(() => _position = pos);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _numberAnimCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final ticket = _ticket;

    if (ticket == null) {
      return Scaffold(
        body: Container(
          color: cs.surface,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: cs.primary),
                const SizedBox(height: 16),
                Text('Cargando tu turno...', style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      );
    }

    final isServed = ticket.ticketStatus == 2;
    final isCancelled = ticket.ticketStatus == 3 || ticket.ticketStatus == 4;
    final displayNum = ticket.number.toString().padLeft(2, '0');

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Immersive Header ──
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 32,
                  left: 24,
                  right: 24,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isServed
                        ? [const Color(0xFF065F46), const Color(0xFF10B981)]
                        : isCancelled
                            ? [const Color(0xFF7C2D12), const Color(0xFFF97316)]
                            : [cs.primary, cs.primary.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // Status indicator
                    if (isServed)
                      _AnimatedStatusChip(
                        icon: Icons.check_circle_rounded,
                        label: '¡Atendido!',
                        color: Colors.white,
                      )
                    else if (isCancelled)
                      _AnimatedStatusChip(
                        icon: Icons.warning_amber_rounded,
                        label: 'Cancelado',
                        color: Colors.white,
                      )
                    else
                      _AnimatedStatusChip(
                        icon: Icons.hourglass_bottom_rounded,
                        label: 'Esperando',
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    const SizedBox(height: 24),

                    // Big number with elastic animation
                    ScaleTransition(
                      scale: _numberScale,
                      child: Text(
                        displayNum,
                        style: GoogleFonts.inter(
                          fontSize: 120,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -4,
                          height: 1.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'TU NÚMERO',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    if (ticket.partySize > 1) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text('${ticket.partySize} personas',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Content Cards ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Position & ETA cards
                  if (ticket.ticketStatus == 0) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.queue_play_next_rounded,
                            label: 'Posición',
                            value: '$_position',
                            subtitle: _position == 1 ? '¡Eres el siguiente!' : '${_position - 1} antes de ti',
                            color: cs.tertiary,
                            highlight: _position <= 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.access_time_filled_rounded,
                            label: 'Espera est.',
                            value: '~${_position * 5}',
                            subtitle: 'minutos',
                            color: cs.secondary,
                            highlight: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // QR Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    color: cs.surfaceContainerLow,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: QrImageView(
                              data: 'colacero:${ticket.ticketId}:${ticket.number}',
                              version: QrVersions.auto,
                              size: 180,
                              backgroundColor: Colors.white,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.roundOuter,
                                color: Color(0xFF4F46E5),
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.roundOuter,
                                color: Color(0xFF1E1B4B),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Escanea para compartir tu estado',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Back button
                  OutlinedButton.icon(
                    onPressed: () => context.go('/join'),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Volver al inicio'),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedStatusChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _AnimatedStatusChip({required this.icon, required this.label, required this.color});

  @override
  State<_AnimatedStatusChip> createState() => _AnimatedStatusChipState();
}

class _AnimatedStatusChipState extends State<_AnimatedStatusChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 16, color: widget.color),
            const SizedBox(width: 8),
            Text(widget.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: widget.color,
                )),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final bool highlight;
  const _MetricCard({
    required this.icon, required this.label, required this.value,
    required this.subtitle, required this.color, required this.highlight,
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
          offset: Offset(0, 20 * (1 - val)),
          child: Opacity(opacity: val, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: highlight
              ? color.withValues(alpha: 0.12)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: highlight
              ? Border.all(color: color.withValues(alpha: 0.3), width: 1.5)
              : null,
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
            const SizedBox(height: 12),
            Text(value,
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.0,
                )),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.5,
                )),
            const SizedBox(height: 2),
            Text(subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                )),
          ],
        ),
      ),
    );
  }
}
