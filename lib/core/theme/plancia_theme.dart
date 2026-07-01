import 'package:flutter/material.dart';

import 'plancia_colors.dart';

abstract final class PlanciaTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: PlanciaColors.verdePrimario,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
