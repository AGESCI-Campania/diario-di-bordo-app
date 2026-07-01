import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/auth/gate_state.dart';
import 'biometric_setup_page.dart';
import 'pin_setup_page.dart';

/// Primo accesso dopo il login: PIN obbligatorio, poi scelta biometria
/// (vedi CLAUDE.md — Step 6). Al termine sblocca il gate — la redirect di
/// `app_router.dart` porta poi automaticamente in `/home`.
class FirstAccessPage extends ConsumerStatefulWidget {
  const FirstAccessPage({super.key});

  @override
  ConsumerState<FirstAccessPage> createState() => _FirstAccessPageState();
}

class _FirstAccessPageState extends ConsumerState<FirstAccessPage> {
  bool _pinSet = false;

  @override
  Widget build(BuildContext context) {
    if (!_pinSet) {
      return PinSetupPage(onDone: () => setState(() => _pinSet = true));
    }
    return BiometricSetupPage(
      onDone: () => ref.read(gateNotifierProvider.notifier).unlock(),
    );
  }
}
