import 'package:firebase_auth/firebase_auth.dart';

/// Helper para obtener información de autenticación de Firebase
class AuthHelper {
  /// Obtiene el username del usuario actual (parte antes del @ del email)
  static String getCurrentUsername() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return '';
    return currentUser.email?.split('@')[0] ?? '';
  }

  /// Verifica si hay un usuario autenticado
  static bool isAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Obtiene el email completo del usuario actual
  static String? getCurrentEmail() {
    return FirebaseAuth.instance.currentUser?.email;
  }
}
