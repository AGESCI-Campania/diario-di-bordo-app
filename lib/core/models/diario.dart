import 'edizione.dart';
import 'moduli.dart';
import 'org.dart';
import 'relazione_finale.dart';
import 'valutazione.dart';

/// I 9 stati FSM del diario (mirror di `StatoDiario` nel backend Plancia,
/// `../plancia/apps/diaries/models.py`). Vedi memoria di progetto
/// `project_stato_diario_fsm` per la mappatura colore in `StatoBadge`.
enum StatoDiario {
  nonIniziato('non_iniziato'),
  inCompilazione('in_compilazione'),
  relazioneFinale('relazione_finale'),
  inviato('inviato'),
  inValutazione('in_valutazione'),
  inRevisione('in_revisione'),
  approvato('approvato'),
  nonApprovato('non_approvato'),
  maggioriInfo('maggiori_info');

  const StatoDiario(this.value);

  final String value;

  static StatoDiario fromValue(String value) => StatoDiario.values.firstWhere(
    (e) => e.value == value,
    orElse: () => throw ArgumentError('StatoDiario sconosciuto: $value'),
  );
}

/// `GET /api/v1/diari` — voce di lista (vedi [DiarioDetail] per il dettaglio
/// completo con i moduli).
class Diario {
  const Diario({
    required this.pk,
    required this.squadriglia,
    required this.edizione,
    required this.tipo,
    required this.tipoDisplay,
    required this.stato,
    required this.statoDisplay,
    required this.pubblicato,
    required this.version,
  });

  factory Diario.fromJson(Map<String, dynamic> json) => Diario(
    pk: json['pk'] as int,
    squadriglia: Squadriglia.fromJson(json['squadriglia'] as Map<String, dynamic>),
    edizione: EdizioneRef.fromJson(json['edizione'] as Map<String, dynamic>),
    tipo: json['tipo'] as String,
    tipoDisplay: json['tipo_display'] as String,
    stato: StatoDiario.fromValue(json['stato'] as String),
    statoDisplay: json['stato_display'] as String,
    pubblicato: json['pubblicato'] as bool,
    version: json['version'] as int,
  );

  final int pk;
  final Squadriglia squadriglia;
  final EdizioneRef edizione;

  /// `nuovo` o `rinnovo`.
  final String tipo;
  final String tipoDisplay;
  final StatoDiario stato;
  final String statoDisplay;
  final bool pubblicato;
  final int version;

  Map<String, dynamic> toJson() => {
    'pk': pk,
    'squadriglia': squadriglia.toJson(),
    'edizione': edizione.toJson(),
    'tipo': tipo,
    'tipo_display': tipoDisplay,
    'stato': stato.value,
    'stato_display': statoDisplay,
    'pubblicato': pubblicato,
    'version': version,
  };
}

/// `GET /api/v1/diari/{pk}` — dettaglio completo con tutti i moduli.
///
/// `relazioneFinale` è sempre `null` per i CSQ (mai visibile), `valutazione`
/// è `null` se non pubblicata (per CSQ/CRP) o non ancora creata — vedi
/// CLAUDE.md "Regola critica".
class DiarioDetail {
  const DiarioDetail({
    required this.pk,
    required this.squadriglia,
    required this.edizione,
    required this.tipo,
    required this.stato,
    required this.pubblicato,
    this.anagrafica,
    this.presentazione,
    required this.imprese,
    this.missione,
    this.relazioneFinale,
    this.valutazione,
  });

  factory DiarioDetail.fromJson(Map<String, dynamic> json) => DiarioDetail(
    pk: json['pk'] as int,
    squadriglia: Squadriglia.fromJson(json['squadriglia'] as Map<String, dynamic>),
    edizione: EdizioneRef.fromJson(json['edizione'] as Map<String, dynamic>),
    tipo: json['tipo'] as String,
    stato: StatoDiario.fromValue(json['stato'] as String),
    pubblicato: json['pubblicato'] as bool,
    anagrafica: json['anagrafica'] == null
        ? null
        : Anagrafica.fromJson(json['anagrafica'] as Map<String, dynamic>),
    presentazione: json['presentazione'] == null
        ? null
        : Presentazione.fromJson(json['presentazione'] as Map<String, dynamic>),
    imprese: (json['imprese'] as List<dynamic>)
        .map((e) => Impresa.fromJson(e as Map<String, dynamic>))
        .toList(),
    missione: json['missione'] == null
        ? null
        : Missione.fromJson(json['missione'] as Map<String, dynamic>),
    relazioneFinale: json['relazione_finale'] == null
        ? null
        : RelazioneFinale.fromJson(json['relazione_finale'] as Map<String, dynamic>),
    valutazione: json['valutazione'] == null
        ? null
        : Valutazione.fromJson(json['valutazione'] as Map<String, dynamic>),
  );

  final int pk;
  final Squadriglia squadriglia;
  final EdizioneRef edizione;
  final String tipo;
  final StatoDiario stato;
  final bool pubblicato;
  final Anagrafica? anagrafica;
  final Presentazione? presentazione;
  final List<Impresa> imprese;
  final Missione? missione;
  final RelazioneFinale? relazioneFinale;
  final Valutazione? valutazione;

  Map<String, dynamic> toJson() => {
    'pk': pk,
    'squadriglia': squadriglia.toJson(),
    'edizione': edizione.toJson(),
    'tipo': tipo,
    'stato': stato.value,
    'pubblicato': pubblicato,
    'anagrafica': anagrafica?.toJson(),
    'presentazione': presentazione?.toJson(),
    'imprese': imprese.map((e) => e.toJson()).toList(),
    'missione': missione?.toJson(),
    'relazione_finale': relazioneFinale?.toJson(),
    'valutazione': valutazione?.toJson(),
  };
}
