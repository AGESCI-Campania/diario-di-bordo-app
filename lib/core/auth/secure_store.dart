import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper unico su [FlutterSecureStorage] per Keychain/Keystore.
///
/// Ci finiscono solo credenziali locali (token di sessione, hash+salt del
/// PIN, preferenza biometria) — mai dati applicativi (diari, valutazioni),
/// vedi CLAUDE.md — "Cosa NON fare".
class SecureStore {
  const SecureStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const _sessionTokenKey = 'session_token';
  static const _pinHashKey = 'pin_hash';
  static const _pinSaltKey = 'pin_salt';
  static const _biometricEnabledKey = 'biometric_enabled';

  Future<String?> readSessionToken() => _storage.read(key: _sessionTokenKey);

  Future<void> writeSessionToken(String token) =>
      _storage.write(key: _sessionTokenKey, value: token);

  Future<void> deleteSessionToken() => _storage.delete(key: _sessionTokenKey);

  Future<String?> readPinHash() => _storage.read(key: _pinHashKey);

  Future<String?> readPinSalt() => _storage.read(key: _pinSaltKey);

  Future<void> writePin({required String hash, required String salt}) async {
    await _storage.write(key: _pinHashKey, value: hash);
    await _storage.write(key: _pinSaltKey, value: salt);
  }

  Future<void> deletePin() async {
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _pinSaltKey);
  }

  Future<bool> readBiometricEnabled() async =>
      await _storage.read(key: _biometricEnabledKey) == 'true';

  Future<void> writeBiometricEnabled(bool enabled) =>
      _storage.write(key: _biometricEnabledKey, value: enabled.toString());

  /// Cancella tutto lo stato locale (logout, o 401 inaspettato).
  Future<void> clearAll() async {
    await _storage.delete(key: _sessionTokenKey);
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _pinSaltKey);
    await _storage.delete(key: _biometricEnabledKey);
  }
}
