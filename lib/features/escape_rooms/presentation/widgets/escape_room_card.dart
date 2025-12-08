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
  final VoidCallback onTogglePlayed;
  final VoidCallback onTogglePending;

  const EscapeRoomCard({
    required this.word,
    required this.onTogglePlayed,
    required this.onTogglePending,
    super.key,
  });

  /// Valida si una URL es válida (no vacía, no "/" y parseable)
  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    if (url == '/' || url == '#') return false;
    final uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    final genres = GenreUtils.parseGenres(word.genero);
    final rating = RatingUtils.parsePuntuacion(word.puntuacion);
    final hasValidWeb = _isValidUrl(word.web);

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              if (word.imagenUrl != null && word.imagenUrl!.isNotEmpty)
                Container(
                  width: 100,
                  height: 140,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      word.imagenUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade400,
                            size: 40,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Información
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        word.text,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.blueGrey.shade900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Empresa (sin link)
                      if (word.empresa != null && word.empresa!.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.business,
                              color: Colors.blueGrey.shade600,
                              size: 14
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                word.empresa!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blueGrey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 6),

                      // Chips de géneros
                      if (genres.isNotEmpty)
                        GenreChipList(genres: genres, filled: true),

                      const SizedBox(height: 6),

                      // Descripción breve
                      if (word.descripcion != null && word.descripcion!.isNotEmpty)
                        Text(
                          word.descripcion!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blueGrey.shade700,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 6),

                      // Duración y Jugadores
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          if (word.duracion != null && word.duracion!.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time,
                                  color: Colors.blueGrey.shade600,
                                  size: 14
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  word.duracion!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blueGrey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          if (word.jugadores != null && word.jugadores!.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.people,
                                  color: Colors.blueGrey.shade600,
                                  size: 14
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  word.jugadores!.replaceAll('De ', '').replaceAll(' jugadores', ''),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blueGrey.shade700,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Ubicación
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.place, color: Colors.blueGrey, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              word.ubicacion,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blueGrey.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

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
                                fontSize: 16,
                                color: Colors.blueGrey.shade900,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Botón Abrir web (solo si URL válida)
                      if (hasValidWeb)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: () => _openWeb(context, word.web),
                            icon: const Icon(Icons.open_in_browser,
                                color: Color(0xFF001F54), size: 14),
                            label: const Text('Abrir web',
                                style: TextStyle(color: Color(0xFF001F54), fontSize: 11)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade100,
                              foregroundColor: Colors.blue.shade900,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),

                      const SizedBox(height: 4),

                      // Acciones: Jugado / Pendiente
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
                              size: 20,
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
                              size: 18,
                            ),
                            onPressed: onTogglePending,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
