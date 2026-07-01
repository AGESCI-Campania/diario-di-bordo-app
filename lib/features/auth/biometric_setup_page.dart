import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';

/// Chiede se abilitare FaceID/TouchID/Fingerprint subito dopo il setup del
/// PIN (vedi CLAUDE.md — Step 6). Se rifiutata, o se il device non ha
/// biometria disponibile, il PIN resta l'unico metodo del gate. Chiama
/// [onDone] in ogni caso al termine.
class BiometricSetupPage extends ConsumerStatefulWidget {
  const BiometricSetupPage({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  ConsumerState<BiometricSetupPage> createState() => _BiometricSetupPageState();
}

class _BiometricSetupPageState extends ConsumerState<BiometricSetupPage> {
  bool _checking = true;
  bool _available = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    final available = await ref.read(biometricServiceProvider).isAvailable();
    if (!mounted) return;
    if (!available) {
      // Nessuna biometria sul device: si salta la scelta, PIN obbligatorio.
      await ref.read(secureStoreProvider).writeBiometricEnabled(false);
      widget.onDone();
      return;
    }
    setState(() {
      _available = available;
      _checking = false;
    });
  }

  Future<void> _choose(bool enable) async {
    setState(() => _isSaving = true);
    if (enable) {
      final ok = await ref
          .read(biometricServiceProvider)
          .authenticate(reason: 'Conferma per abilitare lo sblocco rapido');
      enable = ok;
    }
    await ref.read(secureStoreProvider).writeBiometricEnabled(enable);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    if (_checking || !_available) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Sblocco rapido')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fingerprint, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Vuoi abilitare Face ID / Touch ID per sbloccare più velocemente?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Potrai sempre usare il PIN come alternativa.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_isSaving)
                  const CircularProgressIndicator()
                else ...[
                  FilledButton(
                    onPressed: () => _choose(true),
                    child: const Text('Abilita'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _choose(false),
                    child: const Text('No, usa solo il PIN'),
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
