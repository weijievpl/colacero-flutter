import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import '../../data/local/database.dart';
import '../../data/local/database_provider.dart';

/// Operator PIN Login Gate
/// Wraps admin pages with PIN authentication
class OperatorPinGate extends ConsumerStatefulWidget {
  final Widget child;
  const OperatorPinGate({super.key, required this.child});

  @override
  ConsumerState<OperatorPinGate> createState() => _OperatorPinGateState();
}

// Provider for current operator session
final operatorSessionProvider = StateProvider<String?>((ref) => null);

class _OperatorPinGateState extends ConsumerState<OperatorPinGate>
    with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  bool _isAuthenticated = false;
  String? _error;
  int _attempts = 0;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  // Default PINs (in production, store hashed in DB)
  static const _validPins = ['1234', '0000', '1111'];

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 10, end: -5), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -5, end: 0), weight: 25),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    // Check if already authenticated in this session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(operatorSessionProvider);
      if (session != null) {
        setState(() => _isAuthenticated = true);
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitPin() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      setState(() => _error = 'El PIN debe tener 4 dígitos');
      return;
    }

    HapticFeedback.lightImpact();

    if (_validPins.contains(pin)) {
      // Success
      HapticFeedback.mediumImpact();
      final operatorId = 'operator_${DateTime.now().millisecondsSinceEpoch}';
      ref.read(operatorSessionProvider.notifier).state = operatorId;
      setState(() {
        _isAuthenticated = true;
        _error = null;
        _attempts = 0;
      });

      // Log audit event
      final db = ref.read(appDatabaseProvider);
      await db.insertAuditEvent(AuditEventsCompanion(
        eventType: Value('operator_login'),
        operatorId: Value(operatorId),
      ));
    } else {
      // Failed
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0);
      setState(() {
        _attempts++;
        _error = _attempts >= 3
            ? 'Demasiados intentos. Espera un momento.'
            : 'PIN incorrecto';
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) return widget.child;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _shakeAnim,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnim.value, 0),
                child: child,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lock icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_outline_rounded,
                        size: 48, color: cs.onPrimaryContainer),
                  ),
                  const SizedBox(height: 24),
                  Text('Acceso de operador',
                      style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Ingresa tu PIN para acceder al panel',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant)),
                  const SizedBox(height: 32),

                  // PIN input
                  TextField(
                    controller: _pinController,
                    decoration: InputDecoration(
                      labelText: 'PIN',
                      hintText: '••••',
                      prefixIcon: const Icon(Icons.dialpad_outlined),
                      errorText: _error,
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    onSubmitted: (_) => _submitPin(),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  FilledButton.icon(
                    onPressed: _attempts >= 3 ? null : _submitPin,
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Ingresar'),
                  ),
                  const SizedBox(height: 16),

                  // Back link
                  TextButton(
                    onPressed: () => context.go('/join'),
                    child: const Text('Volver al inicio'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
