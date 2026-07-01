import 'api_client.dart';

/// `GET /api/v1/app-status` — controllo compatibilità versione app al
/// lancio (Plancia ≥ 2.3.0). Endpoint pubblico, nessuna autenticazione
/// richiesta.
class SystemApi {
  SystemApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getAppStatus() async {
    final response = await _client.dio.get('/api/v1/app-status');
    return response.data as Map<String, dynamic>;
  }
}
