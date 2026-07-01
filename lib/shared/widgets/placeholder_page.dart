import 'package:flutter/material.dart';

/// Segnaposto per le rotte protette non ancora implementate (Step 8–10,
/// vedi TODO.md). Sostituita dalla schermata reale quando il relativo step
/// viene realizzato.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          subtitle == null ? 'Prossimamente' : '$title\n$subtitle',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
