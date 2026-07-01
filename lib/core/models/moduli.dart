// `lib/core/models/moduli.dart` — moduli 1–5 del diario, ciascuno con
// `version` (optimistic locking) e `data` tipizzata. Vedi CLAUDE.md
// "Optimistic locking" e `../plancia/docs/api/endpoints.md`.

class MembroSquadriglia {
  const MembroSquadriglia({
    required this.nome,
    required this.ruolo,
    required this.sentiero,
    required this.specialitaInd,
    required this.brevetto,
  });

  factory MembroSquadriglia.fromJson(Map<String, dynamic> json) =>
      MembroSquadriglia(
        nome: json['nome'] as String,
        ruolo: json['ruolo'] as String,
        sentiero: json['sentiero'] as String,
        specialitaInd: json['specialita_ind'] as String,
        brevetto: json['brevetto'] as String,
      );

  final String nome;
  final String ruolo;
  final String sentiero;
  final String specialitaInd;
  final String brevetto;

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'ruolo': ruolo,
    'sentiero': sentiero,
    'specialita_ind': specialitaInd,
    'brevetto': brevetto,
  };
}

/// Modulo 1 — Anagrafica.
class AnagraficaData {
  const AnagraficaData({
    required this.specialita,
    required this.tipoDiario,
    required this.nomeCsq,
    required this.cognomeCsq,
    required this.emailCsq,
    this.cellCsq,
    required this.nomeCrp,
    required this.cognomeCrp,
    required this.emailCrp,
    this.cellCrp,
    required this.membri,
  });

  factory AnagraficaData.fromJson(Map<String, dynamic> json) =>
      AnagraficaData(
        specialita: json['specialita'] as String,
        tipoDiario: json['tipo_diario'] as String,
        nomeCsq: json['nome_csq'] as String,
        cognomeCsq: json['cognome_csq'] as String,
        emailCsq: json['email_csq'] as String,
        cellCsq: json['cell_csq'] as String?,
        nomeCrp: json['nome_crp'] as String,
        cognomeCrp: json['cognome_crp'] as String,
        emailCrp: json['email_crp'] as String,
        cellCrp: json['cell_crp'] as String?,
        membri: (json['membri'] as List<dynamic>)
            .map((e) => MembroSquadriglia.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String specialita;
  final String tipoDiario;
  final String nomeCsq;
  final String cognomeCsq;
  final String emailCsq;
  final String? cellCsq;
  final String nomeCrp;
  final String cognomeCrp;
  final String emailCrp;
  final String? cellCrp;
  final List<MembroSquadriglia> membri;

  Map<String, dynamic> toJson() => {
    'specialita': specialita,
    'tipo_diario': tipoDiario,
    'nome_csq': nomeCsq,
    'cognome_csq': cognomeCsq,
    'email_csq': emailCsq,
    'cell_csq': cellCsq,
    'nome_crp': nomeCrp,
    'cognome_crp': cognomeCrp,
    'email_crp': emailCrp,
    'cell_crp': cellCrp,
    'membri': membri.map((e) => e.toJson()).toList(),
  };
}

class Anagrafica {
  const Anagrafica({required this.version, required this.data});

  factory Anagrafica.fromJson(Map<String, dynamic> json) => Anagrafica(
    version: json['version'] as int,
    data: AnagraficaData.fromJson(json['data'] as Map<String, dynamic>),
  );

  final int version;
  final AnagraficaData data;

  Map<String, dynamic> toJson() => {'version': version, 'data': data.toJson()};
}

/// Modulo 2 — Presentazione.
class PresentazioneData {
  const PresentazioneData({
    required this.nomeSquadriglia,
    required this.specialitaSquadriglia,
    required this.testoPresentazione,
    required this.esitiSpecialita,
  });

  factory PresentazioneData.fromJson(Map<String, dynamic> json) =>
      PresentazioneData(
        nomeSquadriglia: json['nome_squadriglia'] as String,
        specialitaSquadriglia: json['specialita_squadriglia'] as String,
        testoPresentazione: json['testo_presentazione'] as String,
        esitiSpecialita: json['esiti_specialita'] as List<dynamic>,
      );

  final String nomeSquadriglia;
  final String specialitaSquadriglia;
  final String testoPresentazione;

  /// Struttura non documentata dal backend: passata così com'è.
  final List<dynamic> esitiSpecialita;

  Map<String, dynamic> toJson() => {
    'nome_squadriglia': nomeSquadriglia,
    'specialita_squadriglia': specialitaSquadriglia,
    'testo_presentazione': testoPresentazione,
    'esiti_specialita': esitiSpecialita,
  };
}

class Presentazione {
  const Presentazione({required this.version, required this.data});

  factory Presentazione.fromJson(Map<String, dynamic> json) => Presentazione(
    version: json['version'] as int,
    data: PresentazioneData.fromJson(json['data'] as Map<String, dynamic>),
  );

  final int version;
  final PresentazioneData data;

  Map<String, dynamic> toJson() => {'version': version, 'data': data.toJson()};
}

class PostoAzione {
  const PostoAzione({required this.chi, required this.cosa});

  factory PostoAzione.fromJson(Map<String, dynamic> json) =>
      PostoAzione(chi: json['chi'] as String, cosa: json['cosa'] as String);

  final String chi;
  final String cosa;

  Map<String, dynamic> toJson() => {'chi': chi, 'cosa': cosa};
}

/// Modulo 3/4 — Impresa (1 e 2, la seconda opzionale per tipo `rinnovo`).
class ImpresaData {
  const ImpresaData({
    required this.numero,
    required this.titolo,
    required this.dataInizio,
    required this.dataFine,
    required this.perche,
    required this.come,
    required this.cosaAbbiamoImparato,
    required this.linkApprofondimento,
    required this.postiAzione,
    required this.esiti,
  });

  factory ImpresaData.fromJson(Map<String, dynamic> json) => ImpresaData(
    numero: json['numero'] as int,
    titolo: json['titolo'] as String,
    dataInizio: DateTime.parse(json['data_inizio'] as String),
    dataFine: DateTime.parse(json['data_fine'] as String),
    perche: json['perche'] as String,
    come: json['come'] as String,
    cosaAbbiamoImparato: json['cosa_abbiamo_imparato'] as String,
    linkApprofondimento: json['link_approfondimento'] as String,
    postiAzione: (json['posti_azione'] as List<dynamic>)
        .map((e) => PostoAzione.fromJson(e as Map<String, dynamic>))
        .toList(),
    esiti: json['esiti'] as List<dynamic>,
  );

  final int numero;
  final String titolo;
  final DateTime dataInizio;
  final DateTime dataFine;
  final String perche;
  final String come;
  final String cosaAbbiamoImparato;
  final String linkApprofondimento;
  final List<PostoAzione> postiAzione;

  /// Struttura non documentata dal backend: passata così com'è.
  final List<dynamic> esiti;

  Map<String, dynamic> toJson() => {
    'numero': numero,
    'titolo': titolo,
    'data_inizio': dataInizio.toIso8601String().substring(0, 10),
    'data_fine': dataFine.toIso8601String().substring(0, 10),
    'perche': perche,
    'come': come,
    'cosa_abbiamo_imparato': cosaAbbiamoImparato,
    'link_approfondimento': linkApprofondimento,
    'posti_azione': postiAzione.map((e) => e.toJson()).toList(),
    'esiti': esiti,
  };
}

class Impresa {
  const Impresa({required this.version, required this.data});

  factory Impresa.fromJson(Map<String, dynamic> json) => Impresa(
    version: json['version'] as int,
    data: ImpresaData.fromJson(json['data'] as Map<String, dynamic>),
  );

  final int version;
  final ImpresaData data;

  Map<String, dynamic> toJson() => {'version': version, 'data': data.toJson()};
}

class PostoAzioneMissione {
  const PostoAzioneMissione({required this.descrizione});

  factory PostoAzioneMissione.fromJson(Map<String, dynamic> json) =>
      PostoAzioneMissione(descrizione: json['descrizione'] as String);

  final String descrizione;

  Map<String, dynamic> toJson() => {'descrizione': descrizione};
}

/// Modulo 5 — Missione (opzionale per tipo `rinnovo`).
class MissioneData {
  const MissioneData({
    required this.titolo,
    required this.data,
    required this.descrizione,
    required this.postiAzioneMissione,
    required this.esiti,
  });

  factory MissioneData.fromJson(Map<String, dynamic> json) => MissioneData(
    titolo: json['titolo'] as String,
    data: DateTime.parse(json['data'] as String),
    descrizione: json['descrizione'] as String,
    postiAzioneMissione: (json['posti_azione_missione'] as List<dynamic>)
        .map((e) => PostoAzioneMissione.fromJson(e as Map<String, dynamic>))
        .toList(),
    esiti: json['esiti'] as List<dynamic>,
  );

  final String titolo;
  final DateTime data;
  final String descrizione;
  final List<PostoAzioneMissione> postiAzioneMissione;

  /// Struttura non documentata dal backend: passata così com'è.
  final List<dynamic> esiti;

  Map<String, dynamic> toJson() => {
    'titolo': titolo,
    'data': data.toIso8601String().substring(0, 10),
    'descrizione': descrizione,
    'posti_azione_missione': postiAzioneMissione.map((e) => e.toJson()).toList(),
    'esiti': esiti,
  };
}

class Missione {
  const Missione({required this.version, required this.data});

  factory Missione.fromJson(Map<String, dynamic> json) => Missione(
    version: json['version'] as int,
    data: MissioneData.fromJson(json['data'] as Map<String, dynamic>),
  );

  final int version;
  final MissioneData data;

  Map<String, dynamic> toJson() => {'version': version, 'data': data.toJson()};
}
