import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/auth/pin_service.dart';
import '../../core/providers.dart';

/// Setup del PIN a 6 cifre al primo accesso (vedi CLAUDE.md — Step 6):
/// richiede il PIN due volte e lo salva solo se coincidono. Chiama
/// [onDone] al termine — il chiamante (`FirstAccessPage`) decide il passo
/// successivo (`BiometricSetupPage`).
class PinSetupPage extends ConsumerStatefulWidget {
  const PinSetupPage({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends ConsumerState<PinSetupPage> {
  String? _firstPin;
  final _pinController = TextEditingController();
  String? _errorText;
  bool _isSaving = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  bool get _isConfirming => _firstPin != null;

  Future<void> _onSubmitted(String value) async {
    if (value.length != PinService.pinLength) return;
    if (!_isConfirming) {
      setState(() {
        _firstPin = value;
        _pinController.clear();
      });
      return;
    }
    if (value != _firstPin) {
      setState(() {
        _errorText = 'I PIN non coincidono, riprova';
        _firstPin = null;
        _pinController.clear();
      });
      return;
    }
    setState(() => _isSaving = true);
    await ref.read(pinServiceProvider).setPin(value);
    ref.read(pinConfiguredProvider.notifier).markConfigured();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Imposta un PIN')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isConfirming
                      ? 'Conferma il PIN'
                      : 'Scegli un PIN a ${PinService.pinLength} cifre',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ti verrà richiesto per accedere ai dati dei diari.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_isSaving)
                  const CircularProgressIndicator()
                else
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: PinService.pinLength,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(counterText: ''),
                    onChanged: (value) {
                      if (_errorText != null) setState(() => _errorText = null);
                      if (value.length == PinService.pinLength) {
                        _onSubmitted(value);
                      }
                    },
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
