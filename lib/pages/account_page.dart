import 'package:flutter/material.dart';
import 'package:escape_room_application/services/auth_service.dart';
import 'package:escape_room_application/models/avatar.dart';
import 'package:escape_room_application/pages/avatar_selection_page.dart';
import 'package:escape_room_application/pages/database_utils_page.dart';
import 'package:escape_room_application/features/groups/presentation/pages/groups_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    // Usa directamente AuthService.username
    final String username = AuthService.username.isNotEmpty ? AuthService.username : 'Usuario';
    final Avatar currentAvatar = Avatar.findById(AuthService.avatarId) ?? Avatar.defaultAvatar;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi cuenta'),
        backgroundColor: const Color(0xFF000D17),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de perfil con avatar
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AvatarSelectionPage(),
                        ),
                      );
                      // Refrescar la página si se cambió el avatar
                      if (result == true && mounted) {
                        setState(() {});
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Colors.blue,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          currentAvatar.emoji,
                          style: const TextStyle(fontSize: 50),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentAvatar.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AvatarSelectionPage(),
                        ),
                      );
                      if (result == true && mounted) {
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Cambiar avatar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Bienvenida,', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Ajustes', style: TextStyle(fontSize: 18)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.orange),
              title: const Text('Debug Auth (temporal)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, '/debug-auth');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.green),
              title: const Text('Mis Grupos'),
              subtitle: const Text('Gestiona tus grupos de escape rooms', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GroupsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.amber),
              title: const Text('Mis Logros'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, '/achievements');
              },
            ),
            ListTile(
              leading: const Icon(Icons.storage, color: Colors.blue),
              title: const Text('Gestión de Base de Datos'),
              subtitle: const Text('Importar y actualizar datos', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DatabaseUtilsPage(),
                  ),
                );
              },
            ),
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
              onTap: () async {
                await AuthService.logout(); // ⬅️ importante
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF000D17),
        onPressed: () async {
          await AuthService.logout(); // ⬅️ también aquí por si lo usas
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
