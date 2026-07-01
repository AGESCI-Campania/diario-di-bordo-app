/// `GET /api/v1/diari/{pk}/valutazione` — esito e ciclo di valutazione.
///
/// Visibilità (vedi CLAUDE.md): CSQ/CRP solo se `pubblicata`, PGV solo se
/// assegnato, staff/Incaricato/Admin sempre. La valutazione non pubblicata
/// non deve mai essere mostrata al CSQ.
class AssegnazionePgv {
  const AssegnazionePgv({
    required this.pgvPk,
    required this.pgvNome,
    required this.pgvEmail,
  });

  factory AssegnazionePgv.fromJson(Map<String, dynamic> json) =>
      AssegnazionePgv(
        pgvPk: json['pgv_pk'] as int,
        pgvNome: json['pgv_nome'] as String,
        pgvEmail: json['pgv_email'] as String,
      );

  final int pgvPk;
  final String pgvNome;
  final String pgvEmail;

  Map<String, dynamic> toJson() => {
    'pgv_pk': pgvPk,
    'pgv_nome': pgvNome,
    'pgv_email': pgvEmail,
  };
}

class Valutazione {
  const Valutazione({
    required this.esito,
    required this.esitoDisplay,
    required this.stato,
    required this.note,
    required this.pubblicata,
    required this.assegnazioni,
  });

  factory Valutazione.fromJson(Map<String, dynamic> json) => Valutazione(
    esito: json['esito'] as String?,
    esitoDisplay: json['esito_display'] as String?,
    stato: json['stato'] as String,
    note: json['note'] as String?,
    pubblicata: json['pubblicata'] as bool,
    assegnazioni: (json['assegnazioni'] as List<dynamic>)
        .map((e) => AssegnazionePgv.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// `approvato`, `non_approvato` o `maggiori_info`; `null` finché non
  /// ancora valutata.
  final String? esito;
  final String? esitoDisplay;

  /// Stato del ciclo di valutazione (es. `proposta`, `in_revisione`,
  /// `confermata`) — dominio distinto da `StatoDiario`.
  final String stato;
  final String? note;
  final bool pubblicata;
  final List<AssegnazionePgv> assegnazioni;

  Map<String, dynamic> toJson() => {
    'esito': esito,
    'esito_display': esitoDisplay,
    'stato': stato,
    'note': note,
    'pubblicata': pubblicata,
    'assegnazioni': assegnazioni.map((e) => e.toJson()).toList(),
  };
}
