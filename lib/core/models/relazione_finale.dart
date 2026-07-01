/// Modulo 6 — Relazione finale (solo CRP, nessun `version`: vedi
/// CLAUDE.md "Optimistic locking"). **Non deve mai essere visibile al CSQ.**
class RelazioneFinale {
  const RelazioneFinale({
    required this.sintesiImpresa1,
    required this.sintesiImpresa2,
    required this.sintesiMissione,
    required this.considerazioni,
    required this.specialitaConquistata,
  });

  factory RelazioneFinale.fromJson(Map<String, dynamic> json) =>
      RelazioneFinale(
        sintesiImpresa1: json['sintesi_impresa1'] as String,
        sintesiImpresa2: json['sintesi_impresa2'] as String,
        sintesiMissione: json['sintesi_missione'] as String,
        considerazioni: json['considerazioni'] as String,
        specialitaConquistata: json['specialita_conquistata'] as bool,
      );

  final String sintesiImpresa1;
  final String sintesiImpresa2;
  final String sintesiMissione;
  final String considerazioni;
  final bool specialitaConquistata;

  Map<String, dynamic> toJson() => {
    'sintesi_impresa1': sintesiImpresa1,
    'sintesi_impresa2': sintesiImpresa2,
    'sintesi_missione': sintesiMissione,
    'considerazioni': considerazioni,
    'specialita_conquistata': specialitaConquistata,
  };
}
