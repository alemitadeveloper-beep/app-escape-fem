import 'package:flutter/material.dart';
import '../../domain/services/group_service.dart';
import '../../../../services/auth_service.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _routeNameController = TextEditingController();
  final GroupService _groupService = GroupService();
  bool _isCreating = false;
  bool _isPublic = true; // Por defecto público

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _routeNameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      await _groupService.createGroup(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        adminUsername: AuthService.username,
        routeName: _routeNameController.text.trim().isEmpty
            ? null
            : _routeNameController.text.trim(),
        isPublic: _isPublic,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grupo creado exitosamente')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear grupo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Grupo'),
        backgroundColor: const Color(0xFF000D17),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Campos de texto sin Card
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del grupo *',
                hintText: 'Ej: Los Escapistas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.group),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _routeNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la ruta (opcional)',
                hintText: 'Ej: Ruta País Vasco',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.route),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                hintText: 'Describe el propósito del grupo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La descripción es obligatoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            // Selector de visibilidad simplificado
            Text(
              'Visibilidad',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _isPublic,
              onChanged: (value) => setState(() => _isPublic = value),
              title: Row(
                children: [
                  Icon(
                    _isPublic ? Icons.public : Icons.lock,
                    size: 20,
                    color: _isPublic ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(_isPublic ? 'Grupo Público' : 'Grupo Privado'),
                ],
              ),
              subtitle: Text(
                _isPublic
                    ? 'Cualquiera puede unirse directamente'
                    : 'Solo por invitación del administrador',
                style: const TextStyle(fontSize: 13),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isCreating ? null : _createGroup,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: _isCreating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear Grupo'),
            ),
          ],
        ),
      ),
    );
  }
}
