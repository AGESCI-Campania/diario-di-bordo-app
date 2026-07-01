import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/auth/auth_state.dart';
import 'core/navigation/app_router.dart';
import 'core/providers.dart';
import 'core/theme/plancia_theme.dart';
import 'features/auth/upgrade_required_page.dart';

void main() {
  runApp(const ProviderScope(child: DiariApp()));
}

/// Radice dell'app: la navigazione (login, MFA, gate biometrico/PIN,
/// sezioni protette) è delegata a `routerProvider` (vedi TODO.md — Step 7).
/// Resta qui solo il controllo di versione (Plancia ≥ 2.3.0, Step 6): un
/// `upgrade_required` sostituisce l'intero contenuto con la pagina di
/// blocco, prima ancora che il router venga mostrato.
class DiariApp extends ConsumerStatefulWidget {
  const DiariApp({super.key});

  @override
  ConsumerState<DiariApp> createState() => _DiariAppState();
}

class _DiariAppState extends ConsumerState<DiariApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authNotifierProvider.notifier).restore());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Diari di Bordo',
      theme: PlanciaTheme.light,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        final appStatusAsync = ref.watch(appStatusProvider);
        return appStatusAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => child!,
          data: (status) {
            if (status != null && status.upgradeRequired) {
              return UpgradeRequiredPage(status: status);
            }
            return child!;
          },
        );
      },
    );
  }
}
