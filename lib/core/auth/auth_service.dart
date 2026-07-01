import '../api/auth_api.dart';
import '../api/me_api.dart';
import '../models/utente.dart';
import 'secure_store.dart';

/// Orchestrazione di login/MFA/logout e della sessione (`X-Session-Token`).
///
/// Il token — sia quello provvisorio pre-MFA sia quello di sessione piena —
/// è sempre scritto in [SecureStore]: in entrambi i casi serve nell'header
/// `X-Session-Token` della richiesta successiva (login → 2FA, vedi
/// CLAUDE.md — Autenticazione). Lo stato applicativo passa ad "autenticato"
/// solo dopo che `GET /me` è stato risolto con successo.
class AuthService {
  AuthService({
    required AuthApi authApi,
    required MeApi meApi,
    required SecureStore store,
  }) : _authApi = authApi,
       _meApi = meApi,
       _store = store;

  final AuthApi _authApi;
  final MeApi _meApi;
  final SecureStore _store;

  Future<bool> hasSession() async => await _store.readSessionToken() != null;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final result = await _authApi.login(email: email, password: password);
    if (result.sessionToken != null) {
      await _store.writeSessionToken(result.sessionToken!);
    }
    return result;
  }

  Future<AuthResult> authenticateMfa(String code) async {
    final result = await _authApi.authenticateMfa(code);
    if (result.sessionToken != null) {
      await _store.writeSessionToken(result.sessionToken!);
    }
    return result;
  }

  Future<Utente> fetchCurrentUser() async {
    final json = await _meApi.getMe();
    return Utente.fromJson(json);
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (_) {
      // best-effort: la sessione locale va comunque ripulita
    }
    await _store.clearAll();
  }

  /// Invocato dall'interceptor su `401` inaspettato (vedi CLAUDE.md —
  /// tabella "Gestione errori API"): la sessione lato server è già
  /// invalida. A differenza di [logout], non tocca PIN/preferenza
  /// biometrica — sono legati al device, non alla sessione scaduta, e
  /// l'utente non deve doverli riconfigurare al prossimo login.
  Future<void> forceLogout() => _store.deleteSessionToken();
}
