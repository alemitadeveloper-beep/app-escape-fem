import 'package:flutter/material.dart';
import '../../domain/services/group_service.dart';
import '../../data/models/group.dart';
import '../../utils/auth_helper.dart';

class EditGroupPage extends StatefulWidget {
  final EscapeGroup group;

  const EditGroupPage({required this.group, super.key});

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _routeNameController;
  final GroupService _groupService = GroupService();
  bool _isUpdating = false;
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.name);
    _descriptionController = TextEditingController(text: widget.group.description);
    _routeNameController = TextEditingController(text: widget.group.routeName ?? '');
    _isPublic = widget.group.isPublic;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _routeNameController.dispose();
    super.dispose();
  }

  Future<void> _updateGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    try {
      final updatedGroup = EscapeGroup(
        id: widget.group.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        adminUsername: widget.group.adminUsername,
        routeName: _routeNameController.text.trim().isEmpty
            ? null
            : _routeNameController.text.trim(),
        isPublic: _isPublic,
        createdAt: widget.group.createdAt,
      );

      final success = await _groupService.updateGroup(
        updatedGroup,
        AuthHelper.getCurrentUsername(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Grupo actualizado exitosamente')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No tienes permisos para editar este grupo')),
          );
        }
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar grupo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Grupo'),
        backgroundColor: const Color(0xFF000D17),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
              onPressed: _isUpdating ? null : _updateGroup,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: _isUpdating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
