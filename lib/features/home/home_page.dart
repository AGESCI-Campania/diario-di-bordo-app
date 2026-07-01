import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/auth/auth_state.dart';

/// Home post-autenticazione: benvenuto e accesso alle sezioni protette
/// (vedi TODO.md — Step 7). Le destinazioni sono ancora segnaposto finché
/// non vengono realizzate negli Step 8–10.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final utente = auth is AuthAuthenticated ? auth.utente : null;
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
      body: Column(
        children: [
          if (utente != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Benvenuto, ${utente.nome} ${utente.cognome}\n(${utente.ruoloDisplay})',
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: const Text('Diari'),
                  onTap: () => context.push('/diari'),
                ),
                ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('Edizioni'),
                  onTap: () => context.push('/edizioni'),
                ),
                ListTile(
                  leading: const Icon(Icons.account_tree),
                  title: const Text('Organizzazione'),
                  onTap: () => context.push('/org'),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profilo'),
                  onTap: () => context.push('/profilo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
