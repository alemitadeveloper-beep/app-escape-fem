// lib/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static bool isLoggedIn = false;
  static String username = '';
  static String avatarId = 'detective'; // Avatar por defecto

  // Inicializar el estado desde SharedPreferences
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    username = prefs.getString('username') ?? '';
    avatarId = prefs.getString('avatarId') ?? 'detective';
    print('🔐 AuthService initialized - isLoggedIn: $isLoggedIn, username: $username, avatar: $avatarId');
  }

  static Future<void> login(String email) async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = true;
    username = email.split('@')[0];

    // Guardar en SharedPreferences
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    print('✅ AuthService login - isLoggedIn: $isLoggedIn, username: $username');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = false;
    username = '';

    // Limpiar SharedPreferences (pero mantener el avatar)
    await prefs.remove('isLoggedIn');
    await prefs.remove('username');
    await prefs.remove('email');
  }

  static Future<void> updateAvatar(String newAvatarId) async {
    final prefs = await SharedPreferences.getInstance();
    avatarId = newAvatarId;
    await prefs.setString('avatarId', newAvatarId);
    print('✅ Avatar actualizado a: $newAvatarId');
  }
}