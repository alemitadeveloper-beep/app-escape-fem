import 'package:flutter/material.dart';
import 'package:escape_room_application/services/auth_service.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usa directamente AuthService.username
    final String username = AuthService.username.isNotEmpty ? AuthService.username : 'Usuario';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi cuenta'),
        backgroundColor: const Color(0xFF000D17),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bienvenida,', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Ajustes', style: TextStyle(fontSize: 18)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Preferencias'),
              onTap: () {
                // Aquí puedes navegar a la página de configuración
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                AuthService.logout(); // ⬅️ importante
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF000D17),
        onPressed: () {
          AuthService.logout(); // ⬅️ también aquí por si lo usas
          Navigator.pushReplacementNamed(context, '/login');
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
