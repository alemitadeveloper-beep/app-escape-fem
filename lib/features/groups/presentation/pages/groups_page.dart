import 'package:flutter/material.dart';
import '../../domain/services/group_service.dart';
import '../../data/models/group.dart';
import '../../utils/auth_helper.dart';
import 'group_detail_page.dart';
import 'create_group_page.dart';
import 'invitations_page.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final GroupService _groupService = GroupService();
  List<EscapeGroup> _myGroups = [];
  List<EscapeGroup> _allGroups = [];
  bool _isLoading = true;
  int _selectedTab = 0; // 0: Mis grupos, 1: Todos los grupos
  int _pendingInvitationsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() => _isLoading = true);

    try {
      if (!AuthHelper.isAuthenticated()) {
        setState(() => _isLoading = false);
        return;
      }

      final username = AuthHelper.getCurrentUsername();
      final myGroups = await _groupService.getUserGroups(username);
      final allGroups = await _groupService.getAllGroups();
      final invitationsCount = await _groupService.getPendingInvitationsCount(username);

      setState(() {
        _myGroups = myGroups;
        _allGroups = allGroups;
        _pendingInvitationsCount = invitationsCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar grupos: $e')),
        );
      }
    }
  }

  Future<void> _joinGroup(EscapeGroup group) async {
    if (!AuthHelper.isAuthenticated()) return;

    final username = AuthHelper.getCurrentUsername();
    final success = await _groupService.joinGroup(group.id!, username);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Te has unido al grupo exitosamente')),
        );
        _loadGroups();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No puedes unirte a este grupo privado. Necesitas una invitación.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Grupos de Escape Rooms'),
          backgroundColor: const Color(0xFF000D17),
          foregroundColor: Colors.white,
          actions: [
            // Botón de invitaciones con badge
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.mail),
                  tooltip: 'Invitaciones',
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InvitationsPage(),
                      ),
                    );
                    _loadGroups(); // Recargar después de ver invitaciones
                  },
                ),
                if (_pendingInvitationsCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '$_pendingInvitationsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          bottom: TabBar(
            onTap: (index) => setState(() => _selectedTab = index),
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.groups), text: 'Mis Grupos'),
              Tab(icon: Icon(Icons.explore), text: 'Descubrir'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMyGroupsList(),
            _buildAllGroupsList(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateGroupPage()),
            );
            if (result == true) {
              _loadGroups();
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Crear Grupo'),
        ),
      ),
    );
  }

  Widget _buildMyGroupsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No perteneces a ningún grupo',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea uno o únete a un grupo existente',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGroups,
      child: ListView.builder(
        itemCount: _myGroups.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final group = _myGroups[index];
          return _buildGroupCard(group, isMember: true);
        },
      ),
    );
  }

  Widget _buildAllGroupsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Filtrar grupos a los que no pertenece y que sean públicos
    final availableGroups = _allGroups.where((group) {
      final isNotMember = !_myGroups.any((myGroup) => myGroup.id == group.id);
      // Solo mostrar grupos públicos en el descubrimiento
      return isNotMember && group.isPublic;
    }).toList();

    if (availableGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.public_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay grupos públicos disponibles',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Los grupos privados requieren invitación',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGroups,
      child: ListView.builder(
        itemCount: availableGroups.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final group = availableGroups[index];
          return _buildGroupCard(group, isMember: false);
        },
      ),
    );
  }

  Widget _buildGroupCard(EscapeGroup group, {required bool isMember}) {
    final username = AuthHelper.getCurrentUsername();
    final isAdmin = group.adminUsername == username;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isMember
            ? () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupDetailPage(groupId: group.id!),
                  ),
                );
                _loadGroups();
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.group, color: Colors.blue[700]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (group.routeName != null)
                          Text(
                            group.routeName!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ADMIN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[900],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                group.description,
                style: TextStyle(color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Creado por ${group.adminUsername}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  if (!isMember)
                    ElevatedButton.icon(
                      onPressed: () => _joinGroup(group),
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Unirse'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
