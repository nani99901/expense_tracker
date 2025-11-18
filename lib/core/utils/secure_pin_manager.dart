import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurePinManager {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  String _hash(String pin, String salt) {
    return sha256.convert(utf8.encode(pin + salt)).toString();
  }

  Future<void> storePin(String pin) async {
    final salt = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = _hash(pin, salt);
    await storage.write(key: "pin_hash", value: hash);
    await storage.write(key: "pin_salt", value: salt);
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await storage.read(key: "pin_salt");
    final saved = await storage.read(key: "pin_hash");
    if (salt == null || saved == null) return false;
    return saved == _hash(pin, salt);
  }

  Future<void> clear() async {
    await storage.delete(key: "pin_hash");
    await storage.delete(key: "pin_salt");
  }

  Future<bool> hasPin() async {
    final saved = await storage.read(key: "pin_hash");
    return saved != null && saved.isNotEmpty;
  }
}
