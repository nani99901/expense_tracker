import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureCredentials {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  String _hash(String input, String salt) {
    return sha256.convert(utf8.encode(input + salt)).toString();
  }

  String _ns(String email, String suffix) => 'cred:${email.trim().toLowerCase()}:$suffix';

  Future<void> saveCredentials({required String email, required String password}) async {
    final salt = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = _hash(password, salt);
    await storage.write(key: _ns(email, 'hash'), value: hash);
    await storage.write(key: _ns(email, 'salt'), value: salt);
  }

  Future<bool> verify({required String email, required String password}) async {
    try {
      final savedHash = await storage.read(key: _ns(email, 'hash'));
      final salt = await storage.read(key: _ns(email, 'salt'));
      if (savedHash == null || salt == null) return false;
      return savedHash == _hash(password, salt);
    } on PlatformException {
      await clearForEmail(email);
      return false;
    }
  }

  Future<bool> hasAccount() async {
    try {
      final all = await storage.readAll();
      return all.keys.any((k) => k.startsWith('cred:') && k.endsWith(':hash'));
    } on PlatformException {
      await clearAll();
      return false;
    }
  }

  Future<void> clearAll() async {
    try {
      final all = await storage.readAll();
      for (final k in all.keys.where((k) => k.startsWith('cred:'))) {
        await storage.delete(key: k);
      }
    } on PlatformException {
      await storage.deleteAll();
    }
  }

  Future<void> clearForEmail(String email) async {
    await storage.delete(key: _ns(email, 'hash'));
    await storage.delete(key: _ns(email, 'salt'));
  }
}
