import 'package:dio/dio.dart';

/// Eccezioni per gli errori dell'API Plancia `/api/v1/*`.
///
/// Vedi CLAUDE.md — tabella "Gestione errori API" per l'azione UI attesa
/// per ciascun caso.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// `400` — dati non validi. `errors` è la mappa campo → lista messaggi.
class ValidationException extends ApiException {
  const ValidationException(this.errors) : super('Dati non validi');

  final Map<String, List<String>> errors;
}

/// `401` inaspettato — la UI deve forzare il logout e tornare al login.
class UnauthorizedException extends ApiException {
  const UnauthorizedException()
    : super('Sessione scaduta, effettua di nuovo il login');
}

/// `403` — permesso negato, nessun redirect.
class PermissionDeniedException extends ApiException {
  const PermissionDeniedException([super.message = 'Permesso negato']);
}

/// `404` — risorsa non trovata.
class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Risorsa non trovata']);
}

/// `409` — conflitto di optimistic locking su un modulo 1–5.
class ConflictException extends ApiException {
  const ConflictException(this.serverVersion)
    : super('Il modulo è stato aggiornato da un altro dispositivo');

  final int serverVersion;
}

/// `422` — stato FSM non valido per l'azione richiesta.
class InvalidStateException extends ApiException {
  const InvalidStateException(super.message);
}

/// `503` — servizio in manutenzione: la UI mostra una pagina dedicata.
class MaintenanceException extends ApiException {
  const MaintenanceException([super.message = 'Servizio in manutenzione']);
}

/// `426` — versione app sotto `app_versione_minima` (Plancia ≥ 2.3.0):
/// aggiornamento obbligatorio, la UI deve bloccare l'accesso.
class UpgradeRequiredException extends ApiException {
  const UpgradeRequiredException(
    this.versioneMinima, [
    super.message =
        "Versione app non supportata. Aggiorna l'app per continuare.",
  ]);

  final String versioneMinima;
}

/// `429` — rate limit superato (Plancia ≥ 2.3.0): la UI mostra un messaggio
/// e può ritentare dopo `retryAfter` secondi.
class RateLimitException extends ApiException {
  const RateLimitException(
    this.retryAfter, [
    super.message = 'Troppe richieste, riprova più tardi',
  ]);

  final int retryAfter;
}

/// Nessuna connessione di rete, timeout, o errore di trasporto.
class NetworkException extends ApiException {
  const NetworkException([super.message = 'Connessione assente']);
}

/// Qualunque altro errore HTTP non previsto dalla tabella di CLAUDE.md.
class UnknownApiException extends ApiException {
  const UnknownApiException(super.message);
}

/// Estrae la [ApiException] mappata dall'interceptor di `ApiClient` da un
/// errore catturato a livello applicativo. L'interceptor rigetta sempre con
/// `error.copyWith(error: <ApiException>)`, quindi il chiamante riceve una
/// [DioException] la cui [DioException.error] è già il tipo applicativo.
ApiException apiExceptionOf(Object error) {
  if (error is ApiException) return error;
  if (error is DioException && error.error is ApiException) {
    return error.error as ApiException;
  }
  return UnknownApiException(error.toString());
}
