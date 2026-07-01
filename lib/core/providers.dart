import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'api/api_client.dart';
import 'api/api_config.dart';
import 'api/auth_api.dart';
import 'api/me_api.dart';
import 'api/system_api.dart';
import 'auth/auth_service.dart';
import 'auth/biometric_service.dart';
import 'auth/pin_service.dart';
import 'auth/secure_store.dart';
import 'models/app_status.dart';

final secureStoreProvider = Provider<SecureStore>((ref) => const SecureStore());

final pinServiceProvider = Provider<PinService>(
  (ref) => PinService(ref.watch(secureStoreProvider)),
);

final biometricServiceProvider = Provider<BiometricService>(
  (ref) => BiometricService(),
);

/// Contatore incrementato dall'interceptor su `401` inaspettato. [AuthNotifier]
/// lo osserva per forzare il logout reattivo senza che `ApiClient` debba
/// conoscere lo stato applicativo (evita un ciclo di dipendenze provider).
class SessionInvalidationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final sessionInvalidatedProvider =
    NotifierProvider<SessionInvalidationNotifier, int>(
      SessionInvalidationNotifier.new,
    );

final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStore = ref.watch(secureStoreProvider);
  return ApiClient(
    baseUrl: apiBaseUrl,
    getToken: secureStore.readSessionToken,
    onUnauthorized: () {
      // Solo il token: PIN e preferenza biometrica restano, sono legati al
      // device e non alla sessione scaduta (vedi `AuthService.forceLogout`).
      secureStore.deleteSessionToken();
      ref.read(sessionInvalidatedProvider.notifier).bump();
    },
  );
});

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(apiClientProvider)),
);

final meApiProvider = Provider<MeApi>(
  (ref) => MeApi(ref.watch(apiClientProvider)),
);

final systemApiProvider = Provider<SystemApi>(
  (ref) => SystemApi(ref.watch(apiClientProvider)),
);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    authApi: ref.watch(authApiProvider),
    meApi: ref.watch(meApiProvider),
    store: ref.watch(secureStoreProvider),
  ),
);

/// Controllo compatibilità versione al lancio (Plancia ≥ 2.3.0). Un errore
/// di rete non blocca l'avvio: si assume nessuna informazione di versione
/// disponibile e si prosegue al login (coerente con la gestione offline
/// generale dell'app, vedi CLAUDE.md).
final appStatusProvider = FutureProvider<AppStatus?>((ref) async {
  try {
    final json = await ref.watch(systemApiProvider).getAppStatus();
    return AppStatus.fromJson(json);
  } catch (_) {
    return null;
  }
});

/// `true` se il PIN locale è già configurato su questo device. Determina se
/// mostrare il flow di primo accesso (`PinSetupPage` → `BiometricSetupPage`)
/// invece del normale gate. Va invalidato esplicitamente dopo un logout
/// (vedi `AuthNotifier.logout`), perché il logout cancella anche il PIN.
class PinConfigurationNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(pinServiceProvider).hasPin();

  void markConfigured() => state = const AsyncData(true);
}

final pinConfiguredProvider =
    AsyncNotifierProvider<PinConfigurationNotifier, bool>(
      PinConfigurationNotifier.new,
    );
