import 'api_client.dart';

/// `/api/v1/edizioni` — anni scolastici Guidoncini Verdi.
class EditionsApi {
  EditionsApi(this._client);

  final ApiClient _client;

  Future<List<dynamic>> getEdizioni() async {
    final response = await _client.dio.get('/api/v1/edizioni');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getEdizione(int pk) async {
    final response = await _client.dio.get('/api/v1/edizioni/$pk');
    return response.data as Map<String, dynamic>;
  }
}
