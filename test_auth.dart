import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final prefs = await SharedPreferences.getInstance();

  print('=== Estado actual de SharedPreferences ===');
  print('isLoggedIn: ${prefs.getBool('isLoggedIn')}');
  print('username: ${prefs.getString('username')}');
  print('email: ${prefs.getString('email')}');

  print('\n=== Guardando sesión de prueba ===');
  await prefs.setBool('isLoggedIn', true);
  await prefs.setString('username', 'alejandra');
  await prefs.setString('email', 'alejandra@test.com');

  print('isLoggedIn: ${prefs.getBool('isLoggedIn')}');
  print('username: ${prefs.getString('username')}');
  print('email: ${prefs.getString('email')}');

  print('\n✅ Sesión guardada! Ahora intenta correr la app.');
}
