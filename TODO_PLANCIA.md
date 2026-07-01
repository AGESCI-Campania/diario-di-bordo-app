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
