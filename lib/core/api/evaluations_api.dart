import 'api_client.dart';

/// `/api/v1/diari/{pk}/valutazione` — ciclo di valutazione del diario.
///
/// Visibilità (vedi CLAUDE.md): CSQ/CRP solo se pubblicata, PGV solo se
/// assegnato, staff/Incaricato/Admin sempre.
class EvaluationsApi {
  EvaluationsApi(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> getValutazione(int diarioPk) async {
    final response = await _client.dio.get(
      '/api/v1/diari/$diarioPk/valutazione',
    );
    return response.data as Map<String, dynamic>;
  }

  /// Solo staff/incaricato.
  Future<Map<String, dynamic>> assegnaPgv(int diarioPk, int pgvPk) =>
      _post(diarioPk, 'assegna-pgv', {'pgv_pk': pgvPk});

  /// Valutazione diretta, senza passare per la PGV. Solo
  /// incaricato/admin/segreteria.
  Future<Map<String, dynamic>> valuta(
    int diarioPk, {
    required String esito,
    String? note,
  }) => _post(diarioPk, 'valuta', {'esito': esito, 'note': ?note});

  /// Proposta PGV — `esito` non può essere `maggiori_info`. Solo PGV
  /// assegnato al diario.
  Future<Map<String, dynamic>> proponi(
    int diarioPk, {
    required String esito,
    String? note,
  }) => _post(diarioPk, 'proposta', {'esito': esito, 'note': ?note});

  /// Conferma la proposta PGV. Solo incaricato/admin.
  Future<Map<String, dynamic>> conferma(int diarioPk, {String? note}) =>
      _post(diarioPk, 'conferma', {'note': ?note});

  /// Rigetta la proposta PGV, il diario torna in `in_valutazione`. Solo
  /// incaricato/admin.
  Future<Map<String, dynamic>> rigetta(int diarioPk) =>
      _post(diarioPk, 'rigetta', const {});

  /// Modifica l'esito prima della pubblicazione. Solo incaricato/admin.
  Future<Map<String, dynamic>> modifica(
    int diarioPk, {
    required String esito,
    String? note,
  }) => _post(diarioPk, 'modifica', {'esito': esito, 'note': ?note});

  /// Pubblica l'esito del singolo diario. Solo incaricato/admin.
  Future<Map<String, dynamic>> pubblica(int diarioPk) =>
      _post(diarioPk, 'pubblica', const {});

  Future<Map<String, dynamic>> _post(
    int diarioPk,
    String azione,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.dio.post(
      '/api/v1/diari/$diarioPk/valutazione/$azione',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }
}
