import 'package:flutter/material.dart';

import '../../core/models/app_status.dart';

/// Banner non bloccante per `upgrade_available` (Plancia ≥ 2.3.0): elenca
/// [AppStatus.funzioniLimitate] senza impedire l'uso dell'app (a differenza
/// di `UpgradeRequiredPage`, che blocca per `upgrade_required`).
class UpgradeBanner extends StatelessWidget {
  const UpgradeBanner({super.key, required this.status, this.onDismiss});

  final AppStatus status;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    if (!status.upgradeAvailable) return const SizedBox.shrink();
    return MaterialBanner(
      content: Text(
        status.funzioniLimitate.isEmpty
            ? status.messaggio
            : '${status.messaggio}\nFunzioni limitate: ${status.funzioniLimitate.join(', ')}',
      ),
      leading: const Icon(Icons.system_update),
      actions: [
        TextButton(onPressed: onDismiss, child: const Text('Ho capito')),
      ],
    );
  }
}
