import 'package:flutter/material.dart';
import '../features/escape_rooms/data/models/word.dart';
import '../features/escape_rooms/data/datasources/word_database.dart';
import '../features/escape_rooms/data/datasources/firestore_escape_rooms_service.dart';

/// Página de administración para editar escape rooms
class AdminEscapeRoomsPage extends StatefulWidget {
  const AdminEscapeRoomsPage({super.key});

  @override
  State<AdminEscapeRoomsPage> createState() => _AdminEscapeRoomsPageState();
}

class _AdminEscapeRoomsPageState extends State<AdminEscapeRoomsPage> {
  final WordDatabase _database = WordDatabase.instance;
  final FirestoreEscapeRoomsService _firestoreService = FirestoreEscapeRoomsService();

  List<Word> _escapeRooms = [];
  List<Word> _filteredEscapeRooms = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEscapeRooms();
    _searchController.addListener(_filterEscapeRooms);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEscapeRooms() async {
    setState(() => _isLoading = true);
    try {
      final escapeRooms = await _database.readAllWords();
      setState(() {
        _escapeRooms = escapeRooms;
        _filteredEscapeRooms = escapeRooms;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error cargando escape rooms: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterEscapeRooms() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEscapeRooms = _escapeRooms.where((word) {
        return word.text.toLowerCase().contains(query) ||
            (word.empresa?.toLowerCase().contains(query) ?? false) ||
            (word.ubicacion?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  Future<void> _editEscapeRoom(Word word) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEscapeRoomPage(word: word),
      ),
    );

    if (result == true) {
      _loadEscapeRooms(); // Recargar lista
    }
  }

  Future<void> _createNewEscapeRoom() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateEscapeRoomPage(),
      ),
    );

    if (result == true) {
      _loadEscapeRooms(); // Recargar lista
    }
  }

  Future<void> _showScrapingDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔍 Buscar Nuevos Escape Rooms'),
        content: const Text(
          'Esta función ejecutará el script de scraping para buscar nuevos escape rooms en:\n\n'
          '• escaperoomlover.com\n'
          '• todoescaperooms.com\n'
          '• escaperoos.es\n'
          '• escapeup.es\n\n'
          'El proceso puede tardar varios minutos.\n\n'
          '¿Deseas continuar?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF001F54),
            ),
            child: const Text('Iniciar scraping', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Ejecutar el scraping
    await _executeScraping();
  }

  Future<void> _executeScraping() async {
    // Mostrar diálogo informativo con instrucciones
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.laptop_mac, color: Color(0xFF001F54)),
            SizedBox(width: 8),
            Text('Scraping desde computadora'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'El scraping debe ejecutarse desde tu computadora debido a limitaciones de iOS.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Pasos para ejecutar el scraping:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text('1. Abre la terminal en tu Mac'),
              SizedBox(height: 4),
              Text('2. Navega al proyecto:'),
              SizedBox(height: 4),
              Text(
                '   cd escape_room_application/scripts',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                  backgroundColor: Color(0xFFEEEEEE),
                ),
              ),
              SizedBox(height: 8),
              Text('3. Ejecuta el script:'),
              SizedBox(height: 4),
              Text(
                '   python3 scrape_all_sources.py',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                  backgroundColor: Color(0xFFEEEEEE),
                ),
              ),
              SizedBox(height: 16),
              Text(
                '4. Los nuevos escape rooms se agregarán automáticamente a la base de datos',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 8),
              Text(
                '5. Recarga esta pantalla para ver los cambios',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'El proceso puede tardar varios minutos',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _loadEscapeRooms(); // Recargar la lista
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF001F54),
            ),
            icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
            label: const Text(
              'Recargar lista',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Escape Rooms'),
        backgroundColor: const Color(0xFF001F54),
        actions: [
          // Botón de scraping
          IconButton(
            icon: const Icon(Icons.cloud_download),
            tooltip: 'Buscar nuevos escape rooms',
            onPressed: _showScrapingDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, empresa o ciudad...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // Lista de escape rooms
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredEscapeRooms.length,
                    itemBuilder: (context, index) {
                      final word = _filteredEscapeRooms[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(
                            word.text,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${word.empresa ?? "Sin empresa"} - ${word.ubicacion ?? "Sin ubicación"}',
                          ),
                          trailing: const Icon(Icons.edit, color: Color(0xFF001F54)),
                          onTap: () => _editEscapeRoom(word),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewEscapeRoom,
        backgroundColor: const Color(0xFF001F54),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

/// Página para editar un escape room específico
class EditEscapeRoomPage extends StatefulWidget {
  final Word word;

  const EditEscapeRoomPage({required this.word, super.key});

  @override
  State<EditEscapeRoomPage> createState() => _EditEscapeRoomPageState();
}

class _EditEscapeRoomPageState extends State<EditEscapeRoomPage> {
  final _formKey = GlobalKey<FormState>();
  final WordDatabase _database = WordDatabase.instance;
  final FirestoreEscapeRoomsService _firestoreService = FirestoreEscapeRoomsService();

  late TextEditingController _textController;
  late TextEditingController _empresaController;
  late TextEditingController _ubicacionController;
  late TextEditingController _generoController;
  late TextEditingController _puntuacionController;
  late TextEditingController _webController;
  late TextEditingController _latitudController;
  late TextEditingController _longitudController;
  late TextEditingController _precioController;
  late TextEditingController _jugadoresController;
  late TextEditingController _duracionController;
  late TextEditingController _numJugadoresMinController;
  late TextEditingController _numJugadoresMaxController;
  late TextEditingController _dificultadController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  late TextEditingController _provinciaController;
  late TextEditingController _descripcionController;
  late TextEditingController _imagenUrlController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.word.text);
    _empresaController = TextEditingController(text: widget.word.empresa ?? '');
    _ubicacionController = TextEditingController(text: widget.word.ubicacion ?? '');
    _generoController = TextEditingController(text: widget.word.genero ?? '');
    _puntuacionController = TextEditingController(text: widget.word.puntuacion?.toString() ?? '');
    _webController = TextEditingController(text: widget.word.web ?? '');
    _latitudController = TextEditingController(text: widget.word.latitud?.toString() ?? '');
    _longitudController = TextEditingController(text: widget.word.longitud?.toString() ?? '');
    _precioController = TextEditingController(text: widget.word.precio?.toString() ?? '');
    _jugadoresController = TextEditingController(text: widget.word.jugadores ?? '');
    _duracionController = TextEditingController(text: widget.word.duracion ?? '');
    _numJugadoresMinController = TextEditingController(text: widget.word.numJugadoresMin?.toString() ?? '');
    _numJugadoresMaxController = TextEditingController(text: widget.word.numJugadoresMax?.toString() ?? '');
    _dificultadController = TextEditingController(text: widget.word.dificultad ?? '');
    _telefonoController = TextEditingController(text: widget.word.telefono ?? '');
    _emailController = TextEditingController(text: widget.word.email ?? '');
    _provinciaController = TextEditingController(text: widget.word.provincia ?? '');
    _descripcionController = TextEditingController(text: widget.word.descripcion ?? '');
    _imagenUrlController = TextEditingController(text: widget.word.imagenUrl ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    _empresaController.dispose();
    _ubicacionController.dispose();
    _generoController.dispose();
    _puntuacionController.dispose();
    _webController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _precioController.dispose();
    _jugadoresController.dispose();
    _duracionController.dispose();
    _numJugadoresMinController.dispose();
    _numJugadoresMaxController.dispose();
    _dificultadController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _provinciaController.dispose();
    _descripcionController.dispose();
    _imagenUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Crear Word actualizado
      final updatedWord = Word(
        id: widget.word.id,
        text: _textController.text.trim(),
        empresa: _empresaController.text.trim().isEmpty ? null : _empresaController.text.trim(),
        ubicacion: _ubicacionController.text.trim().isEmpty ? '' : _ubicacionController.text.trim(),
        genero: _generoController.text.trim().isEmpty ? '' : _generoController.text.trim(),
        puntuacion: _puntuacionController.text.trim().isEmpty ? '' : _puntuacionController.text.trim(),
        web: _webController.text.trim().isEmpty ? '' : _webController.text.trim(),
        latitud: double.tryParse(_latitudController.text.trim()) ?? 0.0,
        longitud: double.tryParse(_longitudController.text.trim()) ?? 0.0,
        precio: _precioController.text.trim().isEmpty ? null : _precioController.text.trim(),
        jugadores: _jugadoresController.text.trim().isEmpty ? null : _jugadoresController.text.trim(),
        duracion: _duracionController.text.trim().isEmpty ? null : _duracionController.text.trim(),
        numJugadoresMin: int.tryParse(_numJugadoresMinController.text.trim()),
        numJugadoresMax: int.tryParse(_numJugadoresMaxController.text.trim()),
        dificultad: _dificultadController.text.trim().isEmpty ? null : _dificultadController.text.trim(),
        telefono: _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        provincia: _provinciaController.text.trim().isEmpty ? null : _provinciaController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
        imagenUrl: _imagenUrlController.text.trim().isEmpty ? null : _imagenUrlController.text.trim(),
      );

      // Actualizar en SQLite local
      await _database.update(updatedWord);
      print('✅ Escape room ${widget.word.id} actualizado en SQLite');

      // Actualizar en Firestore
      await _firestoreService.upsertEscapeRoom(updatedWord);
      print('✅ Escape room ${widget.word.id} actualizado en Firestore');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Escape room actualizado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Retornar true para indicar cambios
    } catch (e) {
      print('❌ Error guardando cambios: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        maxLines: maxLines,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar: ${widget.word.text}'),
        backgroundColor: const Color(0xFF001F54),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildTextField('Nombre *', _textController),
                  _buildTextField('Empresa', _empresaController),
                  _buildTextField('Ubicación', _ubicacionController),
                  _buildTextField('Género', _generoController),
                  _buildTextField('Puntuación (0-10)', _puntuacionController),
                  _buildTextField('Web', _webController),
                  _buildTextField('Latitud', _latitudController),
                  _buildTextField('Longitud', _longitudController),
                  _buildTextField('Precio (€)', _precioController),
                  _buildTextField('Jugadores', _jugadoresController),
                  _buildTextField('Duración', _duracionController),
                  _buildTextField('Número mínimo de jugadores', _numJugadoresMinController),
                  _buildTextField('Número máximo de jugadores', _numJugadoresMaxController),
                  _buildTextField('Dificultad', _dificultadController),
                  _buildTextField('Teléfono', _telefonoController),
                  _buildTextField('Email', _emailController),
                  _buildTextField('Provincia', _provinciaController),
                  _buildTextField('Descripción', _descripcionController, maxLines: 4),
                  _buildTextField('URL de imagen', _imagenUrlController),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF001F54),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Guardar cambios',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Página para crear un nuevo escape room
class CreateEscapeRoomPage extends StatefulWidget {
  const CreateEscapeRoomPage({super.key});

  @override
  State<CreateEscapeRoomPage> createState() => _CreateEscapeRoomPageState();
}

class _CreateEscapeRoomPageState extends State<CreateEscapeRoomPage> {
  final _formKey = GlobalKey<FormState>();
  final WordDatabase _database = WordDatabase.instance;
  final FirestoreEscapeRoomsService _firestoreService = FirestoreEscapeRoomsService();

  late TextEditingController _textController;
  late TextEditingController _empresaController;
  late TextEditingController _ubicacionController;
  late TextEditingController _generoController;
  late TextEditingController _puntuacionController;
  late TextEditingController _webController;
  late TextEditingController _latitudController;
  late TextEditingController _longitudController;
  late TextEditingController _precioController;
  late TextEditingController _jugadoresController;
  late TextEditingController _duracionController;
  late TextEditingController _numJugadoresMinController;
  late TextEditingController _numJugadoresMaxController;
  late TextEditingController _dificultadController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  late TextEditingController _provinciaController;
  late TextEditingController _descripcionController;
  late TextEditingController _imagenUrlController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _empresaController = TextEditingController();
    _ubicacionController = TextEditingController();
    _generoController = TextEditingController();
    _puntuacionController = TextEditingController();
    _webController = TextEditingController();
    _latitudController = TextEditingController(text: '0.0');
    _longitudController = TextEditingController(text: '0.0');
    _precioController = TextEditingController();
    _jugadoresController = TextEditingController();
    _duracionController = TextEditingController();
    _numJugadoresMinController = TextEditingController();
    _numJugadoresMaxController = TextEditingController();
    _dificultadController = TextEditingController();
    _telefonoController = TextEditingController();
    _emailController = TextEditingController();
    _provinciaController = TextEditingController();
    _descripcionController = TextEditingController();
    _imagenUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    _empresaController.dispose();
    _ubicacionController.dispose();
    _generoController.dispose();
    _puntuacionController.dispose();
    _webController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _precioController.dispose();
    _jugadoresController.dispose();
    _duracionController.dispose();
    _numJugadoresMinController.dispose();
    _numJugadoresMaxController.dispose();
    _dificultadController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _provinciaController.dispose();
    _descripcionController.dispose();
    _imagenUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveNewEscapeRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Crear nuevo Word
      final newWord = Word(
        text: _textController.text.trim(),
        empresa: _empresaController.text.trim().isEmpty ? null : _empresaController.text.trim(),
        ubicacion: _ubicacionController.text.trim().isEmpty ? '' : _ubicacionController.text.trim(),
        genero: _generoController.text.trim().isEmpty ? '' : _generoController.text.trim(),
        puntuacion: _puntuacionController.text.trim().isEmpty ? '' : _puntuacionController.text.trim(),
        web: _webController.text.trim().isEmpty ? '' : _webController.text.trim(),
        latitud: double.tryParse(_latitudController.text.trim()) ?? 0.0,
        longitud: double.tryParse(_longitudController.text.trim()) ?? 0.0,
        precio: _precioController.text.trim().isEmpty ? null : _precioController.text.trim(),
        jugadores: _jugadoresController.text.trim().isEmpty ? null : _jugadoresController.text.trim(),
        duracion: _duracionController.text.trim().isEmpty ? null : _duracionController.text.trim(),
        numJugadoresMin: int.tryParse(_numJugadoresMinController.text.trim()),
        numJugadoresMax: int.tryParse(_numJugadoresMaxController.text.trim()),
        dificultad: _dificultadController.text.trim().isEmpty ? null : _dificultadController.text.trim(),
        telefono: _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        provincia: _provinciaController.text.trim().isEmpty ? null : _provinciaController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
        imagenUrl: _imagenUrlController.text.trim().isEmpty ? null : _imagenUrlController.text.trim(),
      );

      // Guardar en SQLite local
      final createdWord = await _database.create(newWord);
      print('✅ Escape room creado en SQLite con ID: ${createdWord.id}');

      // Subir a Firestore
      await _firestoreService.upsertEscapeRoom(createdWord);
      print('✅ Escape room ${createdWord.id} subido a Firestore');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Escape room creado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Retornar true para indicar cambios
    } catch (e) {
      print('❌ Error creando escape room: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        maxLines: maxLines,
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }
                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Escape Room'),
        backgroundColor: const Color(0xFF001F54),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildTextField('Nombre', _textController, required: true),
                  _buildTextField('Empresa', _empresaController),
                  _buildTextField('Ubicación', _ubicacionController),
                  _buildTextField('Género', _generoController),
                  _buildTextField('Puntuación (0-10)', _puntuacionController),
                  _buildTextField('Web', _webController),
                  _buildTextField('Latitud', _latitudController),
                  _buildTextField('Longitud', _longitudController),
                  _buildTextField('Precio (€)', _precioController),
                  _buildTextField('Jugadores', _jugadoresController),
                  _buildTextField('Duración', _duracionController),
                  _buildTextField('Número mínimo de jugadores', _numJugadoresMinController),
                  _buildTextField('Número máximo de jugadores', _numJugadoresMaxController),
                  _buildTextField('Dificultad', _dificultadController),
                  _buildTextField('Teléfono', _telefonoController),
                  _buildTextField('Email', _emailController),
                  _buildTextField('Provincia', _provinciaController),
                  _buildTextField('Descripción', _descripcionController, maxLines: 4),
                  _buildTextField('URL de imagen', _imagenUrlController),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _saveNewEscapeRoom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF001F54),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Crear escape room',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
