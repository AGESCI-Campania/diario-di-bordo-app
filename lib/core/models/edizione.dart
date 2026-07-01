/// `GET /api/v1/edizioni` — anno scolastico Guidoncini Verdi.
class Edizione {
  const Edizione({
    required this.pk,
    required this.nome,
    required this.stato,
    required this.statoDisplay,
    required this.scadenza1,
    required this.scadenza2,
  });

  factory Edizione.fromJson(Map<String, dynamic> json) => Edizione(
    pk: json['pk'] as int,
    nome: json['nome'] as String,
    stato: json['stato'] as String,
    statoDisplay: json['stato_display'] as String,
    scadenza1: DateTime.parse(json['scadenza_1'] as String),
    scadenza2: DateTime.parse(json['scadenza_2'] as String),
  );

  final int pk;
  final String nome;
  final String stato;
  final String statoDisplay;
  final DateTime scadenza1;
  final DateTime scadenza2;

  Map<String, dynamic> toJson() => {
    'pk': pk,
    'nome': nome,
    'stato': stato,
    'stato_display': statoDisplay,
    'scadenza_1': scadenza1.toIso8601String().substring(0, 10),
    'scadenza_2': scadenza2.toIso8601String().substring(0, 10),
  };
}

/// Riferimento leggero a un'edizione, così com'è annidato in [Diario]
/// (solo `pk` e `nome`, senza stato/scadenze).
class EdizioneRef {
  const EdizioneRef({required this.pk, required this.nome});

  factory EdizioneRef.fromJson(Map<String, dynamic> json) =>
      EdizioneRef(pk: json['pk'] as int, nome: json['nome'] as String);

  final int pk;
  final String nome;

  Map<String, dynamic> toJson() => {'pk': pk, 'nome': nome};
}
