import 'package:flutter/material.dart';
import 'package:escape_room_application/services/firebase_auth_service.dart';
import 'package:escape_room_application/models/avatar.dart';
import 'package:escape_room_application/pages/avatar_selection_page.dart';
import 'package:escape_room_application/pages/database_utils_page.dart';
import 'package:escape_room_application/pages/admin_escape_rooms_page.dart';
import 'package:escape_room_application/features/groups/presentation/pages/groups_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:escape_room_application/features/escape_rooms/data/datasources/word_database.dart';
import 'package:escape_room_application/features/escape_rooms/data/datasources/firestore_escape_rooms_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    // Obtener username directamente de Firebase Auth (sin Firestore)
    final String username = _authService.username.isNotEmpty ? _authService.username : 'Usuario';
    // Por ahora usar avatar por defecto (sin consultar Firestore)
    final Avatar currentAvatar = Avatar.defaultAvatar;

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
              leading: const Icon(Icons.cloud_sync, color: Colors.blue),
              title: const Text('Sincronizar datos con la nube'),
              subtitle: const Text('Subir todos tus datos locales a Firestore', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                try {
                  // Mostrar loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔄 Sincronizando datos con Firestore...'),
                      duration: Duration(seconds: 3),
                    ),
                  );

                  // Sincronizar todos los datos locales con Firestore
                  await _authService.syncLocalDataToFirestore();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Todos tus datos han sido sincronizados con la nube!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error al sincronizar: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload, color: Colors.purple),
              title: const Text('[ADMIN] Migrar catálogo completo a Firestore'),
              subtitle: const Text('Subir los 761 escape rooms a la nube (solo una vez)', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                // Confirmación antes de ejecutar
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('⚠️ Confirmación'),
                    content: const Text(
                      '¿Estás segura de que quieres subir los 761 escape rooms a Firestore?\n\n'
                      'Esta operación:\n'
                      '• Subirá TODO el catálogo a la nube\n'
                      '• Puede tardar varios minutos\n'
                      '• Solo debe ejecutarse UNA VEZ\n\n'
                      '¿Continuar?'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                        child: const Text('Sí, migrar catálogo'),
                      ),
                    ],
                  ),
                );

                if (confirm != true || !mounted) return;

                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔄 Migrando 761 escape rooms a Firestore... Esto puede tardar varios minutos'),
                      duration: Duration(seconds: 5),
                    ),
                  );

                  // Importar los servicios necesarios
                  final database = WordDatabase.instance;
                  final firestoreService = FirestoreEscapeRoomsService();

                  // Obtener todos los escape rooms de SQLite
                  final allEscapeRooms = await database.readAllWords();
                  print('📊 Total de escape rooms en SQLite: ${allEscapeRooms.length}');

                  // Subir a Firestore
                  await firestoreService.uploadAllEscapeRooms(allEscapeRooms);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ ¡Migración completada! ${allEscapeRooms.length} escape rooms subidos a Firestore'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 10),
                      ),
                    );
                  }
                } catch (e) {
                  print('❌ Error en migración: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error al migrar catálogo: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 10),
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.indigo),
              title: const Text('[ADMIN] Editar escape rooms'),
              subtitle: const Text('Modificar información del catálogo', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminEscapeRoomsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.orange),
              title: const Text('Verificar datos en Firestore'),
              subtitle: const Text('Ver qué hay guardado en la nube', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                try {
                  final uid = _authService.uid;
                  if (uid == null) {
                    throw Exception('No hay usuario autenticado');
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🔍 Consultando Firestore...'), duration: Duration(seconds: 3)),
                  );

                  // Leer TODAS las colecciones desde Firestore
                  final favoritesSnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('favorites')
                      .get();

                  final playedSnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('played')
                      .get();

                  final pendingSnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('pending')
                      .get();

                  final favoritesCount = favoritesSnapshot.docs.length;
                  final playedCount = playedSnapshot.docs.length;
                  final pendingCount = pendingSnapshot.docs.length;

                  final favoritesIds = favoritesSnapshot.docs.map((doc) => doc.id).toList();
                  final playedIds = playedSnapshot.docs.map((doc) => doc.id).toList();
                  final pendingIds = pendingSnapshot.docs.map((doc) => doc.id).toList();

                  // Obtener detalles de un documento de played para verificar
                  String playedDetails = '';
                  if (playedSnapshot.docs.isNotEmpty) {
                    final firstPlayed = playedSnapshot.docs.first.data();
                    playedDetails = '\n\nEjemplo de documento played (${playedSnapshot.docs.first.id}):\n'
                        'review: ${firstPlayed['review']}\n'
                        'personalRating: ${firstPlayed['personalRating']}\n'
                        'datePlayed: ${firstPlayed['datePlayed']}';
                  }

                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('📊 Datos en Firestore'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('⭐ Favoritos: $favoritesCount',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('IDs: ${favoritesIds.join(", ")}',
                                style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 12),

                              Text('🎮 Jugados: $playedCount',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('IDs: ${playedIds.join(", ")}',
                                style: const TextStyle(fontSize: 12)),
                              if (playedDetails.isNotEmpty)
                                Text(playedDetails,
                                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
                              const SizedBox(height: 12),

                              Text('⏳ Pendientes: $pendingCount',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('IDs: ${pendingIds.join(", ")}',
                                style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 16),

                              const Text('✅ Los datos SÍ están en Firestore!',
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const Text('Si no los ves en Firebase Console, intenta:\n'
                                  '• Hacer Cmd+Shift+R (Mac) o Ctrl+Shift+R (Windows)\n'
                                  '• Abrir Firebase Console en modo incógnito\n'
                                  '• Esperar unos minutos (cache del navegador)',
                                style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Error: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
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
                await _authService.signOut();
                // El StreamBuilder en main.dart detectará automáticamente el logout
                // y navegará a FirebaseLoginPage
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF000D17),
        onPressed: () async {
          await _authService.signOut();
          // El StreamBuilder en main.dart detectará automáticamente el logout
          // y navegará a FirebaseLoginPage
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
