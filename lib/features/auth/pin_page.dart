import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/auth/gate_state.dart';
import '../../core/auth/pin_service.dart';
import '../../core/providers.dart';

/// Fallback del gate biometrico (vedi CLAUDE.md — Step 6): verifica il PIN
/// contro l'hash salvato e, se corretto, sblocca il gate direttamente —
/// `_PostAuthGate` in `main.dart` osserva `gateNotifierProvider` e mostra
/// la home reattivamente, senza bisogno di navigazione esplicita qui.
class PinPage extends ConsumerStatefulWidget {
  const PinPage({super.key, this.onCancel});

  /// Se non nullo, mostra un'azione per tornare alla schermata biometrica
  /// (usato quando questa pagina è incorporata come fallback in
  /// `BiometricGatePage`).
  final VoidCallback? onCancel;

  @override
  ConsumerState<PinPage> createState() => _PinPageState();
}

class _PinPageState extends ConsumerState<PinPage> {
  final _pinController = TextEditingController();
  String? _errorText;
  bool _isVerifying = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _onChanged(String value) async {
    if (_errorText != null) setState(() => _errorText = null);
    if (value.length != PinService.pinLength) return;
    setState(() => _isVerifying = true);
    final ok = await ref.read(pinServiceProvider).verifyPin(value);
    if (!mounted) return;
    if (ok) {
      ref.read(gateNotifierProvider.notifier).unlock();
      return;
    }
    setState(() {
      _isVerifying = false;
      _errorText = 'PIN errato';
      _pinController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.onCancel != null
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onCancel,
              ),
            )
          : null,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48),
                const SizedBox(height: 16),
                const Text('Inserisci il PIN', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                if (_isVerifying)
                  const CircularProgressIndicator()
                else
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    autofocus: true,
                    maxLength: PinService.pinLength,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(counterText: ''),
                    onChanged: _onChanged,
                  ),
                if (_errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
