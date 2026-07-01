import 'package:dio/dio.dart';

import 'api_exceptions.dart';

/// Versione dell'app inviata come `X-App-Version` su `/api/v1/*` (Plancia
/// ≥ 2.3.0 la usa per `AppVersionMiddleware` — 426 sotto la minima
/// configurata, header `X-App-Upgrade-Warning` sotto la deprecata). Tenere
/// allineata a `version:` in `pubspec.yaml` (vedi CLAUDE.md — Identificativi).
const String appVersion = '1.0.0';

/// Punto centrale di configurazione HTTP verso il backend Plancia.
///
/// Espone due client perché le due famiglie di endpoint usano forme di
/// errore diverse:
/// - [dio] → `/api/v1/*`, errori mappati sulle [ApiException] descritte
///   nella tabella "Gestione errori API" di CLAUDE.md (401 → logout
///   forzato, 409 → conflitto di optimistic locking, ecc.).
/// - [authDio] → `/_allauth/app/v1/*`, segue l'envelope di django-allauth
///   headless in cui anche un `401` è una risposta "normale" del flusso di
///   login/MFA: `AuthApi` legge lo status direttamente dal body, senza che
///   venga sollevata un'eccezione.
///
/// `baseUrl` non va mai hardcodato: passalo da `--dart-define=API_BASE_URL`
/// (vedi CLAUDE.md — Step 13, flavor dev/prod).
class ApiClient {
  ApiClient({
    required String baseUrl,
    required Future<String?> Function() getToken,
    void Function()? onUnauthorized,
  }) : dio = Dio(BaseOptions(baseUrl: baseUrl)),
       authDio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           validateStatus: (status) => status != null && status < 500,
         ),
       ) {
    for (final client in [dio, authDio]) {
      client.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await getToken();
            if (token != null) {
              options.headers['X-Session-Token'] = token;
            }
            handler.next(options);
          },
        ),
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-App-Version'] = appVersion;
          handler.next(options);
        },
        onError: (error, handler) => handler.reject(
          error.copyWith(error: _mapApiError(error, onUnauthorized)),
        ),
      ),
    );

    authDio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.response == null) {
            handler.reject(error.copyWith(error: const NetworkException()));
            return;
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;
  final Dio authDio;
}

ApiException _mapApiError(DioException error, void Function()? onUnauthorized) {
  final response = error.response;
  if (response == null) {
    return const NetworkException();
  }

  final data = response.data;
  final detail = data is Map ? data['detail'] as String? : null;

  switch (response.statusCode) {
    case 400:
      final errors = data is Map ? data['errors'] as Map? : null;
      return ValidationException(
        errors?.map(
              (key, value) =>
                  MapEntry(key as String, List<String>.from(value as List)),
            ) ??
            const <String, List<String>>{},
      );
    case 401:
      onUnauthorized?.call();
      return const UnauthorizedException();
    case 403:
      return PermissionDeniedException(detail ?? 'Permesso negato');
    case 404:
      return NotFoundException(detail ?? 'Risorsa non trovata');
    case 409:
      final serverVersion = data is Map
          ? data['server_version'] as int?
          : null;
      return ConflictException(serverVersion ?? 0);
    case 422:
      return InvalidStateException(
        detail ?? 'Stato non valido per questa azione',
      );
    case 503:
      return MaintenanceException(detail ?? 'Servizio in manutenzione');
    case 426:
      final versioneMinima = data is Map
          ? data['versione_minima'] as String? ?? ''
          : '';
      return UpgradeRequiredException(
        versioneMinima,
        detail ?? "Versione app non supportata. Aggiorna l'app per continuare.",
      );
    case 429:
      final retryAfter =
          (data is Map ? data['retry_after'] as int? : null) ??
          int.tryParse(response.headers.value('retry-after') ?? '') ??
          0;
      return RateLimitException(
        retryAfter,
        detail ?? 'Troppe richieste, riprova più tardi',
      );
    default:
      return UnknownApiException(
        detail ?? 'Errore imprevisto (${response.statusCode})',
      );
  }
}
