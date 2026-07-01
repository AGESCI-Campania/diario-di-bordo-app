import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import 'secure_store.dart';

/// PIN locale a 6 cifre, fallback del gate biometrico.
///
/// Non è mai inviato al backend: è verificato solo sul device, contro un
/// hash SHA-256 salato salvato in Keychain/Keystore (vedi CLAUDE.md — "Non
/// bypassare il gate biometrico/PIN con logica lato app").
class PinService {
  PinService([this._store = const SecureStore()]);

  final SecureStore _store;

  static const pinLength = 6;

  Future<bool> hasPin() async => await _store.readPinHash() != null;

  Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hash(pin, salt);
    await _store.writePin(hash: hash, salt: salt);
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _store.readPinSalt();
    final storedHash = await _store.readPinHash();
    if (salt == null || storedHash == null) return false;
    return _hash(pin, salt) == storedHash;
  }

  Future<void> clearPin() => _store.deletePin();

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hash(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();
}
