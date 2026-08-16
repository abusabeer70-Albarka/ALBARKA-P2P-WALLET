import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppLockService {
  static const String _pinHashKey = 'app_pin_hash';

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin.trim());
    return sha256.convert(bytes).toString();
  }

  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final cleanPin = pin.trim();

    if (cleanPin.length != 6 ||
        int.tryParse(cleanPin) == null) {
      throw Exception('PIN must be exactly 6 digits.');
    }

    await _storage.write(
      key: _pinHashKey,
      value: _hashPin(cleanPin),
    );
  }

  Future<bool> verifyPin(String pin) async {
    final savedHash = await _storage.read(key: _pinHashKey);

    if (savedHash == null || savedHash.isEmpty) {
      return false;
    }

    return savedHash == _hashPin(pin);
  }

  Future<void> removePin() async {
    await _storage.delete(key: _pinHashKey);
  }
}
