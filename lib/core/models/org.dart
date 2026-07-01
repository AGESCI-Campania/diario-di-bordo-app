// `GET /api/v1/org/albero` — struttura organizzativa completa
// (zona → gruppo → reparto → squadriglia).

class Squadriglia {
  const Squadriglia({required this.pk, required this.nome});

  factory Squadriglia.fromJson(Map<String, dynamic> json) =>
      Squadriglia(pk: json['pk'] as int, nome: json['nome'] as String);

  final int pk;
  final String nome;

  Map<String, dynamic> toJson() => {'pk': pk, 'nome': nome};
}

class Reparto {
  const Reparto({
    required this.pk,
    required this.nome,
    required this.squadriglie,
  });

  factory Reparto.fromJson(Map<String, dynamic> json) => Reparto(
    pk: json['pk'] as int,
    nome: json['nome'] as String,
    squadriglie: (json['squadriglie'] as List<dynamic>)
        .map((e) => Squadriglia.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final int pk;
  final String nome;
  final List<Squadriglia> squadriglie;

  Map<String, dynamic> toJson() => {
    'pk': pk,
    'nome': nome,
    'squadriglie': squadriglie.map((e) => e.toJson()).toList(),
  };
}

class Gruppo {
  const Gruppo({required this.pk, required this.nome, required this.reparti});

  factory Gruppo.fromJson(Map<String, dynamic> json) => Gruppo(
    pk: json['pk'] as int,
    nome: json['nome'] as String,
    reparti: (json['reparti'] as List<dynamic>)
        .map((e) => Reparto.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final int pk;
  final String nome;
  final List<Reparto> reparti;

  Map<String, dynamic> toJson() => {
    'pk': pk,
    'nome': nome,
    'reparti': reparti.map((e) => e.toJson()).toList(),
  };
}

class Zona {
  const Zona({required this.pk, required this.nome, required this.gruppi});

  factory Zona.fromJson(Map<String, dynamic> json) => Zona(
    pk: json['pk'] as int,
    nome: json['nome'] as String,
    gruppi: (json['gruppi'] as List<dynamic>)
        .map((e) => Gruppo.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  final int pk;
  final String nome;
  final List<Gruppo> gruppi;

  Map<String, dynamic> toJson() => {
    'pk': pk,
    'nome': nome,
    'gruppi': gruppi.map((e) => e.toJson()).toList(),
  };

  static List<Zona> listFromJson(List<dynamic> json) =>
      json.map((e) => Zona.fromJson(e as Map<String, dynamic>)).toList();
}
