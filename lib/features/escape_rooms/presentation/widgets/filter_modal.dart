import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/genre_utils.dart';
import '../../domain/services/sort_service.dart';

/// Modal de filtros para escape rooms
class FilterModal extends StatefulWidget {
  final Set<String> initialGenres;
  final String? initialProvincia;
  final RangeValues initialRatingRange;
  final SortOrder initialSortOrder;
  final String initialSearchQuery;
  final List<String> availableGenres;
  final List<String> availableProvincias;
  final Function({
    required Set<String> genres,
    required String? provincia,
    required RangeValues ratingRange,
    required SortOrder sortOrder,
    required String searchQuery,
  }) onApplyFilters;

  const FilterModal({
    required this.initialGenres,
    required this.initialProvincia,
    required this.initialRatingRange,
    required this.initialSortOrder,
    required this.initialSearchQuery,
    required this.availableGenres,
    required this.availableProvincias,
    required this.onApplyFilters,
    super.key,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  static const double minRating = 0.0;
  static const double maxRating = 10.0;
  static const int divisions = 20;
  static const Color appBarBg = Color(0xFF000D17);

  late Set<String> _selectedGenres;
  late String? _selectedProvincia;
  late RangeValues _selectedRatingRange;
  late SortOrder _sortOrder;
  late String _searchQuery;

  late TextEditingController _minRatingController;
  late TextEditingController _maxRatingController;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _selectedGenres = Set.from(widget.initialGenres);
    _selectedProvincia = widget.initialProvincia;
    _selectedRatingRange = widget.initialRatingRange;
    _sortOrder = widget.initialSortOrder;
    _searchQuery = widget.initialSearchQuery;

    _minRatingController = TextEditingController(
      text: _selectedRatingRange.start.toStringAsFixed(1),
    );
    _maxRatingController = TextEditingController(
      text: _selectedRatingRange.end.toStringAsFixed(1),
    );
    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _minRatingController.dispose();
    _maxRatingController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _selectedGenres.clear();
      _selectedProvincia = null;
      _selectedRatingRange = const RangeValues(minRating, maxRating);
      _sortOrder = SortOrder.none;
      _searchQuery = '';
      _searchController.clear();
      _minRatingController.text = minRating.toStringAsFixed(1);
      _maxRatingController.text = maxRating.toStringAsFixed(1);
    });
  }

  void _applyFilters() {
    widget.onApplyFilters(
      genres: _selectedGenres,
      provincia: _selectedProvincia,
      ratingRange: _selectedRatingRange,
      sortOrder: _sortOrder,
      searchQuery: _searchQuery,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido scrolleable
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 56),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filtros',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: appBarBg,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                            color: appBarBg,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Buscador
                      _buildSearchBar(),

                      const SizedBox(height: 8),

                      // Ordenamiento
                      _buildSortOptions(),

                      // Provincia
                      _buildProvinciaDropdown(),

                      // Géneros
                      _buildGenreFilter(),

                      // Rating
                      _buildRatingSlider(),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        foregroundColor: appBarBg,
                        side: BorderSide(color: Colors.blue.shade100),
                      ),
                      onPressed: _resetFilters,
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
                      onPressed: _applyFilters,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.blue.shade100),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(color: Colors.blueGrey.shade900),
        cursorColor: Colors.blueGrey.shade700,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.blueGrey.shade600),
          hintText: 'Buscar por nombre, género, ciudad, provincia o web',
          hintStyle: TextStyle(color: Colors.blueGrey.shade400),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpiar',
                  icon: Icon(Icons.clear, color: Colors.blueGrey.shade500),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ordenar por',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 6),
        const Text('Puntuación',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 6,
          children: [
            ChoiceChip(
              label: const Text('Ascendente'),
              selected: _sortOrder == SortOrder.ratingAsc,
              onSelected: (_) => setState(() => _sortOrder = SortOrder.ratingAsc),
            ),
            ChoiceChip(
              label: const Text('Descendente'),
              selected: _sortOrder == SortOrder.ratingDesc,
              onSelected: (_) =>
                  setState(() => _sortOrder = SortOrder.ratingDesc),
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
              selected: _sortOrder == SortOrder.cityAsc,
              onSelected: (_) => setState(() => _sortOrder = SortOrder.cityAsc),
            ),
            ChoiceChip(
              label: const Text('Z-A'),
              selected: _sortOrder == SortOrder.cityDesc,
              onSelected: (_) => setState(() => _sortOrder = SortOrder.cityDesc),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Provincia y Ciudad',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 6,
          children: [
            ChoiceChip(
              label: const Text('A-Z'),
              selected: _sortOrder == SortOrder.provinceCityAsc,
              onSelected: (_) =>
                  setState(() => _sortOrder = SortOrder.provinceCityAsc),
            ),
            ChoiceChip(
              label: const Text('Z-A'),
              selected: _sortOrder == SortOrder.provinceCityDesc,
              onSelected: (_) =>
                  setState(() => _sortOrder = SortOrder.provinceCityDesc),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ChoiceChip(
          label: const Text('Ninguno'),
          selected: _sortOrder == SortOrder.none,
          onSelected: (_) => setState(() => _sortOrder = SortOrder.none),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildProvinciaDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            'Provincia',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: appBarBg,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          value: _selectedProvincia,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blue.shade100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.blue.shade100),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          hint: const Text('Cualquier provincia'),
          onChanged: (value) => setState(() => _selectedProvincia = value),
          items: widget.availableProvincias.map((String provincia) {
            return DropdownMenuItem<String>(
              value: provincia,
              child: Text(provincia),
            );
          }).toList(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => setState(() => _selectedProvincia = null),
            child: const Text('Borrar selección',
                style: TextStyle(color: Color(0xFF001F54))),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildGenreFilter() {
    final allSelected = _selectedGenres.length == widget.availableGenres.length &&
        widget.availableGenres.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Género',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: appBarBg,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (allSelected) {
                      _selectedGenres.clear();
                    } else {
                      _selectedGenres = Set.from(widget.availableGenres);
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
          children: widget.availableGenres.map((genre) {
            final selected = _selectedGenres.contains(genre);
            final color = GenreUtils.getGenreColor(genre);
            final icon = GenreUtils.getGenreIcon(genre);

            return InkWell(
              onTap: () {
                setState(() {
                  if (selected) {
                    _selectedGenres.remove(genre);
                  } else {
                    _selectedGenres.add(genre);
                  }
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? color : color.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? color : color.withAlpha(100),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: selected ? Colors.white : color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      genre,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: selected ? Colors.white : color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRatingSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            'Puntuación (rango)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: appBarBg,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildRatingBox(
                label: 'Desde',
                controller: _minRatingController,
                onChanged: (value) {
                  final v = double.tryParse(value);
                  if (v != null) {
                    setState(() {
                      _selectedRatingRange =
                          RangeValues(v, _selectedRatingRange.end);
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRatingBox(
                label: 'Hasta',
                controller: _maxRatingController,
                onChanged: (value) {
                  final v = double.tryParse(value);
                  if (v != null) {
                    setState(() {
                      _selectedRatingRange =
                          RangeValues(_selectedRatingRange.start, v);
                    });
                  }
                },
              ),
            ),
          ],
        ),
        RangeSlider(
          values: _selectedRatingRange,
          min: minRating,
          max: maxRating,
          divisions: divisions,
          labels: RangeLabels(
            _selectedRatingRange.start.toStringAsFixed(1),
            _selectedRatingRange.end.toStringAsFixed(1),
          ),
          onChanged: (newRange) {
            setState(() {
              _selectedRatingRange = newRange;
              _minRatingController.text = newRange.start.toStringAsFixed(1);
              _maxRatingController.text = newRange.end.toStringAsFixed(1);
            });
          },
          activeColor: appBarBg,
          inactiveColor: const Color(0x4D0e145a),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRatingBox({
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
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.blueGrey.shade600)),
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
}
