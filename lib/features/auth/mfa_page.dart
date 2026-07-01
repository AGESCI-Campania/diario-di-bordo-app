import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/api/api_exceptions.dart';
import '../../core/auth/auth_state.dart';

/// Secondo fattore TOTP (`/_allauth/app/v1/auth/2fa/authenticate`, vedi
/// CLAUDE.md — Autenticazione, sezione MFA). Aperta da [LoginPage] quando
/// `AuthResult.requiresMfa` è vero, usando il token provvisorio già salvato
/// da `AuthService.login`.
class MfaPage extends ConsumerStatefulWidget {
  const MfaPage({super.key});

  @override
  ConsumerState<MfaPage> createState() => _MfaPageState();
}

class _MfaPageState extends ConsumerState<MfaPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    try {
      final result = await ref
          .read(authNotifierProvider.notifier)
          .authenticateMfa(_codeController.text.trim());
      if (!mounted) return;
      if (result.isAuthenticated) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errorText = result.errors.isNotEmpty
              ? result.errors.join('\n')
              : 'Codice non valido';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = apiExceptionOf(e).message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifica in due passaggi')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Inserisci il codice a 6 cifre generato dall'app di autenticazione.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    decoration: const InputDecoration(counterText: ''),
                    validator: (value) => (value == null || value.length != 6)
                        ? 'Inserisci un codice a 6 cifre'
                        : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verifica'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
