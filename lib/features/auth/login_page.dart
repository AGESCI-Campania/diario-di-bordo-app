import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/api/api_exceptions.dart';
import '../../core/auth/auth_state.dart';
import '../../core/models/app_status.dart';
import '../../shared/widgets/upgrade_banner.dart';
import 'mfa_page.dart';

/// Login app-mode (`/_allauth/app/v1/auth/login`, vedi CLAUDE.md —
/// Autenticazione). Se il risultato richiede MFA apre [MfaPage]; se il
/// login riesce del tutto, non fa nulla di esplicito: `AuthNotifier`
/// aggiorna lo stato globale e il widget radice (`_AuthGate` in
/// `main.dart`) smonta questa pagina reattivamente.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.appStatus});

  final AppStatus? appStatus;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;
  bool _bannerDismissed = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;
      if (result.requiresMfa) {
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MfaPage()));
      } else if (!result.isAuthenticated) {
        setState(() {
          _errorText = result.errors.isNotEmpty
              ? result.errors.join('\n')
              : 'Credenziali non valide';
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
    final status = widget.appStatus;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (status != null && !_bannerDismissed)
              UpgradeBanner(
                status: status,
                onDismiss: () => setState(() => _bannerDismissed = true),
              ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Diari di Bordo',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? 'Inserisci la tua email'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            autofillHints: const [AutofillHints.password],
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Inserisci la password'
                                : null,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                          if (_errorText != null) ...[
                            const SizedBox(height: 16),
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Accedi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
