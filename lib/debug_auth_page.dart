import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';

class DebugAuthPage extends StatefulWidget {
  const DebugAuthPage({super.key});

  @override
  State<DebugAuthPage> createState() => _DebugAuthPageState();
}

class _DebugAuthPageState extends State<DebugAuthPage> {
  String _status = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    final prefs = await SharedPreferences.getInstance();

    final storedIsLoggedIn = prefs.getBool('isLoggedIn');
    final storedUsername = prefs.getString('username');
    final storedEmail = prefs.getString('email');

    setState(() {
      _status = '''
=== SharedPreferences ===
isLoggedIn: $storedIsLoggedIn
username: $storedUsername
email: $storedEmail

=== AuthService (memoria) ===
isLoggedIn: ${AuthService.isLoggedIn}
username: ${AuthService.username}
''';
    });
  }

  Future<void> _simulateLogin() async {
    await AuthService.login('test@example.com');
    _loadDebugInfo();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login simulado!')),
      );
    }
  }

  Future<void> _simulateLogout() async {
    await AuthService.logout();
    _loadDebugInfo();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout realizado!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Auth'),
        backgroundColor: const Color(0xFF000D17),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado de Autenticación',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _simulateLogin,
              child: const Text('Simular Login'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _simulateLogout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Simular Logout'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadDebugInfo,
              child: const Text('Recargar Info'),
            ),
          ],
        ),
      ),
    );
  }
}
