import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }

  static Future<void> saveUserEmail(String email) async {
    await _storage.write(key: 'email', value: email);
  }

  static Future<String?> getUserEmail() async {
    return await _storage.read(key: 'email');
  }

  static Future<void> saveRole(String role) async {
    await _storage.write(key: 'role', value: role);
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: 'role');
  }
}
