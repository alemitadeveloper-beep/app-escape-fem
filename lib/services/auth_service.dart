// lib/services/auth_service.dart
class AuthService {
  static bool isLoggedIn = false;
  static String username = '';

  static void login(String email) {
    isLoggedIn = true;
    username = email;
  }

  static void logout() {
    isLoggedIn = false;
    username = '';
  }
}