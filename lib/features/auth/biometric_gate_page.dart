import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/auth/gate_state.dart';
import '../../core/providers.dart';

/// Gate biometrico con fallback a PIN (vedi CLAUDE.md — Step 6). Mostrato
/// dalla redirect di `app_router.dart` ogni volta che `gateNotifierProvider`
/// è `locked`: all'avvio dell'app e dopo 5 minuti in background. Il
/// fallback (biometria assente/non disponibile/annullata) naviga a `/pin`.
class BiometricGatePage extends ConsumerStatefulWidget {
  const BiometricGatePage({super.key});

  @override
  ConsumerState<BiometricGatePage> createState() => _BiometricGatePageState();
}

class _BiometricGatePageState extends ConsumerState<BiometricGatePage> {
  bool _checking = true;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final biometricEnabled = await ref
        .read(secureStoreProvider)
        .readBiometricEnabled();
    if (!mounted) return;
    if (!biometricEnabled) {
      context.go('/pin');
      return;
    }
    setState(() => _checking = false);
    await _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    setState(() => _authenticating = true);
    final biometric = ref.read(biometricServiceProvider);
    final available = await biometric.isAvailable();
    if (!available) {
      if (!mounted) return;
      context.go('/pin');
      return;
    }
    final ok = await biometric.authenticate();
    if (!mounted) return;
    if (ok) {
      ref.read(gateNotifierProvider.notifier).unlock();
      return;
    }
    setState(() => _authenticating = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fingerprint, size: 64),
              const SizedBox(height: 16),
              const Text('Sblocca Diari di Bordo', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              if (_authenticating)
                const CircularProgressIndicator()
              else
                FilledButton(
                  onPressed: _tryBiometric,
                  child: const Text('Riprova'),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/pin'),
                child: const Text('Usa il PIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
