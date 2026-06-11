import 'package:shared_preferences/shared_preferences.dart';

/// Utility class untuk menyimpan dan membaca auth token secara persisten.
/// Menggunakan SharedPreferences (key-value storage lokal).
class TokenStorage {
  static const String _tokenKey = 'auth_token';

  /// Simpan token ke storage lokal
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Ambil token yang sudah tersimpan. Return null jika belum login.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Cek apakah user sudah login (ada token tersimpan)
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Hapus token saat logout
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
