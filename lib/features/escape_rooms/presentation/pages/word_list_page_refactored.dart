import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';

import '../../data/models/word.dart';
import '../../data/repositories/escape_room_repository.dart';
import '../../domain/services/filter_service.dart';
import '../../domain/services/sort_service.dart';
import '../widgets/escape_room_list_view.dart';
import '../widgets/escape_room_map_view.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_modal.dart';

/// Página principal de listado de escape rooms - REFACTORIZADA
class WordListPageRefactored extends StatefulWidget {
  const WordListPageRefactored({super.key});

  @override
  State<WordListPageRefactored> createState() => _WordListPageRefactoredState();
}

class _WordListPageRefactoredState extends State<WordListPageRefactored> {
  // Servicios y repositories
  final EscapeRoomRepository _repository = EscapeRoomRepository();
  final FilterService _filterService = FilterService();
  final SortService _sortService = SortService();

  // Controllers
  final PopupController _popupController = PopupController();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Estado
  List<Word> _allWords = [];
  List<Word> _filteredWords = [];
  bool _isLoading = true;
  bool _showMap = false;

  // Filtros
  Set<String> _selectedGenres = {};
  String? _selectedProvincia;
  RangeValues _selectedRatingRange = const RangeValues(0.0, 10.0);
  SortOrder _sortOrder = SortOrder.none;
  String _searchQuery = '';

  // Datos para filtros
  List<String> _availableGenres = [];
  List<String> _availableProvincias = [];

  // Colores
  static const Color _appBarBg = Color(0xFF000D17);

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    try {
      setState(() => _isLoading = true);

      final words = await _repository.getAllEscapeRooms();

      if (!mounted) return;

      setState(() {
        _allWords = words;
        _availableGenres = _filterService.extractUniqueGenres(words);
        _availableProvincias = _filterService.extractUniqueProvincias(words);
        _isLoading = false;
      });

      _applyFiltersAndSort();
    } catch (e) {
      debugPrint('Error loading words: $e');
      if (!mounted) return;
      setState(() {
        _allWords = [];
        _filteredWords = [];
        _isLoading = false;
      });
    }
  }

  void _applyFiltersAndSort() {
    // Aplicar filtros
    final filtered = _filterService.filterWords(
      words: _allWords,
      selectedGenres: _selectedGenres.isEmpty ? null : _selectedGenres,
      selectedProvincia: _selectedProvincia,
      minRating: _selectedRatingRange.start,
      maxRating: _selectedRatingRange.end,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
    );

    // Aplicar ordenamiento
    final sorted = _sortService.sortWords(filtered, _sortOrder);

    setState(() => _filteredWords = sorted);
  }

  Future<void> _togglePlayed(Word word) async {
    final newPlayedValue = !word.isPlayed;
    await _repository.togglePlayed(word.id!, newPlayedValue);

    if (newPlayedValue) {
      await _repository.togglePending(word.id!, false);
    }

    await _loadWords();
  }

  Future<void> _togglePending(Word word) async {
    final newPendingValue = !word.isPending;
    await _repository.togglePending(word.id!, newPendingValue);

    if (newPendingValue) {
      await _repository.togglePlayed(word.id!, false);
    }

    await _loadWords();
  }

  void _openFilterModal() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filtros',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FilterModal(
          initialGenres: _selectedGenres,
          initialProvincia: _selectedProvincia,
          initialRatingRange: _selectedRatingRange,
          initialSortOrder: _sortOrder,
          initialSearchQuery: _searchQuery,
          availableGenres: _availableGenres,
          availableProvincias: _availableProvincias,
          onApplyFilters: ({
            required genres,
            required provincia,
            required ratingRange,
            required sortOrder,
            required searchQuery,
          }) {
            setState(() {
              _selectedGenres = genres;
              _selectedProvincia = provincia;
              _selectedRatingRange = ratingRange;
              _sortOrder = sortOrder;
              _searchQuery = searchQuery;
              _searchController.text = searchQuery;
            });
            _applyFiltersAndSort();
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation);
        return SlideTransition(position: slide, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showMap
              ? EscapeRoomMapView(
                  words: _filteredWords,
                  mapController: _mapController,
                  popupController: _popupController,
                )
              : Column(
                  children: [
                    SearchBarWidget(
                      controller: _searchController,
                      hintText:
                          'Buscar por nombre, género, ciudad, provincia o web',
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                        _applyFiltersAndSort();
                      },
                      onClear: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        _applyFiltersAndSort();
                      },
                    ),
                    Expanded(
                      child: EscapeRoomListView(
                        words: _filteredWords,
                        onTogglePlayed: _togglePlayed,
                        onTogglePending: _togglePending,
                      ),
                    ),
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
