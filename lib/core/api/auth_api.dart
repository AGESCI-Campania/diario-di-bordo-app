import 'package:dio/dio.dart';

import 'api_client.dart';

/// Esito di una chiamata allauth headless app-mode (login, MFA).
///
/// Vedi CLAUDE.md — Autenticazione: se [isAuthenticated] è `false` dopo il
/// login, l'utente ha MFA attivo e va reindirizzato a `MfaPage` passando
/// [sessionToken] (provvisorio) come header nella chiamata successiva.
class AuthResult {
  const AuthResult({
    required this.statusCode,
    required this.isAuthenticated,
    required this.sessionToken,
    required this.data,
    required this.errors,
  });

  factory AuthResult.fromResponse(Response response) {
    final body = response.data as Map<String, dynamic>;
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    final rawErrors = body['errors'] as List?;
    return AuthResult(
      statusCode: response.statusCode ?? 0,
      isAuthenticated: meta['is_authenticated'] == true,
      sessionToken: meta['session_token'] as String?,
      data: body['data'] as Map<String, dynamic>? ?? const {},
      errors: rawErrors == null
          ? const []
          : rawErrors
                .map((e) => (e as Map)['message'] as String? ?? 'Errore')
                .toList(),
    );
  }

  final int statusCode;
  final bool isAuthenticated;
  final String? sessionToken;

  /// Corpo `data` della risposta allauth (es. `user`, `flows`).
  final Map<String, dynamic> data;

  /// Messaggi di errore allauth (es. credenziali non valide, codice MFA
  /// errato) — `body['errors']`, presenti tipicamente su risposta `400`.
  final List<String> errors;

  /// `true` se il login richiede un secondo fattore: `is_authenticated` è
  /// `false` e tra i `data.flows` è presente `mfa_authenticate` (vedi
  /// CLAUDE.md — Autenticazione, sezione MFA).
  bool get requiresMfa {
    if (isAuthenticated) return false;
    final flows = data['flows'] as List?;
    return flows?.any((f) => f is Map && f['id'] == 'mfa_authenticate') ??
        false;
  }
}

/// Login app-mode di django-allauth headless (`/_allauth/app/v1/*`).
///
/// Non usare mai `/_allauth/browser/*` (browser-mode) — vedi CLAUDE.md,
/// "Cosa NON fare".
class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.authDio.post(
      '/_allauth/app/v1/auth/login',
      data: {'login': email, 'password': password},
    );
    return AuthResult.fromResponse(response);
  }

  Future<AuthResult> authenticateMfa(String code) async {
    final response = await _client.authDio.post(
      '/_allauth/app/v1/auth/2fa/authenticate',
      data: {'code': code},
    );
    return AuthResult.fromResponse(response);
  }

  Future<void> logout() =>
      _client.authDio.delete('/_allauth/app/v1/auth/session');
}
