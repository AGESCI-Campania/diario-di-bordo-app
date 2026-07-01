import 'api_client.dart';

/// `GET /api/v1/me` — utente autenticato corrente.
class MeApi {
  MeApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getMe() async {
    final response = await _client.dio.get('/api/v1/me');
    return response.data as Map<String, dynamic>;
  }
}
