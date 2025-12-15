import 'package:flutter/material.dart';
import '../../domain/services/group_service.dart';
import '../../data/models/group.dart';
import '../../data/models/group_member.dart';
import '../../utils/auth_helper.dart';

class InviteMembersPage extends StatefulWidget {
  final int groupId;

  const InviteMembersPage({required this.groupId, super.key});

  @override
  State<InviteMembersPage> createState() => _InviteMembersPageState();
}

class _InviteMembersPageState extends State<InviteMembersPage> {
  final GroupService _groupService = GroupService();
  final _usernameController = TextEditingController();
  final _messageController = TextEditingController();

  EscapeGroup? _group;
  List<GroupMember> _currentMembers = [];
  List<String> _selectedUsers = [];
  bool _isLoading = true;
  bool _isSending = false;

  // Lista simulada de usuarios disponibles (en producción vendría de un servicio)
  final List<String> _availableUsers = [
    'ui0', 'ui1', 'ui2', 'ui3', 'ui4',
    'maria_escape', 'juan_rooms', 'ana_detective',
    'carlos_enigma', 'laura_mystery', 'pablo_adventure'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final group = await _groupService.getGroup(widget.groupId);
      final members = await _groupService.getGroupMembers(widget.groupId);

      setState(() {
        _group = group;
        _currentMembers = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  List<String> get _usersToInvite {
    final memberUsernames = _currentMembers.map((m) => m.username).toSet();
    return _availableUsers.where((u) => !memberUsernames.contains(u)).toList();
  }

  Future<void> _sendInvitations() async {
    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un usuario')),
      );
      return;
    }

    setState(() => _isSending = true);

    int successCount = 0;
    int failCount = 0;

    for (final username in _selectedUsers) {
      final success = await _groupService.sendInvitation(
        groupId: widget.groupId,
        recipientUsername: username,
        senderUsername: AuthHelper.getCurrentUsername(),
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
      );

      if (success) {
        successCount++;
      } else {
        failCount++;
      }
    }

    setState(() => _isSending = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invitaciones enviadas: $successCount${failCount > 0 ? ", fallidas: $failCount" : ""}',
          ),
        ),
      );

      if (successCount > 0) {
        Navigator.pop(context, true);
      }
    }
  }

  void _toggleUser(String username) {
    setState(() {
      if (_selectedUsers.contains(username)) {
        _selectedUsers.remove(username);
      } else {
        _selectedUsers.add(username);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedUsers.length == _usersToInvite.length) {
        _selectedUsers.clear();
      } else {
        _selectedUsers = List.from(_usersToInvite);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Invitar Miembros'),
          backgroundColor: const Color(0xFF000D17),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_group == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: const Color(0xFF000D17),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Grupo no encontrado')),
      );
    }

    final usersToInvite = _usersToInvite;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitar Miembros'),
        backgroundColor: const Color(0xFF000D17),
        foregroundColor: Colors.white,
        actions: [
          if (usersToInvite.isNotEmpty)
            TextButton(
              onPressed: _selectAll,
              child: Text(
                _selectedUsers.length == usersToInvite.length
                    ? 'Deseleccionar todos'
                    : 'Seleccionar todos',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Header con info del grupo
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.group, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _group!.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_currentMembers.length} miembros actuales',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Mensaje opcional
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Mensaje de invitación (opcional)',
                hintText: '¡Únete a nuestro grupo!',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.message),
                helperText: 'Este mensaje se enviará con la invitación',
              ),
              maxLines: 2,
            ),
          ),

          // Lista de usuarios
          Expanded(
            child: usersToInvite.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay usuarios disponibles',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Todos los usuarios ya son miembros',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: usersToInvite.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final username = usersToInvite[index];
                      final isSelected = _selectedUsers.contains(username);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: isSelected ? Colors.blue[50] : null,
                        child: CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) => _toggleUser(username),
                          title: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: isSelected
                                    ? Colors.blue[700]
                                    : Colors.grey[400],
                                child: Text(
                                  username[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  username,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Footer con botón de enviar
          if (usersToInvite.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedUsers.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '${_selectedUsers.length} usuario${_selectedUsers.length != 1 ? "s" : ""} seleccionado${_selectedUsers.length != 1 ? "s" : ""}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSending || _selectedUsers.isEmpty
                          ? null
                          : _sendInvitations,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        _isSending
                            ? 'Enviando...'
                            : 'Enviar ${_selectedUsers.length} invitación${_selectedUsers.length != 1 ? "es" : ""}',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
