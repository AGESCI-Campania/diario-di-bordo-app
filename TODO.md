# TODO — Diari di Bordo (Flutter)

## Step 1 — Scaffolding progetto ✅

- [x] `flutter create --org org.antaresnet --platforms ios,android appgv`
- [x] Bundle ID: `org.antaresnet.appgv` (iOS e Android)
- [x] Cartella rinominata in `diario-di-bordo-app`, nome display "Diari di Bordo"
- [x] Git inizializzato, primo commit
- [x] Struttura cartelle `lib/core/`, `lib/features/`, `lib/shared/`, `assets/`
- [x] Icone PWA copiate in `assets/icons/` (192, 512, 1024px)
- [x] `CLAUDE.md` e `TODO.md` creati

---

## Step 2 — Dipendenze (`pubspec.yaml`)

- [ ] `dio` — client HTTP con interceptors
- [ ] `hooks_riverpod` + `riverpod_annotation` — state management
- [ ] `go_router` — navigazione con route guards
- [ ] `flutter_secure_storage` — Keychain/Keystore per X-Session-Token e PIN
- [ ] `local_auth` — FaceID, TouchID, Fingerprint
- [ ] `reactive_forms` — form moduli 1–5 con validazione
- [ ] `flutter_svg` — icone SVG AGESCI
- [ ] `flutter_native_splash` — splash screen
- [ ] `intl` — localizzazione italiana
- [ ] `build_runner` + `riverpod_generator` (dev) — code generation Riverpod

---

## Step 3 — Design system e tema

- [ ] `lib/core/theme/plancia_colors.dart`: palette AGESCI (verde #5AA02C, viola #7A1E99, giallo #FFCC1E)
- [ ] `lib/core/theme/plancia_theme.dart`: `ThemeData` con `ColorScheme.fromSeed(verdePrimario)` Material 3
- [ ] Chip colori stati FSM (mappati 1:1 con la web app)
- [ ] Configurare `flutter_native_splash` (sfondo bianco + logo `assets/icons/icon-512x512.png`)
- [ ] Aggiornare `pubspec.yaml` con sezione `assets:`

---

## Step 4 — Layer API (`lib/core/api/`)

- [ ] `api_client.dart`: Dio con base URL da `--dart-define=API_BASE_URL`, interceptor X-Session-Token
- [ ] Interceptor errori: 401 → logout forzato; 503 → navigazione a pagina manutenzione
- [ ] `auth_api.dart`: login (`/_allauth/app/v1/auth/login`), MFA, logout
- [ ] `me_api.dart`: `GET /api/v1/me`
- [ ] `diari_api.dart`: lista, dettaglio, PUT moduli 1–5, PUT relazione finale, POST azioni FSM
- [ ] `evaluations_api.dart`: GET/POST valutazione, assegna PGV, proposta, conferma, rigetto, pubblica
- [ ] `editions_api.dart`: lista edizioni, dettaglio
- [ ] `org_api.dart`: albero organizzativo

---

## Step 5 — Modelli (`lib/core/models/`)

- [ ] `utente.dart`: pk, email, nome, cognome, ruolo, ruolo_display
- [ ] `edizione.dart`: pk, nome, stato, scadenza_1, scadenza_2
- [ ] `diario.dart`: pk, squadriglia, edizione, tipo, stato, stato_display, pubblicato, version + enum StatoDiario
- [ ] `moduli.dart`: Anagrafica, Presentazione, Impresa, Missione (con version + data)
- [ ] `relazione_finale.dart`: sintesi imprese, considerazioni, specialita_conquistata
- [ ] `valutazione.dart`: esito, stato, note, pubblicata, assegnazioni PGV
- [ ] `org.dart`: Zona → Gruppo → Reparto → Squadriglia
- [ ] Tutti con `fromJson`/`toJson` manuali (no code generation)

---

## Step 6 — Autenticazione e gate biometrico

- [ ] `lib/core/auth/auth_service.dart`: login, logout, leggi/salva token, check sessione (`GET /me`)
- [ ] `lib/features/auth/login_page.dart`: form email/password, gestione errori
- [ ] `lib/features/auth/mfa_page.dart`: inserimento codice TOTP a 6 cifre
- [ ] `lib/features/auth/biometric_gate_page.dart`: FaceID/TouchID con fallback a PIN
- [ ] `lib/features/auth/pin_setup_page.dart`: setup PIN 6 cifre al primo accesso
- [ ] `lib/features/auth/pin_page.dart`: inserimento PIN con hash SHA-256 + salt
- [ ] Timeout 5 minuti in background → ripresenta gate (`AppLifecycleListener`)
- [ ] `BiometricSetupPage`: chiede se abilitare biometria; se rifiutata, PIN obbligatorio

---

## Step 7 — Navigazione (`go_router`)

- [ ] Route guard `authGuard`: nessun token → `/login`
- [ ] Route guard `biometricGuard`: token presente ma gate non superato → `/gate`
- [ ] Rotte: `/login`, `/mfa`, `/gate`, `/pin`, `/pin-setup`
- [ ] Rotte protette: `/home`, `/diari`, `/diari/:id`, `/diari/:id/modulo/:n`, `/edizioni`, `/edizioni/:id`, `/org`, `/profilo`

---

## Step 8 — Schermate core (diari)

- [ ] `DiariListPage`: lista diari, filtri edizione/stato, paginazione, pull-to-refresh
- [ ] `DiarioDetailPage`: dettaglio read-only, tutti i moduli visibili per ruolo, badge stato FSM
- [ ] `Modulo1EditPage` (Anagrafica): form reactive, optimistic locking, dialog su 409 Conflict
- [ ] `Modulo2EditPage` (Presentazione)
- [ ] `ImpreseEditPage` (Impresa 1 e 2 — impresa 2 opzionale per rinnovo)
- [ ] `MissioneEditPage` (opzionale per rinnovo)
- [ ] `RelazioneFinaleEditPage` (solo CRP, nessun optimistic locking)
- [ ] Dialog conferma azioni FSM: "Invia la tua parte" (CSQ), "Invia al valutatore" (CRP), "Riapri" (staff)

---

## Step 9 — Valutazione

- [ ] `ValutazionePage`: visibilità condizionale per ruolo
- [ ] Form valutazione diretta (Incaricato EG / Admin / Segreteria)
- [ ] Form proposta PGV (`approvato` / `non_approvato` — no `maggiori_info`)
- [ ] Conferma proposta PGV (Incaricato EG / Admin)
- [ ] Rigetto proposta PGV
- [ ] Modifica esito pre-pubblicazione
- [ ] Bottone pubblica esito

---

## Step 10 — Schermate secondarie

- [ ] `EdizioniListPage` + `EdizioneDetailPage`
- [ ] `AlberoOrgPage`: zona → gruppo → reparto → squadriglia (TreeView espandibile)
- [ ] `ProfiloPage`: nome, ruolo, logout; link "Cambia password" apre il sito web

---

## Step 11 — Gestione errori e UX

- [ ] Pagina "Servizio in manutenzione" (503) — non dialog, schermata dedicata
- [ ] Banner offline con timestamp ultimo aggiornamento (cache in memoria, niente disco)
- [ ] Loading skeleton su list e detail page
- [ ] Empty state con messaggio e illustrazione

---

## Step 12 — Localizzazione

- [ ] `AppLocalizations` con `lib/l10n/app_it.arb`
- [ ] Stringhe: stati FSM (non_iniziato → "Non iniziato", ecc.), ruoli, messaggi errore API
- [ ] Solo lingua italiana per v1

---

## Step 13 — Configurazione build (flavor dev/prod)

- [ ] Flavor `dev`: `API_BASE_URL=http://localhost:8000`, icona con badge "DEV"
- [ ] Flavor `prod`: `API_BASE_URL=https://plancia.agescicampania.org`
- [ ] `--dart-define=API_BASE_URL` leggibile da `String.fromEnvironment`
- [ ] Firme Android (keystore) e iOS (provisioning profile) — da configurare al primo rilascio

---

## Step 14 — Test e verifica

- [ ] Test widget: gate biometrico, login flow, dialog conflitto 409
- [ ] Test integration: login → lista diari → dettaglio → modifica modulo 1 → invia
- [ ] Verifica su simulatore iOS (Xcode) e emulatore Android (AVD)
- [ ] Verifica invisibilità modulo 6 e valutazione non pubblicata per CSQ
- [ ] Verifica schermata manutenzione (abilitare modo manutenzione dal backend)
- [ ] Verifica gate biometrico dopo 5 minuti in background

---

## Step 15 — Distribuzione

- [ ] App Store Connect: nuovo bundle `org.antaresnet.appgv`, screenshot, descrizione italiana
- [ ] Google Play Console: nuovo package, screenshot, descrizione
- [ ] Verificare `CORS_ALLOWED_ORIGINS` in produzione Plancia (aggiungere schema app mobile se necessario)
- [ ] Aggiornare `../plancia/docs/api/overview.md` con note su client mobile
