#!/usr/bin/env dart

/// Script para sincronizar los escape rooms de SQLite a Firebase
///
/// Este script debe ejecutarse desde el directorio raíz del proyecto Flutter
void main() async {
  print('=' * 70);
  print('🔥 SINCRONIZACIÓN DE ESCAPE ROOMS A FIREBASE');
  print('=' * 70);
  print('');
  print('⚠️ IMPORTANTE:');
  print('Este script requiere que ejecutes la sincronización desde la app Flutter.');
  print('');
  print('📱 PASOS PARA SINCRONIZAR CON FIREBASE:');
  print('');
  print('1. Abre el simulador iOS y ejecuta la app Flutter');
  print('2. Inicia sesión como administrador');
  print('3. Ve a "Cuenta" > "Admin Panel"');
  print('4. Toca el botón "Migrar a Firebase"');
  print('5. Confirma la migración');
  print('');
  print('La app subirá automáticamente todos los escape rooms');
  print('de SQLite (incluyendo los 21 nuevos) a Firebase.');
  print('');
  print('=' * 70);
}
