import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/word.dart';
import '../../../../core/widgets/star_rating.dart';
import '../../../../core/widgets/genre_chip.dart';
import '../../../../core/widgets/played_badge.dart';
import '../../../../core/utils/genre_utils.dart';
import '../../../../core/utils/rating_utils.dart';

/// Tarjeta individual de escape room para lista
class EscapeRoomCard extends StatelessWidget {
  final Word word;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTogglePlayed;
  final VoidCallback onTogglePending;

  const EscapeRoomCard({
    required this.word,
    required this.onToggleFavorite,
    required this.onTogglePlayed,
    required this.onTogglePending,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final genres = GenreUtils.parseGenres(word.genero);
    final rating = RatingUtils.parsePuntuacion(word.puntuacion);

    return Card(
      clipBehavior: Clip.antiAlias,
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
                // Título
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

                // Chips de géneros
                if (genres.isNotEmpty)
                  GenreChipList(genres: genres, filled: true),

                const SizedBox(height: 8),

                // Ubicación
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.place, color: Colors.blueGrey, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        word.ubicacion,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Estrellas + número
                Row(
                  children: [
                    StarRating(rating: rating),
                    if (rating > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        rating.toStringAsFixed(1),
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

                // Botón Abrir web
                if (word.web.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: () => _openWeb(context, word.web),
                      icon: const Icon(Icons.open_in_browser,
                          color: Color(0xFF001F54)),
                      label: const Text('Abrir web',
                          style: TextStyle(color: Color(0xFF001F54))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade900,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                const SizedBox(height: 4),

                // Acciones: Jugado / Pendiente / Favorito
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Jugado
                    IconButton(
                      tooltip: word.isPlayed
                          ? 'Marcado como jugado'
                          : 'Marcar como jugado',
                      icon: Icon(
                        word.isPlayed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: word.isPlayed
                            ? Colors.blue.shade700
                            : Colors.blueGrey.shade400,
                        size: 24,
                      ),
                      onPressed: onTogglePlayed,
                    ),

                    // Pendiente
                    IconButton(
                      tooltip: word.isPending
                          ? 'Marcado como pendiente'
                          : 'Marcar como pendiente',
                      icon: Icon(
                        word.isPending
                            ? Icons.schedule
                            : Icons.schedule_outlined,
                        color: word.isPending
                            ? Colors.orange
                            : Colors.blueGrey.shade400,
                        size: 22,
                      ),
                      onPressed: onTogglePending,
                    ),

                    // Favorito
                    IconButton(
                      tooltip: word.isFavorite
                          ? 'Quitar favorito'
                          : 'Marcar favorito',
                      icon: Icon(
                        word.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: word.isFavorite
                            ? Colors.redAccent
                            : Colors.blueGrey.shade400,
                        size: 24,
                      ),
                      onPressed: onToggleFavorite,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Badge "Jugado" en la esquina
          if (word.isPlayed)
            const Positioned(
              top: 0,
              right: 0,
              child: PlayedBadge(),
            ),
        ],
      ),
    );
  }

  Future<void> _openWeb(BuildContext context, String web) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(web);
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
  }
}
