import 'package:local_auth/local_auth.dart';

/// Wrapper su `local_auth` — FaceID / TouchID / Fingerprint.
class BiometricService {
  BiometricService([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// `true` se il device supporta e ha almeno un metodo biometrico
  /// registrato (non solo "hardware capace").
  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Richiede l'autenticazione biometrica. Ritorna `false` sia su
  /// annullamento dell'utente sia su errore/mancanza hardware — la UI
  /// deve sempre offrire il fallback PIN in entrambi i casi.
  Future<bool> authenticate({String reason = 'Sblocca Diari di Bordo'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
