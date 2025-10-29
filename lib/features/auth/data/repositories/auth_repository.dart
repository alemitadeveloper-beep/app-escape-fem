import 'package:shared_preferences/shared_preferences.dart';

/// Repository para gestión de autenticación con persistencia
class AuthRepository {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';

  /// Verifica si el usuario está autenticado
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Obtiene el nombre de usuario guardado
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  /// Obtiene el email guardado
  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  /// Guarda la sesión del usuario
  Future<void> saveSession({
    required String email,
    String? username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyEmail, email);
    if (username != null) {
      await prefs.setString(_keyUsername, username);
    }
  }

  /// Cierra la sesión del usuario
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyEmail);
  }

  /// Login del usuario (simulado, sin validación real)
  Future<bool> login(String email, String password) async {
    // TODO: Implementar validación real de credenciales
    // Por ahora, acepta cualquier email/password
    if (email.isNotEmpty && password.isNotEmpty) {
      await saveSession(email: email, username: email.split('@')[0]);
      return true;
    }
    return false;
  }

  /// Logout del usuario
  Future<void> logout() async {
    await clearSession();
  }
}
