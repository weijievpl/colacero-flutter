import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import '../../../data/local/database.dart';
import '../../../data/local/database_provider.dart';

class RecoveryPage extends ConsumerStatefulWidget {
  const RecoveryPage({super.key});

  @override
  ConsumerState<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends ConsumerState<RecoveryPage>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String? _error;
  bool _isSearching = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _recover() async {
    setState(() => _error = null);
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();

    if (phone.isEmpty && code.isEmpty) {
      setState(() => _error = 'Ingresa al menos un dato para buscar');
      return;
    }

    setState(() => _isSearching = true);
    HapticFeedback.lightImpact();

    try {
      final db = ref.read(appDatabaseProvider);
      Ticket? ticket;

      if (code.isNotEmpty) {
        // Try exact ticketId match first
        ticket = await db.getTicketByTicketId(code);
        // Try partial match (last N chars)
        if (ticket == null && code.length >= 4) {
          ticket = await db.findTicketByPartialCode(code);
        }
      }

      if (ticket == null && phone.isNotEmpty) {
        ticket = await db.findActiveTicketByPhone(phone);
      }

      if (!mounted) return;

      if (ticket != null) {
        HapticFeedback.mediumImpact();
        context.go('/wait/${ticket.ticketId}');
      } else {
        HapticFeedback.heavyImpact();
        setState(() => _error = 'No se encontró ningún turno activo con esos datos');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Error al buscar: $e');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
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
        title: const Text('Recuperar turno'),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header illustration
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.secondaryContainer,
                        cs.tertiaryContainer.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.onSecondaryContainer.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.search_rounded,
                            size: 36, color: cs.onSecondaryContainer),
                      ),
                      const SizedBox(height: 16),
                      Text('¿Perdiste tu turno?',
                          style: theme.textTheme.headlineSmall?.copyWith(
                              color: cs.onSecondaryContainer)),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Busca por teléfono o código de recuperación para volver a tu lugar en la fila',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSecondaryContainer.withValues(alpha: 0.75)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Phone field
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    hintText: '+54 9 11 ...',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Code field
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Código de turno',
                    hintText: 'Ej: a3f8b2c1d4e6',
                    prefixIcon: Icon(Icons.tag_outlined),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _recover(),
                ),
                const SizedBox(height: 8),

                // Error message
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Color(0xFFEF4444), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(_error!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFFEF4444))),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Search button
                FilledButton.icon(
                  onPressed: _isSearching ? null : _recover,
                  icon: _isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.search_rounded),
                  label: Text(_isSearching ? 'Buscando...' : 'Recuperar turno'),
                ),
                const SizedBox(height: 16),

                // Help text
                Center(
                  child: Text(
                    'El código se muestra en tu pantalla de espera\ny en el QR generado',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
