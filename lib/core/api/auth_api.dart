import 'package:dio/dio.dart';

import 'api_client.dart';

/// Esito di una chiamata allauth headless app-mode (login, MFA).
///
/// Vedi CLAUDE.md — Autenticazione: se [isAuthenticated] è `false` dopo il
/// login, l'utente ha MFA attivo e va reindirizzato a `MfaPage` passando
/// [sessionToken] (provvisorio) come header nella chiamata successiva.
class AuthResult {
  const AuthResult({
    required this.isAuthenticated,
    required this.sessionToken,
    required this.data,
  });

  factory AuthResult.fromResponse(Response response) {
    final body = response.data as Map<String, dynamic>;
    final meta = body['meta'] as Map<String, dynamic>? ?? const {};
    return AuthResult(
      isAuthenticated: meta['is_authenticated'] == true,
      sessionToken: meta['session_token'] as String?,
      data: body['data'] as Map<String, dynamic>? ?? const {},
    );
  }

  final bool isAuthenticated;
  final String? sessionToken;

  /// Corpo `data` della risposta allauth (es. `user`, `flows`).
  final Map<String, dynamic> data;
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
