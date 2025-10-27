import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/word.dart';
import '../db/word_database.dart';

/// ===== Estrellas con paleta de FavoritesPage =====
class StarRating extends StatelessWidget {
  final double rating; // 0-10
  final int maxStars;
  final double starSize;

  const StarRating({
    required this.rating,
    this.maxStars = 5,
    this.starSize = 20,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedRating = rating / 2.0; // 0-5
    final fullStars = normalizedRating.floor();
    final hasHalfStar = (normalizedRating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: Colors.cyan.shade300, size: starSize);
        } else if (index == fullStars && hasHalfStar) {
          return Icon(Icons.star_half, color: Colors.cyan.shade300, size: starSize);
        } else {
          return Icon(Icons.star_border, color: Colors.blue.shade100, size: starSize);
        }
      }),
    );
  }
}

/// ===== Utilidad: extraer decimal de la puntuación =====
double parsePuntuacion(String puntuacion) {
  final regex = RegExp(r'^\d+(\.\d+)?');
  final match = regex.firstMatch(puntuacion.trim());
  if (match != null) {
    return double.tryParse(match.group(0)!) ?? 0.0;
  }
  return 0.0;
}

/// ===== Mapa ciudades → provincias =====
const Map<String, String> _ciudadesToProvincias = {
  'Benidorm': 'Alicante',
  'Madrid': 'Madrid',
  'Huesca': 'Huesca',
  'Gijón': 'Asturias',
  'Orihuela': 'Alicante',
  'Cáceres': 'Cáceres',
  'Córdoba': 'Córdoba',
  'Valencia': 'Valencia',
  'Barcelona': 'Barcelona',
  'Sevilla': 'Sevilla',
  'Zaragoza': 'Zaragoza',
  'Málaga': 'Málaga',
  'Murcia': 'Murcia',
  'Palma': 'Illes Balears',
  'Las Palmas de Gran Canaria': 'Las Palmas',
  'Bilbao': 'Bizkaia',
  'Alicante': 'Alicante',
  'Vigo': 'Pontevedra',
  'Granada': 'Granada',
  'Oviedo': 'Asturias',
  'Cartagena': 'Murcia',
  'A Coruña': 'A Coruña',
  'Vitoria-Gasteiz': 'Álava',
  'Albacete': 'Albacete',
  'Burgos': 'Burgos',
  'Salamanca': 'Salamanca',
  'Logroño': 'La Rioja',
  'Pamplona': 'Navarra',
  'Santander': 'Cantabria',
  'Castellón de la Plana': 'Castellón',
  'Almería': 'Almería',
  'La Rioja': 'La Rioja',
  'Valladolid': 'Valladolid',
  'Jaén': 'Jaén',
  'Huelva': 'Huelva',
  'Badajoz': 'Badajoz',
  'Lleida': 'Lleida',
  'Tarragona': 'Tarragona',
  'León': 'León',
  'Cádiz': 'Cádiz',
  'Ourense': 'Ourense',
  'Girona': 'Girona',
  'Lugo': 'Lugo',
  'Teruel': 'Teruel',
  'Soria': 'Soria',
  'Ávila': 'Ávila',
  'Cuenca': 'Cuenca',
  'Zamora': 'Zamora',
  'Segovia': 'Segovia',
  'Guadalajara': 'Guadalajara',
  'Toledo': 'Toledo',
  'Ciudad Real': 'Ciudad Real',
  'Pontevedra': 'Pontevedra',
};

class WordListPage extends StatefulWidget {
  const WordListPage({super.key});

  @override
  State<WordListPage> createState() => _WordListPageState();
}

class _WordListPageState extends State<WordListPage> {
  // ---------- Estado ----------
  List<Word> _words = [];
  List<Word> _filteredWords = [];
  final PopupController _popupController = PopupController();
  final MapController _mapController = MapController();

  static const double minRating = 0.0;
  static const double maxRating = 10.0;
  static const int divisions = 20;

  Set<String> selectedGeneros = {};
  String? _selectedProvincia;
  RangeValues _selectedRatingRange = const RangeValues(minRating, maxRating);
  String sortOrder = 'ninguno';

  List<String> allGeneros = [];
  List<String> allProvincias = [];

  bool _showMap = false;

  // Paleta FavoritesPage
  static const Color _appBarBg = Color(0xFF000D17);

  final TextEditingController _minRatingController = TextEditingController();
  final TextEditingController _maxRatingController = TextEditingController();

  // Buscador
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  @override
  void dispose() {
    _minRatingController.dispose();
    _maxRatingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ---------- Utils ----------
  Map<String, String> _parseUbicacion(String ubicacion) {
    String provincia = '';
    String ciudad = '';

    final parts = ubicacion.split(',').map((p) => p.trim()).toList();
    if (parts.isNotEmpty) ciudad = parts[0];

    final normalized = ubicacion.toLowerCase();
    for (final p in _ciudadesToProvincias.values) {
      if (normalized.contains(p.toLowerCase())) {
        provincia = p;
        break;
      }
    }
    return {'provincia': provincia, 'ciudad': ciudad};
  }

  Word? _findWordByLatLng(LatLng p) {
    for (final w in _filteredWords) {
      if ((w.latitud ?? 0) == p.latitude && (w.longitud ?? 0) == p.longitude) return w;
    }
    return null;
  }

  // ------ Colores por género ------
  Color _getGenreColor(String genre) {
    switch (genre.toLowerCase()) {
      case 'terror':
        return Colors.deepPurple;
      case 'aventura':
        return Colors.green;
      case 'investigación':
        return Colors.blueGrey;
      case 'acción':
        return Colors.redAccent;
      case 'fantasía':
        return Colors.indigo;
      case 'humor':
        return const Color(0xffe6a008);
      case 'misterio':
        return const Color(0xff831702);
      case 'sobrenatural':
        return const Color(0xff0509e1);
      case 'familiar':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _loadWords() async {
    try {
      final words = await WordDatabase.instance.readAllWords();
      setState(() {
        _words = words;
        _filteredWords = words;
      });

      if (_words.isEmpty) return;

      final allGenerosSet = _words
          .expand((w) => w.genero.split('/'))
          .map((g) => g.trim())
          .where((g) => g.isNotEmpty)
          .toSet();
      allGeneros = allGenerosSet.toList()..sort();

      final allUbicacionData = _words.map((w) => _parseUbicacion(w.ubicacion));
      final allProvinciasSet =
          allUbicacionData.map((u) => u['provincia']!).where((p) => p.isNotEmpty).toSet();
      allProvincias = allProvinciasSet.toList()..sort();

      _recomputeFilteredWords(); // por si hay query previa
    } catch (e) {
      debugPrint('Error loading words: $e');
      setState(() {
        _words = [];
        _filteredWords = [];
      });
    }
  }

  Future<void> _toggleFavorite(Word word) async {
    await WordDatabase.instance.toggleFavorite(word.id!, !word.isFavorite);
    _loadWords();
  }

  Future<void> _togglePlayed(Word word) async {
    final newPlayedValue = !word.isPlayed;
    await WordDatabase.instance.togglePlayed(word.id!, newPlayedValue);
    if (newPlayedValue) {
      await WordDatabase.instance.togglePending(word.id!, false);
    }

    setState(() {
      final index = _words.indexWhere((w) => w.id == word.id);
      if (index != -1) {
        _words[index] = _words[index].copyWith(
          isPlayed: newPlayedValue,
          isPending: newPlayedValue ? false : word.isPending,
        );
      }
      final filteredIndex = _filteredWords.indexWhere((w) => w.id == word.id);
      if (filteredIndex != -1) {
        _filteredWords[filteredIndex] = _filteredWords[filteredIndex].copyWith(
          isPlayed: newPlayedValue,
          isPending: newPlayedValue ? false : word.isPending,
        );
      }
    });
  }

  Future<void> _togglePending(Word word) async {
    final newPendingValue = !word.isPending;
    await WordDatabase.instance.togglePending(word.id!, newPendingValue);
    if (newPendingValue) {
      await WordDatabase.instance.togglePlayed(word.id!, false);
    }

    setState(() {
      final index = _words.indexWhere((w) => w.id == word.id);
      if (index != -1) {
        _words[index] = _words[index].copyWith(
          isPending: newPendingValue,
          isPlayed: newPendingValue ? false : word.isPlayed,
        );
      }
      final filteredIndex = _filteredWords.indexWhere((w) => w.id == word.id);
      if (filteredIndex != -1) {
        _filteredWords[filteredIndex] = _filteredWords[filteredIndex].copyWith(
          isPending: newPendingValue,
          isPlayed: newPendingValue ? false : word.isPlayed,
        );
      }
    });
  }

  // ---------- Filtro + búsqueda + orden ----------
  void _recomputeFilteredWords() {
    final query = _searchQuery.trim().toLowerCase();

    List<Word> result = _words.where((word) {
      final generoChips = word.genero
          .split('/')
          .map((g) => g.trim())
          .where((g) => g.isNotEmpty)
          .toList();

      final ubicacionData = _parseUbicacion(word.ubicacion);
      final puntuacionValue = parsePuntuacion(word.puntuacion);
      final minP = _selectedRatingRange.start;
      final maxP = _selectedRatingRange.end;

      final matchGenero =
          selectedGeneros.isEmpty || generoChips.any((g) => selectedGeneros.contains(g));
      final matchProvincia =
          _selectedProvincia == null || ubicacionData['provincia'] == _selectedProvincia;
      final matchPuntuacion = puntuacionValue >= minP && puntuacionValue <= maxP;

      bool matchSearch = true;
      if (query.isNotEmpty) {
        final ciudad = ubicacionData['ciudad'] ?? '';
        final provincia = ubicacionData['provincia'] ?? '';
        final texto = (word.text).toLowerCase();
        final generoStr = word.genero.toLowerCase();
        final ubicStr = word.ubicacion.toLowerCase();
        final webStr = (word.web).toLowerCase();
        matchSearch = texto.contains(query) ||
            generoStr.contains(query) ||
            ubicStr.contains(query) ||
            provincia.toLowerCase().contains(query) ||
            ciudad.toLowerCase().contains(query) ||
            webStr.contains(query);
      }

      return matchGenero && matchProvincia && matchPuntuacion && matchSearch;
    }).toList();

    // Orden
    if (sortOrder == 'puntuacion_asc') {
      result.sort((a, b) => parsePuntuacion(a.puntuacion).compareTo(parsePuntuacion(b.puntuacion)));
    } else if (sortOrder == 'puntuacion_desc') {
      result.sort((a, b) => parsePuntuacion(b.puntuacion).compareTo(parsePuntuacion(a.puntuacion)));
    } else if (sortOrder == 'ciudad_asc') {
      result.sort((a, b) {
        final ciudadA = _parseUbicacion(a.ubicacion)['ciudad'] ?? '';
        final ciudadB = _parseUbicacion(b.ubicacion)['ciudad'] ?? '';
        return ciudadA.compareTo(ciudadB);
      });
    } else if (sortOrder == 'ciudad_desc') {
      result.sort((a, b) {
        final ciudadA = _parseUbicacion(a.ubicacion)['ciudad'] ?? '';
        final ciudadB = _parseUbicacion(b.ubicacion)['ciudad'] ?? '';
        return ciudadB.compareTo(ciudadA);
      });
    } else if (sortOrder == 'provincia_ciudad_asc') {
      result.sort((a, b) {
        final ua = _parseUbicacion(a.ubicacion);
        final ub = _parseUbicacion(b.ubicacion);
        final pa = ua['provincia'] ?? '';
        final pb = ub['provincia'] ?? '';
        final ca = ua['ciudad'] ?? '';
        final cb = ub['ciudad'] ?? '';
        final cmp = pa.compareTo(pb);
        if (cmp != 0) return cmp;
        return ca.compareTo(cb);
      });
    } else if (sortOrder == 'provincia_ciudad_desc') {
      result.sort((a, b) {
        final ua = _parseUbicacion(a.ubicacion);
        final ub = _parseUbicacion(b.ubicacion);
        final pa = ua['provincia'] ?? '';
        final pb = ub['provincia'] ?? '';
        final ca = ua['ciudad'] ?? '';
        final cb = ub['ciudad'] ?? '';
        final cmp = pb.compareTo(pa);
        if (cmp != 0) return cmp;
        return cb.compareTo(ca);
      });
    }

    setState(() {
      _filteredWords = result;
    });
  }

  void _applyFilters() {
    _recomputeFilteredWords();
    Navigator.of(context).pop();
  }

  // ---------- Search bar (look & feel de card) ----------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.blue.shade100),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) {
            _searchQuery = v;
            _recomputeFilteredWords(); // filtra en vivo
          },
          style: TextStyle(color: Colors.blueGrey.shade900),
          cursorColor: Colors.blueGrey.shade700,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.blueGrey.shade600),
            hintText: 'Buscar por nombre, género, ciudad, provincia o web',
            hintStyle: TextStyle(color: Colors.blueGrey.shade400),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Limpiar',
                    icon: Icon(Icons.clear, color: Colors.blueGrey.shade500),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                      _recomputeFilteredWords();
                    },
                  ),
          ),
        ),
      ),
    );
  }

  // ---------- Modal de filtros con estética Favorites ----------
  void _openFilterModal() {
    final tempSelectedGeneros = Set<String>.from(selectedGeneros);
    String? tempSelectedProvincia = _selectedProvincia;
    RangeValues tempSelectedRatingRange = _selectedRatingRange;
    String tempSortOrder = sortOrder;

    // búsqueda del modal (solo aplica al pulsar Aplicar)
    String tempSearchQuery = _searchQuery;
    final TextEditingController tempSearchController =
        TextEditingController(text: tempSearchQuery);

    _minRatingController.text = tempSelectedRatingRange.start.toStringAsFixed(1);
    _maxRatingController.text = tempSelectedRatingRange.end.toStringAsFixed(1);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filtros',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, localSetState) => Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 56),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Filtros',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _appBarBg,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.of(context).pop(),
                                  color: _appBarBg,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Buscador del modal (aplica al pulsar Aplicar)
                            Card(
                              elevation: 2,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.blue.shade100),
                              ),
                              child: TextField(
                                controller: tempSearchController,
                                onChanged: (v) => tempSearchQuery = v,
                                style: TextStyle(color: Colors.blueGrey.shade900),
                                cursorColor: Colors.blueGrey.shade700,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.search,
                                      color: Colors.blueGrey.shade600),
                                  hintText:
                                      'Buscar por nombre, género, ciudad, provincia o web',
                                  hintStyle:
                                      TextStyle(color: Colors.blueGrey.shade400),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                  suffixIcon: tempSearchController.text.isEmpty
                                      ? null
                                      : IconButton(
                                          tooltip: 'Limpiar',
                                          icon: Icon(Icons.clear,
                                              color: Colors.blueGrey.shade500),
                                          onPressed: () {
                                            tempSearchController.clear();
                                            tempSearchQuery = '';
                                            localSetState(() {});
                                          },
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),
                            _buildSortOptions(
                              localSetState,
                              tempSortOrder,
                              (newOrder) => localSetState(() => tempSortOrder = newOrder),
                            ),
                            _buildProvinciaDropdown(
                              localSetState,
                              tempSelectedProvincia,
                              (newValue) => localSetState(() => tempSelectedProvincia = newValue),
                            ),
                            _buildFilterPanel(
                              'Género',
                              allGeneros,
                              tempSelectedGeneros,
                              localSetState,
                            ),
                            _buildRatingSlider(
                              localSetState,
                              tempSelectedRatingRange,
                              (newRange) {
                                localSetState(() {
                                  tempSelectedRatingRange = newRange;
                                  _minRatingController.text =
                                      newRange.start.toStringAsFixed(1);
                                  _maxRatingController.text =
                                      newRange.end.toStringAsFixed(1);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Botonera inferior
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.refresh),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _appBarBg,
                              side: BorderSide(color: Colors.blue.shade100),
                            ),
                            onPressed: () {
                              localSetState(() {
                                tempSelectedGeneros.clear();
                                tempSelectedProvincia = null;
                                tempSelectedRatingRange =
                                    const RangeValues(minRating, maxRating);
                                tempSortOrder = 'ninguno';
                                tempSearchQuery = '';
                                tempSearchController.clear();
                                _minRatingController.text =
                                    minRating.toStringAsFixed(1);
                                _maxRatingController.text =
                                    maxRating.toStringAsFixed(1);
                              });
                            },
                            label: const Text('Reiniciar'),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check, color: Color(0xFF001F54)),
                            label: const Text('Aplicar',
                                style: TextStyle(color: Color(0xFF001F54))),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade100,
                              elevation: 0,
                            ),
                            onPressed: () {
                              setState(() {
                                selectedGeneros = tempSelectedGeneros;
                                _selectedProvincia = tempSelectedProvincia;
                                _selectedRatingRange = tempSelectedRatingRange;
                                sortOrder = tempSortOrder;
                                _searchQuery = tempSearchQuery;
                                _searchController.text = _searchQuery;
                              });
                              _applyFilters();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(animation);
        return SlideTransition(position: slide, child: child);
      },
    );
  }

  Widget _buildFilterPanel(
    String title,
    List<dynamic> options,
    Set<dynamic> selectedSet,
    void Function(void Function()) setModalState,
  ) {
    final allSelected = selectedSet.length == options.length && options.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: _appBarBg,
                ),
              ),
              TextButton(
                onPressed: () {
                  setModalState(() {
                    if (allSelected) {
                      selectedSet.clear();
                    } else {
                      selectedSet..clear()..addAll(options);
                    }
                  });
                },
                child: const Text('Todos / Ninguno',
                    style: TextStyle(color: Color(0xFF001F54))),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final selected = selectedSet.contains(option);
            final c = _getGenreColor(option.toString());
            return FilterChip(
              label: Text(
                option.toString(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: selected ? Colors.white : c),
              ),
              selected: selected,
              selectedColor: c,
              backgroundColor: c.withAlpha(40),
              showCheckmark: false,
              onSelected: (val) {
                setModalState(() {
                  if (val) {
                    selectedSet.add(option);
                  } else {
                    selectedSet.remove(option);
                  }
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: c.withAlpha(120), width: 1.5),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildProvinciaDropdown(
    void Function(void Function()) setModalState,
    String? currentValue,
    Function(String?) onProvinciaChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Provincia',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: _appBarBg,
                ),
              ),
            ],
          ),
        ),
        DropdownButtonFormField<String>(
          value: currentValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blue.shade100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blue.shade100),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          hint: const Text('Cualquier provincia'),
          onChanged: (String? newValue) => onProvinciaChanged(newValue),
          items: allProvincias.map((String provincia) {
            return DropdownMenuItem<String>(
              value: provincia,
              child: Text(provincia),
            );
          }).toList(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => onProvinciaChanged(null),
            child: const Text('Borrar selección',
                style: TextStyle(color: Color(0xFF001F54))),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRatingSlider(
    void Function(void Function()) setModalState,
    RangeValues currentRange,
    Function(RangeValues) onRangeChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Puntuación (rango)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: _appBarBg,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _ratingBox(
                label: 'Desde',
                controller: _minRatingController,
                onChanged: (value) {
                  final v = double.tryParse(value);
                  if (v != null) onRangeChanged(RangeValues(v, currentRange.end));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ratingBox(
                label: 'Hasta',
                controller: _maxRatingController,
                onChanged: (value) {
                  final v = double.tryParse(value);
                  if (v != null) onRangeChanged(RangeValues(currentRange.start, v));
                },
              ),
            ),
          ],
        ),
        RangeSlider(
          values: currentRange,
          min: minRating,
          max: maxRating,
          divisions: divisions,
          labels: RangeLabels(
            currentRange.start.toStringAsFixed(1),
            currentRange.end.toStringAsFixed(1),
          ),
          onChanged: (newRange) => onRangeChanged(newRange),
          activeColor: _appBarBg,
          inactiveColor: const Color(0x4D0e145a),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _ratingBox({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.blueGrey.shade600)),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
            ],
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  // === Badge "Jugado" (esquina, sin solapar cabecera) ===
  Widget _playedBadge() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF015526), // verde oscuro
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          topRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check, size: 14, color: Colors.white),
          SizedBox(width: 6),
          Text(
            'Jugado',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Lista con tarjetas estilo FavoritesPage ----------
  Widget _buildList() {
    if (_filteredWords.isEmpty) {
      return Center(
        child: Text(
          'No hay elementos para mostrar.',
          style: TextStyle(color: Colors.blueGrey.shade700),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: _filteredWords.length,
      itemBuilder: (context, index) {
        final word = _filteredWords[index];
        final generoChips = word.genero
            .split('/')
            .map((g) => g.trim())
            .where((g) => g.isNotEmpty)
            .toList();
        final puntuacion = parsePuntuacion(word.puntuacion);

        return Card(
          clipBehavior: Clip.antiAlias, // asegura recorte en esquinas
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.blue.shade100),
          ),
          child: Stack(
            children: [
              // Contenido
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Cabecera: solo título (dejamos la esquina para el badge)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            word.text,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.blueGrey.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// Chips de géneros (colores)
                    if (generoChips.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: generoChips.map((g) {
                          final c = _getGenreColor(g);
                          return Chip(
                            label: Text(
                              g,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: c,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: c.withAlpha(120)),
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 8),

                    /// Ubicación
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.place, color: Colors.blueGrey, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            word.ubicacion,
                            style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// Estrellas + número (aquí para no chocar con badge)
                    Row(
                      children: [
                        StarRating(rating: puntuacion),
                        if (puntuacion > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            puntuacion.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.blueGrey.shade900,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// Botón Abrir web
                    if (word.web.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final uri = Uri.tryParse(word.web);
                            if (uri == null) {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('URL no válida')),
                              );
                              return;
                            }
                            final ok = await canLaunchUrl(uri);
                            if (ok) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } else {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('No se pudo abrir el enlace')),
                              );
                            }
                          },
                          icon: const Icon(Icons.open_in_browser, color: Color(0xFF001F54)),
                          label: const Text('Abrir web',
                              style: TextStyle(color: Color(0xFF001F54))),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade100,
                            foregroundColor: Colors.blue.shade900,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),

                    const SizedBox(height: 4),

                    /// Acciones: Jugado / Pendiente / Favorito
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Jugado
                        IconButton(
                          tooltip: word.isPlayed ? 'Marcado como jugado' : 'Marcar como jugado',
                          icon: Icon(
                            word.isPlayed
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: word.isPlayed
                                ? Colors.blue.shade700
                                : Colors.blueGrey.shade400,
                            size: 24,
                          ),
                          onPressed: () => _togglePlayed(word),
                        ),

                        // Pendiente
                        IconButton(
                          tooltip: word.isPending
                              ? 'Marcado como pendiente'
                              : 'Marcar como pendiente',
                          icon: Icon(
                            word.isPending ? Icons.schedule : Icons.schedule_outlined,
                            color: word.isPending ? Colors.orange : Colors.blueGrey.shade400,
                            size: 22,
                          ),
                          onPressed: () => _togglePending(word),
                        ),

                        // Favorito
                        IconButton(
                          tooltip: word.isFavorite ? 'Quitar favorito' : 'Marcar favorito',
                          icon: Icon(
                            word.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: word.isFavorite
                                ? Colors.redAccent
                                : Colors.blueGrey.shade400,
                            size: 24,
                          ),
                          onPressed: () => _toggleFavorite(word),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Badge "Jugado" en la esquina (dentro de la card)
              if (word.isPlayed)
                Positioned(
                  top: 0,
                  right: 0,
                  child: _playedBadge(),
                ),
            ],
          ),
        );
      },
    );
  }

  // ---------- Mapa con popup suavizado ----------
  Widget _buildMap() {
    final markers = _filteredWords.where((w) => w.latitud != null && w.longitud != null).map((word) {
      return Marker(
        point: LatLng(word.latitud!, word.longitud!),
        width: 40,
        height: 40,
        child: const Icon(Icons.location_pin, color: Color(0xFF010521), size: 30),
        key: ValueKey(word.id),
      );
    }).toList();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(40.4168, -3.7038),
        initialZoom: 5.5,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.escape_room_application',
        ),
        PopupMarkerLayer(
          options: PopupMarkerLayerOptions(
            markers: markers,
            popupController: _popupController,
            markerTapBehavior: MarkerTapBehavior.togglePopupAndHideRest(),
            popupDisplayOptions: PopupDisplayOptions(
              builder: (context, marker) {
                final word = _findWordByLatLng(marker.point);
                if (word == null) return const SizedBox.shrink();

                final generoChips = word.genero
                    .split('/')
                    .map((g) => g.trim())
                    .where((g) => g.isNotEmpty)
                    .toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _mapController.move(marker.point, 14.0);
                });

                return Container(
                  width: 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(64),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: DefaultTextStyle(
                      style:
                          TextStyle(color: Colors.blueGrey.shade900, fontSize: 13),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            word.text,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.blueGrey.shade900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: generoChips.map((g) {
                              final c = _getGenreColor(g);
                              return Chip(
                                label: Text(
                                  g,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: c,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(color: c.withAlpha(120)),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.place,
                                  size: 16, color: Colors.blueGrey),
                              const SizedBox(width: 6),
                              Expanded(
                                  child: Text('Ubicación: ${word.ubicacion}')),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: Colors.blueGrey),
                              const SizedBox(width: 6),
                              Text('Puntuación: ${word.puntuacion}'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Web: ${word.web}',
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.lightBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Sort options ----------
  Widget _buildSortOptions(
    void Function(void Function()) setModalState,
    String currentOrder,
    Function(String) onOrderChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ordenar por',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 6),

        const Text('Puntuación', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 6,
          children: [
            ChoiceChip(
              label: const Text('Ascendente'),
              selected: currentOrder == 'puntuacion_asc',
              onSelected: (_) => onOrderChanged('puntuacion_asc'),
            ),
            ChoiceChip(
              label: const Text('Descendente'),
              selected: currentOrder == 'puntuacion_desc',
              onSelected: (_) => onOrderChanged('puntuacion_desc'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        const Text('Ciudad', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 6,
          children: [
            ChoiceChip(
              label: const Text('A-Z'),
              selected: currentOrder == 'ciudad_asc',
              onSelected: (_) => onOrderChanged('ciudad_asc'),
            ),
            ChoiceChip(
              label: const Text('Z-A'),
              selected: currentOrder == 'ciudad_desc',
              onSelected: (_) => onOrderChanged('ciudad_desc'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        const Text('Provincia y Ciudad', style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 6,
          children: [
            ChoiceChip(
              label: const Text('A-Z'),
              selected: currentOrder == 'provincia_ciudad_asc',
              onSelected: (_) => onOrderChanged('provincia_ciudad_asc'),
            ),
            ChoiceChip(
              label: const Text('Z-A'),
              selected: currentOrder == 'provincia_ciudad_desc',
              onSelected: (_) => onOrderChanged('provincia_ciudad_desc'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ChoiceChip(
          label: const Text('Ninguno'),
          selected: currentOrder == 'ninguno',
          onSelected: (_) => onOrderChanged('ninguno'),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // igual FavoritesPage
      appBar: AppBar(
        backgroundColor: _appBarBg,
        foregroundColor: Colors.white,
        title: const Text(
          'Listado Escape Room España',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.filter_alt_rounded),
          onPressed: _openFilterModal,
        ),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            tooltip: _showMap ? 'Ver listado' : 'Ver mapa',
            onPressed: () {
              setState(() {
                _showMap = !_showMap;
                _popupController.hideAllPopups();
              });
            },
          ),
        ],
      ),
      body: _words.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _showMap
              ? _buildMap()
              : Column(
                  children: [
                    _buildSearchBar(),
                    Expanded(child: _buildList()),
                  ],
                ),
      floatingActionButton: _showMap
          ? FloatingActionButton(
              onPressed: () {
                _popupController.hideAllPopups();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _mapController.move(const LatLng(40.4168, -3.7038), 5.5);
                });
              },
              backgroundColor: Colors.blueAccent,
              tooltip: 'Ver mapa completo',
              child: const Icon(Icons.zoom_out_map),
            )
          : null,
    );
  }
}