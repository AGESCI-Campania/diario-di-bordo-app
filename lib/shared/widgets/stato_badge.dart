import 'package:flutter/material.dart';

import '../../core/theme/plancia_colors.dart';

/// Badge colorato per lo stato FSM del Diario (`StatoDiario` lato backend).
///
/// Colori e label mappati sulla web app Plancia
/// (`templates/diaries/{list,detail}.html`), con l'eccezione di
/// `maggiori_info`: nella web app ricade nel grigio di default insieme a
/// `non_iniziato`, qui invece usa il colore d'attenzione (giallo/arancio).
class StatoBadge extends StatelessWidget {
  const StatoBadge({super.key, required this.stato});

  final String stato;

  static const _label = {
    'non_iniziato': 'Non iniziato',
    'in_compilazione': 'In compilazione',
    'relazione_finale': 'Relazione finale',
    'inviato': 'Inviato',
    'in_valutazione': 'In valutazione',
    'in_revisione': 'In revisione',
    'approvato': 'Approvato',
    'non_approvato': 'Non approvato',
    'maggiori_info': 'Maggiori informazioni richieste',
  };

  static const _color = {
    'non_iniziato': PlanciaColors.statoSecondary,
    'in_compilazione': PlanciaColors.statoInfo,
    'relazione_finale': PlanciaColors.statoWarning,
    'inviato': PlanciaColors.statoPrimary,
    'in_valutazione': PlanciaColors.statoWarning,
    'in_revisione': PlanciaColors.statoWarning,
    'approvato': PlanciaColors.statoSuccess,
    'non_approvato': PlanciaColors.statoDanger,
    'maggiori_info': PlanciaColors.statoWarning,
  };

  @override
  Widget build(BuildContext context) {
    final background = _color[stato] ?? PlanciaColors.statoSecondary;
    final label = _label[stato] ?? stato;
    final foreground = background == PlanciaColors.statoWarning ||
            background == PlanciaColors.statoInfo
        ? Colors.black
        : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
