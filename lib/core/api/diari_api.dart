import 'api_client.dart';

/// `/api/v1/diari` — lista, dettaglio, moduli 1–6 e transizioni FSM.
///
/// I moduli 1–5 usano optimistic locking: leggi `version` dal dettaglio,
/// passalo nel PUT, e gestisci il `409 Conflict` (vedi CLAUDE.md). La
/// relazione finale (modulo 6) non ha `version`.
class DiariApi {
  DiariApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getDiari({
    int? edizione,
    String? stato,
    int? squadriglia,
    int page = 1,
  }) async {
    final response = await _client.dio.get(
      '/api/v1/diari',
      queryParameters: {
        'edizione': ?edizione,
        'stato': ?stato,
        'squadriglia': ?squadriglia,
        'page': page,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDiario(int pk) async {
    final response = await _client.dio.get('/api/v1/diari/$pk');
    return response.data as Map<String, dynamic>;
  }

  /// Modulo 1.
  Future<Map<String, dynamic>> putAnagrafica(
    int pk, {
    required int version,
    required Map<String, dynamic> data,
  }) => _putModulo('$pk/anagrafica', version: version, data: data);

  /// Modulo 2.
  Future<Map<String, dynamic>> putPresentazione(
    int pk, {
    required int version,
    required Map<String, dynamic> data,
  }) => _putModulo('$pk/presentazione', version: version, data: data);

  /// `numero` ∈ {1, 2} — modulo 3 (impresa 1) o modulo 4 (impresa 2,
  /// opzionale per tipo `rinnovo`).
  Future<Map<String, dynamic>> putImpresa(
    int pk,
    int numero, {
    required int version,
    required Map<String, dynamic> data,
  }) => _putModulo('$pk/imprese/$numero', version: version, data: data);

  /// Modulo 5 (opzionale per rinnovo).
  Future<Map<String, dynamic>> putMissione(
    int pk, {
    required int version,
    required Map<String, dynamic> data,
  }) => _putModulo('$pk/missione', version: version, data: data);

  /// Modulo 6 (solo CRP) — nessun optimistic locking.
  Future<Map<String, dynamic>> putRelazioneFinale(
    int pk, {
    required Map<String, dynamic> data,
  }) async {
    final response = await _client.dio.put(
      '/api/v1/diari/$pk/relazione-finale',
      data: {'data': data},
    );
    return response.data as Map<String, dynamic>;
  }

  /// `azione` ∈ {`csq-invia`, `invia`, `riapri`}.
  Future<Map<String, dynamic>> eseguiAzione(int pk, String azione) async {
    final response = await _client.dio.post('/api/v1/diari/$pk/azioni/$azione');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _putModulo(
    String path, {
    required int version,
    required Map<String, dynamic> data,
  }) async {
    final response = await _client.dio.put(
      '/api/v1/diari/$path',
      data: {'version': version, 'data': data},
    );
    return response.data as Map<String, dynamic>;
  }
}
