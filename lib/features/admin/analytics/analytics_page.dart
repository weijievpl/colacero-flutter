import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/local/database.dart';
import '../../../data/local/database_provider.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _loadStats();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final db = ref.read(appDatabaseProvider);
    final stats = await db.getTodayStats();
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
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
        title: const Text('Análisis del día'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: cs.primary))
            : FadeTransition(
                opacity: _fadeAnim,
                child: RefreshIndicator(
                  onRefresh: _loadStats,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Summary card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cs.primaryContainer, cs.secondaryContainer.withValues(alpha: 0.7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.insights_rounded, size: 36, color: cs.onPrimaryContainer),
                              const SizedBox(height: 12),
                              Text('Resumen de hoy',
                                  style: theme.textTheme.titleLarge?.copyWith(color: cs.onPrimaryContainer)),
                              const SizedBox(height: 8),
                              Text(_generateSummary(),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onPrimaryContainer.withValues(alpha: 0.85),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Stats grid
                        Row(children: [
                          Expanded(child: _StatTile(
                            icon: Icons.confirmation_number_outlined,
                            label: 'Creados',
                            value: '${_stats?['totalCreated'] ?? 0}',
                            color: cs.primary,
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _StatTile(
                            icon: Icons.check_circle_outline_rounded,
                            label: 'Atendidos',
                            value: '${_stats?['served'] ?? 0}',
                            color: const Color(0xFF10B981),
                          )),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _StatTile(
                            icon: Icons.hourglass_bottom_outlined,
                            label: 'Esperando',
                            value: '${_stats?['waiting'] ?? 0}',
                            color: const Color(0xFFF59E0B),
                          )),
                          const SizedBox(width: 12),
                          Expanded(child: _StatTile(
                            icon: Icons.person_off_outlined,
                            label: 'No-show',
                            value: '${_stats?['noShows'] ?? 0}',
                            color: const Color(0xFFEF4444),
                          )),
                        ]),
                        const SizedBox(height: 12),

                        // Avg wait time — full width
                        _StatTile(
                          icon: Icons.timer_outlined,
                          label: 'Espera promedio',
                          value: '${_stats?['avgWaitMinutes'] ?? 0} min',
                          color: cs.tertiary,
                        ),
                        const SizedBox(height: 24),

                        // Simple bar chart
                        Text('Distribución de estados', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: (_stats?['totalCreated'] ?? 1).toDouble().clamp(1, double.infinity),
                              barGroups: [
                                _makeBar(0, (_stats?['served'] ?? 0).toDouble(), const Color(0xFF10B981), 'Serv'),
                                _makeBar(1, (_stats?['waiting'] ?? 0).toDouble(), const Color(0xFFF59E0B), 'Esp'),
                                _makeBar(2, (_stats?['noShows'] ?? 0).toDouble(), const Color(0xFFEF4444), 'NS'),
                              ],
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const labels = ['Serv', 'Esp', 'NS'];
                                      final idx = value.toInt();
                                      if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(labels[idx],
                                            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Back button
                        OutlinedButton.icon(
                          onPressed: () => context.go('/dashboard'),
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Volver al panel'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  String _generateSummary() {
    if (_stats == null) return 'Cargando datos...';
    final total = _stats!['totalCreated'] as int;
    final served = _stats!['served'] as int;
    final waiting = _stats!['waiting'] as int;
    final avgWait = _stats!['avgWaitMinutes'] as int;

    if (total == 0) return 'Aún no se han creado turnos hoy.';
    if (waiting == 0 && served > 0) return '¡Excelente! Todos los turnos de hoy han sido atendidos. $served clientes servidos con una espera promedio de $avgWait min.';
    if (served == 0) return '$total personas esperan ser atendidas. El equipo aún no ha comenzado a llamar turnos.';
    return 'Hoy se crearon $total turnos. $served ya fueron atendidos y $waiting están en espera. Tiempo promedio de atención: $avgWait minutos.';
  }

  BarChartGroupData _makeBar(int x, double y, Color color, String label) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 32,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatTile({required this.icon, required this.label, required this.value, required this.color});

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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: TextStyle(
                        fontSize: 28,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
