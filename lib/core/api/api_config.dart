/// Base URL del backend Plancia.
///
/// Non va mai hardcodato nel codice (vedi CLAUDE.md — "Cosa NON fare"):
/// passalo con `--dart-define=API_BASE_URL=https://...`. Il default vale
/// solo per lo sviluppo locale, prima che i flavor dev/prod (Step 13)
/// sostituiscano questo meccanismo.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);
