import 'package:flutter/material.dart';
import '../features/escape_rooms/data/datasources/word_database.dart';

/// Página de utilidades para gestionar la base de datos
class DatabaseUtilsPage extends StatefulWidget {
  const DatabaseUtilsPage({super.key});

  @override
  State<DatabaseUtilsPage> createState() => _DatabaseUtilsPageState();
}

class _DatabaseUtilsPageState extends State<DatabaseUtilsPage> {
  final WordDatabase _db = WordDatabase.instance;
  bool _isLoading = false;
  String _statusMessage = '';
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _db.getStats();
      setState(() {
        _stats = stats;
        _statusMessage = 'Estadísticas cargadas';
      });
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Importando datos desde JSON...';
    });

    try {
      print('🔄 Iniciando importación de escape rooms...');
      await _db.importEscapesFromScrapedJson();
      print('✅ Importación completada');

      // Recargar estadísticas
      await _loadStats();

      setState(() {
        _statusMessage = '✅ Importación completada con éxito. ${_stats['total'] ?? 0} escape rooms en la base de datos.';
      });

      // Mostrar SnackBar de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Datos importados correctamente: ${_stats['total'] ?? 0} escape rooms'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error en importación: $e');
      print('Stack trace: $stackTrace');
      setState(() => _statusMessage = '❌ Error en importación: $e');

      // Mostrar SnackBar de error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _backfillProvincias() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Actualizando provincias...';
    });

    try {
      final updated = await _db.backfillProvinciaFromCoordinates();
      setState(() => _statusMessage = 'Provincias actualizadas: $updated registros');
      await _loadStats();
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _backfillEmpresas() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Actualizando empresas...';
    });

    try {
      final updated = await _db.backfillEmpresaFromExisting();
      setState(() => _statusMessage = 'Empresas actualizadas: $updated registros');
      await _loadStats();
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testProvinciasList() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Obteniendo provincias...';
    });

    try {
      final provincias = await _db.getProvinciasDisponibles();
      setState(() {
        _statusMessage = 'Provincias encontradas (${provincias.length}):\n${provincias.take(10).join(', ')}...';
      });
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utilidades de Base de Datos'),
        backgroundColor: const Color(0xFF000D17),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color(0xFF000D17),
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Estadísticas
            Card(
              color: Colors.white.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estadísticas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_stats.isNotEmpty) ...[
                      _buildStatRow('Total de escape rooms', _stats['total']),
                      _buildStatRow('Con descripción', _stats['conDescripcion']),
                      _buildStatRow('Con provincia', _stats['conProvincia']),
                      _buildStatRow('Con precio', _stats['conPrecio']),
                      _buildStatRow('Con jugadores', _stats['conJugadores']),
                      _buildStatRow('Con empresa', _stats['conEmpresa']),
                    ] else
                      const Text(
                        'Cargando...',
                        style: TextStyle(color: Colors.white70),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Mensaje de estado
            if (_statusMessage.isNotEmpty)
              Card(
                color: Colors.blue.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Botones de acción
            _buildActionButton(
              'Importar Datos Completos',
              'Importa y actualiza todos los escape rooms desde el JSON',
              _importData,
              Icons.cloud_download,
            ),

            _buildActionButton(
              'Actualizar Provincias',
              'Rellena provincias desde coordenadas',
              _backfillProvincias,
              Icons.location_on,
            ),

            _buildActionButton(
              'Actualizar Empresas',
              'Rellena empresas desde URLs',
              _backfillEmpresas,
              Icons.business,
            ),

            _buildActionButton(
              'Ver Provincias',
              'Muestra lista de provincias disponibles',
              _testProvinciasList,
              Icons.list,
            ),

            _buildActionButton(
              'Recargar Estadísticas',
              'Actualiza las estadísticas mostradas',
              _loadStats,
              Icons.refresh,
            ),

            const SizedBox(height: 32),

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String description,
    VoidCallback onPressed,
    IconData icon,
  ) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _isLoading ? null : onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
