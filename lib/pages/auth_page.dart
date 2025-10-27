import 'package:flutter/material.dart';
import 'package:escape_room_application/services/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLogin = true;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      AuthService.login(email);
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Iniciar sesión' : 'Crear cuenta'),
        backgroundColor: const Color(0xFF000D17),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                _isLogin ? 'Accede con tu email' : 'Regístrate con tu email',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty || !value.contains('@')) {
                    return 'Introduce un email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: Icon(_isLogin ? Icons.login : Icons.person_add),
                label: Text(_isLogin ? 'Entrar' : 'Crear cuenta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000D17),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _toggleMode,
                child: Text(
                  _isLogin
                      ? '¿No tienes cuenta? Regístrate'
                      : '¿Ya tienes cuenta? Inicia sesión',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}