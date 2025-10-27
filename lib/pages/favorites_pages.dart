import 'package:flutter/material.dart';
import '../db/word_database.dart';
import '../models/word.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  FavoritesPageState createState() => FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Word> _favorites = [];
  List<Word> _played = [];
  List<Word> _pending = [];
  List<Word> _ranking = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  void _handleTabSelection() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final favorites = await WordDatabase.instance.readFavorites();
    final played = await WordDatabase.instance.readPlayed();
    final pending = await WordDatabase.instance.readPending();

    if (!mounted) return;

    final rankingList = [...played]..sort(
      (a, b) => _calculateAverageRating(b).compareTo(_calculateAverageRating(a)),
    );

    setState(() {
      _favorites = favorites;
      _played = played;
      _pending = pending;
      _ranking = rankingList;
    });
  }

  double _calculateAverageRating(Word word) {
    int sum = 0;
    int count = 0;
    if (word.historiaRating != null && word.historiaRating! > 0) {
      sum += word.historiaRating!;
      count++;
    }
    if (word.ambientacionRating != null && word.ambientacionRating! > 0) {
      sum += word.ambientacionRating!;
      count++;
    }
    if (word.jugabilidadRating != null && word.jugabilidadRating! > 0) {
      sum += word.jugabilidadRating!;
      count++;
    }
    if (word.gameMasterRating != null && word.gameMasterRating! > 0) {
      sum += word.gameMasterRating!;
      count++;
    }
    if (word.miedoRating != null && word.miedoRating! > 0) {
      sum += word.miedoRating!;
      count++;
    }
    return count > 0 ? sum / count : 0.0;
  }

  Widget _buildRatingRow(IconData icon, String label, int value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey.shade700),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700),
        ),
      ],
    );
  }

  Widget _buildStarRating(double rating, {double size = 18}) {
    double scaledRating = rating;
    if (rating > 5) {
      scaledRating = rating / 2.0;
    }
    int fullStars = scaledRating.floor();
    bool hasHalfStar = (scaledRating - fullStars) >= 0.5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: Colors.cyan.shade300, size: size);
        } else if (index == fullStars && hasHalfStar) {
          return Icon(Icons.star_half, color: Colors.cyan.shade300, size: size);
        } else {
          return Icon(Icons.star_border, color: Colors.blue.shade100, size: size);
        }
      }),
    );
  }

  /// ===== Colores de chips por género (igual que en word_list_page) =====
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

  Future<String> saveImagePermanently(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(image.path);
    final imagePath = join(directory.path, name);
    final newImage = await image.copy(imagePath);
    return newImage.path;
  }

  void _openReviewDialog(BuildContext context, Word word) {
    DateTime selectedDate = word.datePlayed ?? DateTime.now();
    final TextEditingController commentController = TextEditingController(text: word.review ?? '');
    File? selectedImage = word.photoPath != null ? File(word.photoPath!) : null;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        int historiaRating = word.historiaRating ?? 5;
        int ambientacionRating = word.ambientacionRating ?? 5;
        int jugabilidadRating = word.jugabilidadRating ?? 5;
        int gameMasterRating = word.gameMasterRating ?? 5;
        int miedoRating = word.miedoRating ?? 5;

        Widget buildRatingSlider(String label, int value, ValueChanged<double> onChanged) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$label: $value', style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700)),
              Slider(
                value: value.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: value.toString(),
                onChanged: onChanged,
                activeColor: Colors.blue.shade700,
                inactiveColor: Colors.blue.shade100,
              ),
            ],
          );
        }

        return StatefulBuilder(
          builder: (BuildContext innerContext, StateSetter setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Text(
                'Reseña: ${word.text}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF001F54)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today, color: Colors.blueGrey),
                      label: Text(
                        'Fecha: ${selectedDate.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(color: Colors.blueGrey.shade700),
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setStateDialog(() {
                            selectedDate = date;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildStarRating(_calculateAverageRating(word)),
                    const SizedBox(height: 8),
                    buildRatingSlider('Historia', historiaRating, (val) => setStateDialog(() => historiaRating = val.toInt())),
                    buildRatingSlider('Ambientación', ambientacionRating, (val) => setStateDialog(() => ambientacionRating = val.toInt())),
                    buildRatingSlider('Jugabilidad', jugabilidadRating, (val) => setStateDialog(() => jugabilidadRating = val.toInt())),
                    buildRatingSlider('GameMaster', gameMasterRating, (val) => setStateDialog(() => gameMasterRating = val.toInt())),
                    buildRatingSlider('Miedo', miedoRating, (val) => setStateDialog(() => miedoRating = val.toInt())),
                    TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        labelText: 'Comentario',
                        labelStyle: TextStyle(color: Colors.blueGrey.shade700),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue.shade100),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          final savedPath = await saveImagePermanently(File(pickedFile.path));
                          setStateDialog(() {
                            selectedImage = File(savedPath);
                          });
                        }
                      },
                      icon: const Icon(Icons.photo, color: Color(0xFF001F54)),
                      label: const Text('Seleccionar imagen', style: TextStyle(color: Color(0xFF001F54))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                    if (selectedImage?.existsSync() == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(selectedImage!, height: 100, fit: BoxFit.cover),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cancelar', style: TextStyle(color: Colors.blueGrey.shade700)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final navigator = Navigator.of(dialogContext);
                    await WordDatabase.instance.updateReview(
                      word.id!,
                      selectedDate,
                      word.personalRating ?? 0,
                      commentController.text.trim(),
                      selectedImage?.path,
                      historiaRating,
                      ambientacionRating,
                      jugabilidadRating,
                      gameMasterRating,
                      miedoRating,
                    );
                    if (!mounted) return;
                    await _loadData();
                    navigator.pop();
                  },
                  child: Text('Guardar', style: TextStyle(color: Color(0xFF001F54))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    elevation: 0,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCardItem(
    BuildContext context,
    Word word,
    IconData icon,
    Color color,
    VoidCallback onDelete,
    bool isRanking
  ) {
    final isPlayed = icon == Icons.check_circle || isRanking;
    final hasReviewData = word.datePlayed != null ||
        (word.review != null && word.review!.isNotEmpty) ||
        (word.photoPath != null && File(word.photoPath!).existsSync());

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.blue.shade100),
      ),
      child: isPlayed && hasReviewData
          ? ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: isRanking
                  ? Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '#${_ranking.indexOf(word) + 1}',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : Icon(icon, color: color),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      word.text,
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.blueGrey.shade900),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_calculateAverageRating(word) > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.cyan.shade300, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _calculateAverageRating(word).toStringAsFixed(1),
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.blueGrey.shade900),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                if (word.datePlayed != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.blueGrey),
                        const SizedBox(width: 6),
                        Text(
                          'Jugado el: ${word.datePlayed!.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700),
                        ),
                      ],
                    ),
                  ),
                if (word.review != null && word.review!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '“${word.review!}”',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: Colors.blueGrey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (word.historiaRating != null || word.ambientacionRating != null || word.jugabilidadRating != null || word.gameMasterRating != null || word.miedoRating != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRatingRow(Icons.menu_book, 'Historia', word.historiaRating ?? 0),
                            const SizedBox(height: 6),
                            _buildRatingRow(Icons.landscape, 'Ambientación', word.ambientacionRating ?? 0),
                            const SizedBox(height: 6),
                            _buildRatingRow(Icons.videogame_asset, 'Jugabilidad', word.jugabilidadRating ?? 0),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRatingRow(Icons.person, 'GameMaster', word.gameMasterRating ?? 0),
                            const SizedBox(height: 6),
                            _buildRatingRow(Icons.flash_on, 'Miedo', word.miedoRating ?? 0),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (word.photoPath != null && File(word.photoPath!).existsSync())
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(word.photoPath!), height: 100, fit: BoxFit.cover),
                    ),
                  ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.lightBlue),
                    tooltip: 'Editar reseña',
                    onPressed: () {
                      _openReviewDialog(context, word);
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            )
          : ListTile(
              leading: Icon(icon, color: color),
              title: Text(
                word.text,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.blueGrey.shade900),
              ),
              trailing: isPlayed
                ? IconButton(
                    icon: const Icon(Icons.edit, color: Colors.lightBlue),
                    onPressed: () => _openReviewDialog(context, word),
                  )
                : IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: onDelete,
                  ),
            ),
    );
  }

  Widget _buildList(List<Word> words, {required bool isPlayedList, bool isPendingList = false}) {
    if (words.isEmpty) {
      return Center(
        child: Text(
          'No hay elementos para mostrar.',
          style: TextStyle(color: Colors.blueGrey.shade700),
        ),
      );
    }

    return ListView.builder(
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        if (isPendingList) {
          // ---- Tarjeta PENDIENTES con chips de género coloreados ----
          final generoStr = (word.genero ?? '').trim();
          final generos = generoStr.isEmpty
              ? <String>[]
              : generoStr.split('/').map((g) => g.trim()).where((g) => g.isNotEmpty).toList();

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.blue.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ExpansionTile(
                    leading: Icon(Icons.access_time, color: Colors.lightBlue),
                    title: Text(
                      word.text,
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.blueGrey.shade900),
                      overflow: TextOverflow.ellipsis,
                    ),
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    children: [
                      if (generos.isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: generos.map((g) {
                              final c = _getGenreColor(g);
                              return Chip(
                                label: Text(g, style: TextStyle(color: c)),
                                backgroundColor: c.withAlpha(40),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(color: c.withAlpha(120)),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.place, color: Colors.blueGrey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              word.ubicacion,
                              style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (word.web != null && word.web!.isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final uri = Uri.tryParse(word.web!);
                              if (uri == null) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('No se pudo abrir el enlace')),
                                );
                                return;
                              }
                              final bool canLaunch = await canLaunchUrl(uri);
                              if (!mounted) return;
                              if (canLaunch) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('No se pudo abrir el enlace')),
                                );
                              }
                            },
                            icon: const Icon(Icons.open_in_browser),
                            label: const Text('Abrir web'),
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12, right: 8),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      await WordDatabase.instance.togglePending(word.id!, false);
                      _loadData();
                    },
                  ),
                ),
              ],
            ),
          );
        }
        // ---- Favoritos y Jugados ----
        return _buildCardItem(
          context,
          word,
          isPlayedList ? Icons.check_circle : Icons.favorite,
          isPlayedList ? Colors.blue.shade700 : Colors.redAccent,
          () async {
            if (isPlayedList) {
              await WordDatabase.instance.togglePlayed(word.id!, false);
            } else {
              await WordDatabase.instance.toggleFavorite(word.id!, false);
            }
            _loadData();
          },
          false
        );
      },
    );
  }

  Widget _buildRankingList(List<Word> words) {
    if (words.isEmpty) {
      return Center(
        child: Text(
          'No hay escape rooms jugados con puntuación.',
          style: TextStyle(color: Colors.blueGrey.shade700),
        ),
      );
    }

    return ListView.builder(
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        final averageRating = _calculateAverageRating(word);
        if (averageRating == 0.0) {
          return const SizedBox.shrink();
        }
        return _buildCardItem(
          context,
          word,
          Icons.check_circle,
          Colors.blue.shade900,
          () async {},
          true
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mis Escape Rooms',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF000D17),
        elevation: 2,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF000D17),
            child: CupertinoTabBar(
              currentIndex: _tabController.index,
              onTap: (index) {
                _tabController.animateTo(index);
              },
              backgroundColor: const Color(0xFF000D17),
              activeColor: Colors.lightBlueAccent.shade100,
              inactiveColor: Colors.blueGrey.shade100,
              items: List.generate(4, (index) {
                final isSelected = _tabController.index == index;
                double iconSize = isSelected ? 30.0 : 24.0;
                return BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      [
                        Icons.favorite,
                        Icons.check_circle,
                        Icons.access_time,
                        Icons.emoji_events,
                      ][index],
                      size: iconSize,
                    ),
                  ),
                  label: [
                    'Favoritos',
                    'Jugados',
                    'Pendientes',
                    'Ranking'
                  ][index],
                );
              }),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(_favorites, isPlayedList: false),
                _buildList(_played, isPlayedList: true),
                _buildList(_pending, isPlayedList: false, isPendingList: true),
                _buildRankingList(_ranking),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
