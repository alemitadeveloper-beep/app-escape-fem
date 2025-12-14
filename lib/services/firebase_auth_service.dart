import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/escape_rooms/data/datasources/firestore_user_data_service.dart';
import '../features/escape_rooms/data/datasources/word_database.dart';

/// Servicio de autenticación usando Firebase Authentication
/// Maneja login, registro, logout y gestión de sesiones
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream del estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // ¿Está logueado?
  bool get isLoggedIn => currentUser != null;

  // Username del usuario actual
  String get username {
    // Primero intentar con displayName
    if (currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty) {
      return currentUser!.displayName!;
    }
    // Si no hay displayName, usar la parte del email antes del @
    if (currentUser?.email != null) {
      return currentUser!.email!.split('@').first;
    }
    return '';
  }

  // Email del usuario actual
  String? get email => currentUser?.email;

  // UID del usuario actual
  String? get uid => currentUser?.uid;

  // Avatar ID del usuario actual (se guarda en Firestore)
  Future<String> get avatarId async {
    if (uid == null) return 'detective';
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['avatarId'] ?? 'detective';
    } catch (e) {
      print('Error getting avatar ID: $e');
      return 'detective';
    }
  }

  /// Registrar nuevo usuario
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    String avatarId = 'detective',
  }) async {
    try {
      // Crear usuario en Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualizar el display name
      await userCredential.user?.updateDisplayName(username);

      // Intentar crear documento del usuario en Firestore (opcional)
      try {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': username,
          'email': email,
          'avatarId': avatarId,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
        print('✅ Datos de usuario guardados en Firestore');
      } catch (firestoreError) {
        print('⚠️ No se pudieron guardar datos en Firestore (esto no afecta el registro): $firestoreError');
        // Continuar sin fallar - el usuario ya está registrado en Auth
      }

      print('✅ Usuario registrado: $username ($email)');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Error al registrar: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Error inesperado al registrar: $e');
      rethrow;
    }
  }

  /// Login con email y contraseña
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Intentar actualizar última vez que inició sesión (opcional)
      try {
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
        print('✅ Última sesión actualizada en Firestore');
      } catch (firestoreError) {
        print('⚠️ No se pudo actualizar lastLogin en Firestore (esto no afecta el login): $firestoreError');
        // Continuar sin fallar - el usuario ya está logueado
      }

      print('✅ Usuario logueado: ${userCredential.user?.email}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Error al iniciar sesión: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Error inesperado al iniciar sesión: $e');
      rethrow;
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ Usuario deslogueado');
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
      rethrow;
    }
  }

  /// Enviar email de recuperación de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Email de recuperación enviado a: $email');
    } on FirebaseAuthException catch (e) {
      print('❌ Error al enviar email de recuperación: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Error inesperado al enviar email: $e');
      rethrow;
    }
  }

  /// Cambiar contraseña del usuario actual
  Future<void> changePassword(String newPassword) async {
    try {
      await currentUser?.updatePassword(newPassword);
      print('✅ Contraseña actualizada');
    } on FirebaseAuthException catch (e) {
      print('❌ Error al cambiar contraseña: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Error inesperado al cambiar contraseña: $e');
      rethrow;
    }
  }

  /// Actualizar avatar del usuario
  Future<void> updateAvatar(String avatarId) async {
    if (uid == null) throw Exception('Usuario no autenticado');
    try {
      await _firestore.collection('users').doc(uid).update({
        'avatarId': avatarId,
      });
      print('✅ Avatar actualizado: $avatarId');
    } catch (e) {
      print('❌ Error al actualizar avatar: $e');
      rethrow;
    }
  }

  /// Actualizar username del usuario
  Future<void> updateUsername(String newUsername) async {
    if (uid == null) throw Exception('Usuario no autenticado');
    try {
      await currentUser?.updateDisplayName(newUsername);
      await _firestore.collection('users').doc(uid).update({
        'username': newUsername,
      });
      print('✅ Username actualizado: $newUsername');
    } catch (e) {
      print('❌ Error al actualizar username: $e');
      rethrow;
    }
  }

  /// Eliminar cuenta del usuario actual
  Future<void> deleteAccount() async {
    if (uid == null) throw Exception('Usuario no autenticado');
    try {
      // Eliminar documento de Firestore
      await _firestore.collection('users').doc(uid).delete();
      // Eliminar usuario de Authentication
      await currentUser?.delete();
      print('✅ Cuenta eliminada');
    } on FirebaseAuthException catch (e) {
      print('❌ Error al eliminar cuenta: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Error inesperado al eliminar cuenta: $e');
      rethrow;
    }
  }

  /// Obtener datos del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (uid == null) return null;
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('❌ Error al obtener datos del usuario: $e');
      return null;
    }
  }

  /// Sincronizar datos locales con Firestore después del login
  Future<void> syncLocalDataToFirestore() async {
    if (uid == null) return;

    try {
      print('🔄 Iniciando sincronización de datos locales a Firestore...');

      final firestoreService = FirestoreUserDataService(userId: uid!);
      final allWords = await WordDatabase.instance.readAllWords();

      await firestoreService.syncFromSQLite(allWords);

      print('✅ Sincronización completada');
    } catch (e) {
      print('⚠️ Error al sincronizar datos: $e');
      // No lanzar error - la sincronización es opcional
    }
  }

  /// Manejar excepciones de Firebase Auth y convertirlas en mensajes legibles
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La contraseña es demasiado débil. Debe tener al menos 6 caracteres.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este email.';
      case 'invalid-email':
        return 'El email no es válido.';
      case 'user-not-found':
        return 'No existe ningún usuario con este email.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde.';
      case 'operation-not-allowed':
        return 'Operación no permitida. Contacta con soporte.';
      case 'requires-recent-login':
        return 'Esta operación requiere que hayas iniciado sesión recientemente. Por favor, vuelve a iniciar sesión.';
      default:
        return e.message ?? 'Error de autenticación desconocido.';
    }
  }
}
