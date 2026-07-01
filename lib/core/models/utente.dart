/// `GET /api/v1/me` — utente autenticato corrente.
class Utente {
  const Utente({
    required this.pk,
    required this.email,
    required this.nome,
    required this.cognome,
    required this.ruolo,
    required this.ruoloDisplay,
  });

  factory Utente.fromJson(Map<String, dynamic> json) => Utente(
    pk: json['pk'] as int,
    email: json['email'] as String,
    nome: json['nome'] as String,
    cognome: json['cognome'] as String,
    ruolo: json['ruolo'] as String,
    ruoloDisplay: json['ruolo_display'] as String,
  );

  final int pk;
  final String email;
  final String nome;
  final String cognome;

  /// Uno tra `csq`, `crp`, `pgv`, `incaricato_eg`, `segreteria`, `admin`
  /// (vedi tabella ruoli in CLAUDE.md).
  final String ruolo;
  final String ruoloDisplay;

  Map<String, dynamic> toJson() => {
    'pk': pk,
    'email': email,
    'nome': nome,
    'cognome': cognome,
    'ruolo': ruolo,
    'ruolo_display': ruoloDisplay,
  };
}
