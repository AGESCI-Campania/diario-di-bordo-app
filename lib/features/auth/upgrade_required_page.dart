import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/models/app_status.dart';
import '../../core/providers.dart';

/// Pagina di blocco per `upgrade_required` (Plancia ≥ 2.3.0, HTTP 426):
/// nessun accesso all'app finché la versione installata non è aggiornata
/// (vedi CLAUDE.md — Version gate).
class UpgradeRequiredPage extends ConsumerWidget {
  const UpgradeRequiredPage({super.key, required this.status});

  final AppStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.system_update, size: 64),
                const SizedBox(height: 16),
                Text(
                  "Aggiorna l'app",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(status.messaggio, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Versione minima richiesta: ${status.versioneMinima}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => ref.invalidate(appStatusProvider),
                  child: const Text('Riprova'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
