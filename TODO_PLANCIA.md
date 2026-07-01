# TODO_PLANCIA — Modifiche da portare nel backend Plancia

Questo file traccia le incongruenze/bug scoperti lavorando sull'app Flutter
**Diari di Bordo** che riguardano il backend Django
([`plancia`](https://github.com/AGESCI-Campania/plancia), checkout locale
in `../plancia/`) e che andrebbero eventualmente portati anche lì, per
mantenere coerenza tra web app e app mobile.

Non è una todo-list dell'app Flutter (quella è in `TODO.md`): qui finiscono
solo gli interventi che si applicano al repo
[`plancia`](https://github.com/AGESCI-Campania/plancia).

---

## Aperti

- [ ] **Forma di `relazione_finale` non documentata dentro `GET /diari/{pk}`**
  - **Dove**: `docs/api/endpoints.md`, sezione `GET /diari/{pk}` vs
    `PUT /diari/{pk}/relazione-finale`.
  - **Problema**: il PUT ha request/response `{"data": {...}}` (nessun
    `version`, a differenza dei moduli 1–5). L'esempio di `GET /diari/{pk}`
    mostra solo `"relazione_finale": null` e non chiarisce se, quando
    valorizzato, il campo sia annidato come `{"data": {...}}` oppure come
    oggetto piatto `{sintesi_impresa1: ..., ...}`.
  - **Assunzione fatta nell'app Flutter**: `lib/core/models/relazione_finale.dart`
    (`RelazioneFinale.fromJson`) si aspetta l'oggetto piatto, coerente con
    l'assenza di `version`. Da verificare contro una risposta reale
    dell'API prima dello Step 8 (schermate); se il backend annida in
    `{"data": {...}}` va aggiunto un livello di unwrap in `DiarioDetail.fromJson`
    (`lib/core/models/diario.dart`).
  - **Fix proposto**: aggiungere un esempio esplicito in
    `docs/api/endpoints.md` per `relazione_finale` valorizzato dentro
    `GET /diari/{pk}`.

- [x] **Badge stato `maggiori_info` grigio invece di giallo/arancio**
  - **Dove**: `templates/diaries/list.html` e `templates/diaries/detail.html`,
    blocco `{% if diario.stato == ... %}` per il badge Bootstrap.
  - **Problema**: lo stato `maggiori_info` non ha un `elif` dedicato e ricade
    nell'`else` → `bg-secondary` (grigio), lo stesso colore di
    `non_iniziato`. Semanticamente dovrebbe essere un colore di attenzione
    (giallo/arancio), come già usato per `relazione_finale` / `in_valutazione`
    / `in_revisione` (`bg-warning`).
  - **Fix proposto**: aggiungere
    `{% elif diario.stato == 'maggiori_info' %}bg-warning text-dark`
    prima dell'`{% else %}` in entrambi i template.
  - **Stato nell'app Flutter**: già corretto in
    `lib/shared/widgets/stato_badge.dart` (usa `PlanciaColors.statoWarning`
    per `maggiori_info`), così le due UI sono divergenti finché il fix non
    viene portato anche sulla web app.

---

## Portati

- Badge `maggiori_info` → `bg-warning text-dark` in `list.html` e `detail.html` (allineato all'app Flutter)
