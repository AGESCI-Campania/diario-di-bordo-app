# Diari di Bordo

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B.svg?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.11%2B-0175C2.svg?logo=dart&logoColor=white)](https://dart.dev/)
[![Riverpod](https://img.shields.io/badge/state-Riverpod-1B1B1F.svg)](https://riverpod.dev/)
[![go_router](https://img.shields.io/badge/routing-go__router-4285F4.svg)](https://pub.dev/packages/go_router)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-lightgrey.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

App mobile Flutter per la gestione dei **Guidoncini Verdi** — AGESCI Campania, Branca E/G.
Consente a Capi Squadriglia, Capi Reparto, Pattuglia GV, Incaricati EG e Segreteria di
consultare e compilare i Diari di Bordo tramite le API REST della piattaforma **Plancia**.

> Guida per l'implementazione assistita: [`CLAUDE.md`](CLAUDE.md).
> Avanzamento sviluppo: [`TODO.md`](TODO.md).

## Stack

Flutter 3.x · Dart 3.x · Riverpod (`hooks_riverpod`) · go_router · Dio · flutter_secure_storage ·
local_auth (FaceID/TouchID/Fingerprint) · reactive_forms · intl.

## Identificativi

|            |                        |
| ---------- | ---------------------- |
| Bundle ID  | `org.antaresnet.appgv` |
| API target | Plancia `/api/v1/`     |
| Backend    | `plancia` (Django)     |

## Avvio rapido

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=https://... # URL API esplicito, mai hardcodato
```

Altri comandi utili in [`CLAUDE.md`](CLAUDE.md#comandi-utili).

## Licenza

Distribuito sotto licenza [MIT](LICENSE).
