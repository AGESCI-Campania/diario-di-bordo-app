import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/biometric_gate_page.dart';
import '../../features/auth/first_access_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/mfa_page.dart';
import '../../features/auth/pin_page.dart';
import '../../features/home/home_page.dart';
import '../../shared/widgets/placeholder_page.dart';
import '../auth/auth_state.dart';
import '../auth/gate_state.dart';
import '../providers.dart';

const splashLocation = '/';

/// Ponte fra i provider Riverpod che determinano la destinazione (sessione,
/// PIN, gate) e `GoRouter.refreshListenable`, che si aspetta un
/// `Listenable` classico.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authNotifierProvider, (_, _) => notifyListeners());
    ref.listen(gateNotifierProvider, (_, _) => notifyListeners());
    ref.listen(pinConfiguredProvider, (_, _) => notifyListeners());
  }
}

/// `authGuard` + `biometricGuard` (vedi TODO.md — Step 7): nessun token →
/// `/login`; MFA in sospeso → `/mfa`; primo accesso senza PIN → `/pin-setup`;
/// token presente ma gate non superato → `/gate`. Il controllo di versione
/// app (`upgrade_required`, Step 6) resta fuori dal router — è gestito a
/// monte, in `DiariApp.builder` (`main.dart`).
String? _redirect(Ref ref, String location) {
  final auth = ref.read(authNotifierProvider);

  if (auth is AuthInitial) {
    return location == splashLocation ? null : splashLocation;
  }
  if (auth is AuthUnauthenticated) {
    return location == '/login' ? null : '/login';
  }
  if (auth is AuthAwaitingMfa) {
    return location == '/mfa' ? null : '/mfa';
  }

  // Da qui in poi: AuthAuthenticated.
  final pinConfigured = ref.read(pinConfiguredProvider).value;
  if (pinConfigured == null) {
    return null; // ancora in lettura da flutter_secure_storage
  }
  if (!pinConfigured) {
    return location == '/pin-setup' ? null : '/pin-setup';
  }

  if (ref.read(gateNotifierProvider) == GateStatus.locked) {
    const gateRoutes = {'/gate', '/pin'};
    return gateRoutes.contains(location) ? null : '/gate';
  }

  const authOnlyRoutes = {
    splashLocation,
    '/login',
    '/mfa',
    '/gate',
    '/pin',
    '/pin-setup',
  };
  return authOnlyRoutes.contains(location) ? '/home' : null;
}

/// Router applicativo (vedi TODO.md — Step 7): sostituisce la navigazione
/// imperativa dello Step 6 (`BootstrapPage`/`_AuthGate` in `main.dart`).
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: splashLocation,
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(ref, state.matchedLocation),
    routes: [
      GoRoute(
        path: splashLocation,
        builder: (context, state) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/mfa', builder: (context, state) => const MfaPage()),
      GoRoute(
        path: '/gate',
        builder: (context, state) => const BiometricGatePage(),
      ),
      GoRoute(path: '/pin', builder: (context, state) => const PinPage()),
      GoRoute(
        path: '/pin-setup',
        builder: (context, state) => const FirstAccessPage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/diari',
        builder: (context, state) => const PlaceholderPage(title: 'Diari'),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => PlaceholderPage(
              title: 'Diario',
              subtitle: 'id: ${state.pathParameters['id']}',
            ),
            routes: [
              GoRoute(
                path: 'modulo/:n',
                builder: (context, state) => PlaceholderPage(
                  title: 'Modulo',
                  subtitle:
                      'diario: ${state.pathParameters['id']} · '
                      'modulo: ${state.pathParameters['n']}',
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/edizioni',
        builder: (context, state) => const PlaceholderPage(title: 'Edizioni'),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => PlaceholderPage(
              title: 'Edizione',
              subtitle: 'id: ${state.pathParameters['id']}',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/org',
        builder: (context, state) =>
            const PlaceholderPage(title: 'Organizzazione'),
      ),
      GoRoute(
        path: '/profilo',
        builder: (context, state) => const PlaceholderPage(title: 'Profilo'),
      ),
    ],
  );
});
