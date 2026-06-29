# CLAUDE.md — Diari di Bordo (Flutter)

Questo file orienta Claude Code nello sviluppo dell'app mobile **Diari di Bordo**.

---

## Cos'è questa app

App mobile Flutter per la gestione dei **Guidoncini Verdi** di AGESCI Campania (Branca E/G).
Consente a Capi Squadriglia, Capi Reparto, Pattuglia GV, Incaricati EG e Segreteria di
consultare e compilare i Diari di Bordo tramite le API REST della piattaforma **Plancia**.

Repo backend (Django): `../plancia/`  
API REST documentata in: `../plancia/docs/api/`

## Identificativi

- **Bundle ID**: `org.antaresnet.appgv`
- **Nome display**: Diari di Bordo
- **Versione**: `1.0.0` (indipendente dal backend)
- **Targets**: Plancia API v1 (`/api/v1/`)

## Stack

- **Flutter 3.x**, Dart 3.x
- **Riverpod** (`hooks_riverpod`) — state management
- **go_router** — navigazione con route guards
- **Dio** — client HTTP, interceptors per `X-Session-Token` e gestione errori
- **flutter_secure_storage** — token e PIN in Keychain/Keystore
- **local_auth** — FaceID, TouchID, Fingerprint Android
- **reactive_forms** — form moduli 1–5 con validazione
- **flutter_native_splash** — splash screen
- **intl** — localizzazione italiana

## Layout cartelle

```
lib/
  core/
    api/          # Dio client, interceptors, api per ogni dominio
    auth/         # AuthService: login, logout, token storage
    models/       # Modelli JSON (Diario, Moduli, Edizione, Org, Utente)
    theme/        # PlanciaTheme, PlanciaColors
  features/
    auth/         # LoginPage, MfaPage, BiometricGatePage, PinPage, PinSetupPage
    diari/        # DiariListPage, DiarioDetailPage, ModuloNEditPage
    relazione/    # RelazioneFinaleEditPage (solo CRP)
    evaluations/  # ValutazionePage e form per ogni ruolo
    editions/     # EdizioniListPage, EdizioneDetailPage
    org/          # AlberoOrgPage
  shared/
    widgets/      # Widget riusabili: StatoBadge, ModuloCard, LoadingSkeleton, EmptyState
assets/
  icons/          # icon-192x192.png, icon-512x512.png, icon-1024x1024.png
```

## Comandi utili

```bash
flutter pub get                        # installa dipendenze
flutter run                            # avvia su dispositivo/simulatore collegato
flutter run --dart-define=API_BASE_URL=https://... # con URL API esplicito
flutter build apk                      # build Android
flutter build ipa                      # build iOS (richiede Xcode)
flutter test                           # tutti i test
flutter analyze                        # analisi statica Dart
dart format lib/                       # formattazione codice
```

## Autenticazione — flusso chiave

L'app usa allauth headless in **app-mode** (non browser-mode):

```
POST /_allauth/app/v1/auth/login        → X-Session-Token (se MFA non richiesto)
POST /_allauth/app/v1/auth/2fa/authenticate → completa MFA con codice TOTP
GET  /api/v1/me                         → verifica token e legge ruolo utente
```

Il token viene salvato in `flutter_secure_storage`. Ad ogni avvio o rientro dal background
(>5 min) viene richiesto il gate biometrico o PIN prima di mostrare qualsiasi dato.

## Ruoli e visibilità (specchio del backend)

| Ruolo | Codice | Cosa vede |
|---|---|---|
| Capo Squadriglia | `csq` | Solo il proprio diario, moduli 1–5; valutazione solo se pubblicata |
| Capo Reparto | `crp` | Diari del proprio reparto + relazione finale (modulo 6) |
| Pattuglia GV | `pgv` | Solo diari assegnati; può proporre valutazione |
| Incaricato EG | `incaricato_eg` | Tutti i diari; tutte le azioni di valutazione |
| Segreteria | `segreteria` | Tutti i diari; tutte le azioni |
| Admin | `admin` | Accesso completo |

**Regola critica**: il modulo 6 (relazione finale) e la valutazione non pubblicata non
devono mai essere visibili al CSQ — né via UI né via API (il backend lo garantisce,
ma l'UI non deve nemmeno tentare di mostrarli).

## Gestione errori API

| HTTP | Azione nell'app |
|---|---|
| `401` inaspettato | Logout forzato → LoginPage, pulizia secure_storage |
| `403` | Messaggio "Permesso negato", nessun redirect |
| `409` Conflict (optimistic lock) | Dialog "Modulo aggiornato da un altro dispositivo — ricarica?" |
| `422` Stato non valido | Snackbar con il messaggio dell'API |
| `503` Manutenzione | Pagina dedicata (non dialog) |
| Nessuna rete | Banner offline + timestamp ultimo dato in cache (cache in memoria) |

## Palette colori AGESCI

```dart
const verdePrimario = Color(0xFF5AA02C);  // Verde GV — brand principale PWA
const verdeScuro    = Color(0xFF3D8E33);  // Branca E/G
const violaIstituz  = Color(0xFF7A1E99);  // AGESCI istituzionale
const gialloOro     = Color(0xFFFFCC1E); // Accent
```

`ThemeData` usa `ColorScheme.fromSeed(seedColor: verdePrimario)` — Material 3.

## Optimistic locking (moduli 1–5)

1. `GET /api/v1/diari/{id}` → leggi il campo `version` del modulo
2. `PUT /api/v1/diari/{id}/anagrafica` con `{"version": N, "data": {...}}`
3. Se `409` → mostra dialog, ricarica, riproponi il form con i dati freschi

La relazione finale (modulo 6) non ha `version`.

## Cosa NON fare

- Non mostrare relazione finale o valutazione non pubblicata al CSQ.
- Non salvare dati sensibili (contenuto diari, foto) in cache persistente su disco — solo cache in memoria per la sessione corrente.
- Non usare browser-mode allauth (`/_allauth/browser/`): usare sempre app-mode (`/_allauth/app/`).
- Non hardcodare l'URL del backend: usare `--dart-define=API_BASE_URL` o flavor dev/prod.
- Non bypassare il gate biometrico/PIN con logica lato app — è l'unica protezione locale.
