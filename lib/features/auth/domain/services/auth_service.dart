import '../../data/repositories/auth_repository.dart';

/// Servicio de autenticación mejorado con persistencia
class AuthService {
  final AuthRepository _repository = AuthRepository();

  // Estado en memoria (cache)
  bool _isLoggedIn = false;
  String _username = '';
  String _email = '';

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get email => _email;

  /// Inicializa el servicio cargando el estado desde persistencia
  Future<void> initialize() async {
    _isLoggedIn = await _repository.isLoggedIn();
    if (_isLoggedIn) {
      _username = await _repository.getUsername() ?? '';
      _email = await _repository.getEmail() ?? '';
    }
  }

  /// Login del usuario
  Future<bool> login(String email, String password) async {
    final success = await _repository.login(email, password);
    if (success) {
      _isLoggedIn = true;
      _email = email;
      _username = email.split('@')[0];
      return true;
    }
    return false;
  }

  /// Logout del usuario
  Future<void> logout() async {
    await _repository.logout();
    _isLoggedIn = false;
    _username = '';
    _email = '';
  }

  /// Verifica si las credenciales son válidas (simulado)
  bool validateCredentials(String email, String password) {
    // TODO: Implementar validación real
    return email.isNotEmpty && password.isNotEmpty;
  }
}
