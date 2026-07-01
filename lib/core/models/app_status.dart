/// `GET /api/v1/app-status` (Plancia ≥ 2.3.0) — compatibilità della
/// versione app corrente. Chiamato al lancio, prima del login: se
/// [upgradeRequired] la UI deve mostrare una pagina di blocco; se
/// [upgradeAvailable] un banner non bloccante che elenca [funzioniLimitate].
class AppStatus {
  const AppStatus({
    required this.upgradeRequired,
    required this.upgradeAvailable,
    required this.versioneMinima,
    required this.deprecataSotto,
    required this.messaggio,
    required this.funzioniLimitate,
  });

  factory AppStatus.fromJson(Map<String, dynamic> json) => AppStatus(
    upgradeRequired: json['upgrade_required'] as bool,
    upgradeAvailable: json['upgrade_available'] as bool,
    versioneMinima: json['versione_minima'] as String,
    deprecataSotto: json['deprecata_sotto'] as String,
    messaggio: json['messaggio'] as String,
    funzioniLimitate: List<String>.from(json['funzioni_limitate'] as List),
  );

  final bool upgradeRequired;
  final bool upgradeAvailable;
  final String versioneMinima;
  final String deprecataSotto;
  final String messaggio;
  final List<String> funzioniLimitate;

  Map<String, dynamic> toJson() => {
    'upgrade_required': upgradeRequired,
    'upgrade_available': upgradeAvailable,
    'versione_minima': versioneMinima,
    'deprecata_sotto': deprecataSotto,
    'messaggio': messaggio,
    'funzioni_limitate': funzioniLimitate,
  };
}
