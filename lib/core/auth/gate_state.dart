import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Il gate biometrico/PIN che precede la visualizzazione di qualunque dato
/// (vedi CLAUDE.md — Autenticazione).
enum GateStatus { locked, unlocked }

/// Traccia se il gate va mostrato: sempre `locked` all'avvio di un nuovo
/// [ProviderContainer] (avvio app) o subito dopo un login riuscito
/// (`AuthNotifier` chiama [lock] esplicitamente), e si rilocca da solo se
/// l'app resta in background più di 5 minuti.
class GateNotifier extends Notifier<GateStatus> {
  static const backgroundTimeout = Duration(minutes: 5);

  AppLifecycleListener? _lifecycleListener;
  DateTime? _pausedAt;

  @override
  GateStatus build() {
    _lifecycleListener = AppLifecycleListener(
      onPause: () => _pausedAt = DateTime.now(),
      onResume: _onResume,
    );
    ref.onDispose(() => _lifecycleListener?.dispose());
    return GateStatus.locked;
  }

  void _onResume() {
    final pausedAt = _pausedAt;
    _pausedAt = null;
    if (pausedAt != null &&
        DateTime.now().difference(pausedAt) > backgroundTimeout) {
      state = GateStatus.locked;
    }
  }

  void lock() => state = GateStatus.locked;

  void unlock() => state = GateStatus.unlocked;
}

final gateNotifierProvider = NotifierProvider<GateNotifier, GateStatus>(
  GateNotifier.new,
);
