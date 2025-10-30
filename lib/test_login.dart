// Script de prueba rápida para el login
// Ejecuta: flutter run lib/test_login.dart

import 'package:flutter/material.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=== TEST DE AUTENTICACIÓN ===\n');

  // 1. Inicializar
  print('1️⃣ Inicializando AuthService...');
  await AuthService.initialize();
  print('   isLoggedIn: ${AuthService.isLoggedIn}');
  print('   username: ${AuthService.username}\n');

  // 2. Hacer login
  print('2️⃣ Haciendo login con test@example.com...');
  await AuthService.login('test@example.com');
  print('   isLoggedIn: ${AuthService.isLoggedIn}');
  print('   username: ${AuthService.username}\n');

  // 3. Re-inicializar para simular reinicio de app
  print('3️⃣ Simulando reinicio de app (re-inicializar)...');
  AuthService.isLoggedIn = false; // Resetear memoria
  AuthService.username = '';
  await AuthService.initialize();
  print('   isLoggedIn después de reiniciar: ${AuthService.isLoggedIn}');
  print('   username después de reiniciar: ${AuthService.username}\n');

  if (AuthService.isLoggedIn) {
    print('✅ ¡ÉXITO! La sesión persiste después de reiniciar');
  } else {
    print('❌ ERROR: La sesión NO persiste después de reiniciar');
  }

  // 4. Logout
  print('\n4️⃣ Haciendo logout...');
  await AuthService.logout();
  print('   isLoggedIn: ${AuthService.isLoggedIn}');
  print('   username: ${AuthService.username}');

  print('\n=== FIN DEL TEST ===');
}
