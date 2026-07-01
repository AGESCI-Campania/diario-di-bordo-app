import 'package:flutter/material.dart';

/// Palette AGESCI Campania, condivisa con la web app Plancia.
abstract final class PlanciaColors {
  static const verdePrimario = Color(0xFF5AA02C);
  static const verdeScuro = Color(0xFF3D8E33);
  static const violaIstituz = Color(0xFF7A1E99);
  static const gialloOro = Color(0xFFFFCC1E);

  /// Colori badge stato FSM del Diario, mappati 1:1 sulle classi Bootstrap
  /// usate dalla web app (`templates/diaries/{list,detail}.html`).
  static const statoSecondary = Color(0xFF6C757D); // bg-secondary
  static const statoInfo = Color(0xFF0DCAF0); // bg-info
  static const statoWarning = Color(0xFFFFC107); // bg-warning
  static const statoPrimary = Color(0xFF0D6EFD); // bg-primary
  static const statoSuccess = Color(0xFF198754); // bg-success
  static const statoDanger = Color(0xFFDC3545); // bg-danger
}
