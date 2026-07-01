import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/auth/auth_state.dart';
import 'core/auth/gate_state.dart';
import 'core/models/app_status.dart';
import 'core/models/utente.dart';
import 'core/providers.dart';
import 'core/theme/plancia_theme.dart';
import 'features/auth/biometric_gate_page.dart';
import 'features/auth/biometric_setup_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/pin_setup_page.dart';
import 'features/auth/upgrade_required_page.dart';

void main() {
  runApp(const ProviderScope(child: DiariApp()));
}

class DiariApp extends StatelessWidget {
  const DiariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diari di Bordo',
      theme: PlanciaTheme.light,
      home: const BootstrapPage(),
    );
  }
}

/// Radice della navigazione: verifica prima la versione app (Plancia ≥
/// 2.3.0), poi la sessione, poi il gate biometrico/PIN. Sostituita dai
/// route guard `go_router` allo Step 7 — qui la sequenza è imperativa/
/// reattiva sullo stato dei provider, non essendoci ancora un router.
class BootstrapPage extends ConsumerWidget {
  const BootstrapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStatusAsync = ref.watch(appStatusProvider);
    return appStatusAsync.when(
      loading: () => const _SplashScreen(),
      error: (_, _) => const _AuthGate(appStatus: null),
      data: (status) {
        if (status != null && status.upgradeRequired) {
          return UpgradeRequiredPage(status: status);
        }
        return _AuthGate(appStatus: status);
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _AuthGate extends ConsumerStatefulWidget {
  const _AuthGate({required this.appStatus});

  final AppStatus? appStatus;

  @override
  ConsumerState<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<_AuthGate> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authNotifierProvider.notifier).restore());
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    return switch (auth) {
      AuthInitial() => const _SplashScreen(),
      AuthAuthenticated(:final utente) => _PostAuthGate(utente: utente),
      AuthUnauthenticated() ||
      AuthAwaitingMfa() => LoginPage(appStatus: widget.appStatus),
    };
  }
}

/// Una volta autenticati: primo accesso (setup PIN + biometria) oppure
/// gate normale (se `locked`) oppure home. Reattivo su
/// `pinConfiguredProvider` e `gateNotifierProvider` — il timeout di 5
/// minuti in background rilocca `gateNotifierProvider` e questo widget
/// rimostra automaticamente il gate.
class _PostAuthGate extends ConsumerWidget {
  const _PostAuthGate({required this.utente});

  final Utente utente;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinConfiguredAsync = ref.watch(pinConfiguredProvider);
    return pinConfiguredAsync.when(
      loading: () => const _SplashScreen(),
      error: (_, _) => const _SplashScreen(),
      data: (configured) {
        if (!configured) return const _FirstAccessFlow();
        final gate = ref.watch(gateNotifierProvider);
        return switch (gate) {
          GateStatus.locked => const BiometricGatePage(),
          GateStatus.unlocked => HomePlaceholderPage(utente: utente),
        };
      },
    );
  }
}

/// Primo accesso: PIN obbligatorio, poi scelta biometria (vedi CLAUDE.md —
/// Step 6). Al termine sblocca il gate e va in home.
class _FirstAccessFlow extends ConsumerStatefulWidget {
  const _FirstAccessFlow();

  @override
  ConsumerState<_FirstAccessFlow> createState() => _FirstAccessFlowState();
}

class _FirstAccessFlowState extends ConsumerState<_FirstAccessFlow> {
  bool _pinSet = false;

  @override
  Widget build(BuildContext context) {
    if (!_pinSet) {
      return PinSetupPage(onDone: () => setState(() => _pinSet = true));
    }
    return BiometricSetupPage(
      onDone: () => ref.read(gateNotifierProvider.notifier).unlock(),
    );
  }
}

class HomePlaceholderPage extends ConsumerWidget {
  const HomePlaceholderPage({super.key, required this.utente});

  final Utente utente;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diari di Bordo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Benvenuto, ${utente.nome} ${utente.cognome}\n(${utente.ruoloDisplay})',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
