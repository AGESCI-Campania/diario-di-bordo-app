import 'package:flutter/material.dart';

import 'core/theme/plancia_theme.dart';

void main() {
  runApp(const DiariApp());
}

class DiariApp extends StatelessWidget {
  const DiariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diari di Bordo',
      theme: PlanciaTheme.light,
      home: const Scaffold(body: Center(child: Text('Diari di Bordo'))),
    );
  }
}
