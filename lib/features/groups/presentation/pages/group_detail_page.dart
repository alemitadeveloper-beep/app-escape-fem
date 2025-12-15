import 'package:flutter/material.dart';
import '../../domain/services/group_service.dart';
import '../../data/models/group.dart';
import '../../data/models/group_member.dart';
import '../../data/models/group_session.dart';
import '../../utils/auth_helper.dart';
import 'create_session_page.dart';
import 'session_detail_page.dart';
import 'invite_members_page.dart';
import 'edit_group_page.dart';
import 'edit_session_page.dart';

class GroupDetailPage extends StatefulWidget {
  final int groupId;

  const GroupDetailPage({required this.groupId, super.key});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> with SingleTickerProviderStateMixin {
  final GroupService _groupService = GroupService();
  late TabController _tabController;

  EscapeGroup? _group;
  List<GroupMember> _members = [];
  List<GroupSession> _sessions = [];
  List<Map<String, dynamic>> _ranking = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final group = await _groupService.getGroup(widget.groupId);
      final members = await _groupService.getGroupMembers(widget.groupId);
      final sessions = await _groupService.getGroupSessions(widget.groupId);
      final ranking = await _groupService.getGroupRanking(widget.groupId);

      setState(() {
        _group = group;
        _members = members;
        _sessions = sessions;
        _ranking = ranking;
        _isAdmin = group?.adminUsername == AuthHelper.getCurrentUsername();
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

  Future<void> _leaveGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salir del grupo'),
        content: const Text('¿Estás seguro de que quieres salir de este grupo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await _groupService.leaveGroup(widget.groupId, AuthHelper.getCurrentUsername());
      if (success && mounted) {
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No puedes salir del grupo siendo administrador')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cargando...'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_group!.name),
        backgroundColor: const Color(0xFF000D17),
        foregroundColor: Colors.white,
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar grupo',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditGroupPage(group: _group!),
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              },
            ),
          if (!_isAdmin)
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              tooltip: 'Salir del grupo',
              onPressed: _leaveGroup,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today), text: 'Sesiones'),
            Tab(icon: Icon(Icons.people), text: 'Miembros'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Ranking'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSessionsTab(),
          _buildMembersTab(),
          _buildRankingTab(),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateSessionPage(groupId: widget.groupId),
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Nueva Sesión'),
            )
          : null,
    );
  }

  Widget _buildSessionsTab() {
    if (_sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay sesiones programadas',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            if (_isAdmin) ...[
              const SizedBox(height: 8),
              Text(
                'Crea la primera sesión',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _sessions.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final session = _sessions[index];
          return _buildSessionCard(session);
        },
      ),
    );
  }

  Widget _buildSessionCard(GroupSession session) {
    final isCompleted = session.isCompleted;
    final isPast = session.scheduledDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SessionDetailPage(
                sessionId: session.id!,
                isAdmin: _isAdmin,
              ),
            ),
          );
          _loadData();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.escapeRoomName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_isAdmin)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Editar sesión',
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditSessionPage(session: session),
                          ),
                        );
                        if (result == true) {
                          _loadData();
                        }
                      },
                    ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'COMPLETADO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                    )
                  else if (isPast)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'PENDIENTE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(session.scheduledDate),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              if (session.notes != null) ...[
                const SizedBox(height: 8),
                Text(
                  session.notes!,
                  style: TextStyle(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembersTab() {
    return Column(
      children: [
        // Botón de invitar si es admin
        if (_isAdmin)
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InviteMembersPage(groupId: widget.groupId),
                  ),
                );
                if (result == true) {
                  _loadData();
                }
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Invitar Miembros'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ),

        // Lista de miembros
        Expanded(
          child: ListView.builder(
            itemCount: _members.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final member = _members[index];
              final isCurrentUser = member.username == AuthHelper.getCurrentUsername();
              final isMemberAdmin = member.isAdmin;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCurrentUser ? Colors.blue[700] : Colors.grey[400],
                    child: Text(
                      member.username[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(member.username),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(Tú)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    'Miembro desde ${_formatDate(member.joinedAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  trailing: isMemberAdmin
                      ? Container(
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
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRankingTab() {
    if (_ranking.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aún no hay valoraciones',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Completa sesiones y valóralas para ver el ranking',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _ranking.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final entry = _ranking[index];
        final position = index + 1;
        final username = entry['username'] as String;
        final sessionsRated = entry['sessionsRated'] as int? ?? 0;
        final averageRating = entry['averageRating'] as double? ?? 0.0;

        Color? medalColor;
        IconData? medalIcon;
        if (position == 1) {
          medalColor = Colors.amber;
          medalIcon = Icons.emoji_events;
        } else if (position == 2) {
          medalColor = Colors.grey[400];
          medalIcon = Icons.emoji_events;
        } else if (position == 3) {
          medalColor = Colors.brown[300];
          medalIcon = Icons.emoji_events;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: position <= 3 ? 4 : 1,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: medalColor ?? Colors.blue[100],
              child: medalIcon != null
                  ? Icon(medalIcon, color: Colors.white)
                  : Text(
                      '$position',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
            title: Text(
              username,
              style: TextStyle(
                fontWeight: position <= 3 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              '$sessionsRated sesiones valoradas',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber[700]),
                    const SizedBox(width: 4),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
