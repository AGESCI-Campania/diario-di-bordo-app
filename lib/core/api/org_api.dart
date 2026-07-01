import 'api_client.dart';

/// `/api/v1/org` — albero organizzativo (zona → gruppo → reparto → squadriglia).
class OrgApi {
  OrgApi(this._client);

  final ApiClient _client;

  Future<List<dynamic>> getAlbero() async {
    final response = await _client.dio.get('/api/v1/org/albero');
    return response.data as List<dynamic>;
  }
}
