import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../api/auth_api.dart';
import '../models/utente.dart';
import '../providers.dart';
import 'gate_state.dart';

/// Stato applicativo di autenticazione.
///
/// Non descrive il gate biometrico/PIN: un [AuthAuthenticated] con
/// [GateStatus.locked] (vedi `gate_state.dart`) ha comunque una sessione
/// valida, ma l'UI non deve mostrare alcun dato finché il gate non è
/// superato (vedi CLAUDE.md — Autenticazione).
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Login riuscito ma in attesa del codice TOTP (`MfaPage`).
class AuthAwaitingMfa extends AuthState {
  const AuthAwaitingMfa();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.utente);

  final Utente utente;
}

class AuthNotifier extends Notifier<AuthState> {
  late final _service = ref.watch(authServiceProvider);

  @override
  AuthState build() {
    // Un 401 inaspettato pulisce la sessione locale (vedi
    // `apiClientProvider.onUnauthorized`); qui si riflette il cambiamento
    // nello stato applicativo così l'UI torna al login.
    ref.listen(sessionInvalidatedProvider, (previous, next) {
      if (previous != null && next != previous) {
        state = const AuthUnauthenticated();
      }
    });
    return const AuthInitial();
  }

  /// Da chiamare all'avvio dell'app: se un token è già salvato prova a
  /// risolverlo con `GET /me`; un token non più valido viene scartato in
  /// silenzio (l'utente rivede semplicemente la `LoginPage`).
  Future<void> restore() async {
    if (!await _service.hasSession()) {
      state = const AuthUnauthenticated();
      return;
    }
    try {
      final utente = await _service.fetchCurrentUser();
      ref.read(gateNotifierProvider.notifier).lock();
      state = AuthAuthenticated(utente);
    } catch (_) {
      await _service.forceLogout();
      state = const AuthUnauthenticated();
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final result = await _service.login(email: email, password: password);
    if (result.isAuthenticated) {
      final utente = await _service.fetchCurrentUser();
      ref.read(gateNotifierProvider.notifier).lock();
      state = AuthAuthenticated(utente);
    } else if (result.requiresMfa) {
      state = const AuthAwaitingMfa();
    }
    return result;
  }

  Future<AuthResult> authenticateMfa(String code) async {
    final result = await _service.authenticateMfa(code);
    if (result.isAuthenticated) {
      final utente = await _service.fetchCurrentUser();
      ref.read(gateNotifierProvider.notifier).lock();
      state = AuthAuthenticated(utente);
    }
    return result;
  }

  Future<void> logout() async {
    await _service.logout();
    // Il logout cancella anche PIN e preferenza biometrica (vedi
    // `AuthService.logout`): il prossimo login deve rifare il primo
    // accesso, quindi si invalida la cache di `pinConfiguredProvider`.
    ref.invalidate(pinConfiguredProvider);
    ref.read(gateNotifierProvider.notifier).lock();
    state = const AuthUnauthenticated();
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
