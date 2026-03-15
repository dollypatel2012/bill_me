import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

class EncryptionHelper {
  static const _keyKey = 'db_encryption_key';
  static final _storage = FlutterSecureStorage();

  static Future<String> getKey() async {
    String? key = await _storage.read(key: _keyKey);
    if (key == null) {
      // Generate a random 32-byte key (for AES-256)
      final random = Random.secure();
      final bytes = List<int>.generate(32, (_) => random.nextInt(256));
      key = base64Url.encode(bytes);
      await _storage.write(key: _keyKey, value: key);
    }
    return key;
  }

  // If user sets a passcode, derive key from it
  static Future<void> setPasscode(String passcode) async {
    final bytes = utf8.encode(passcode);
    final key = sha256.convert(bytes).toString(); // 64 hex chars = 32 bytes
    await _storage.write(key: _keyKey, value: key);
  }
}