import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/word.dart';
import '../../../../core/widgets/star_rating.dart';
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFF001F54).withValues(alpha: 0.15),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Puedes agregar navegación a página de detalles aquí si quieres
        },
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con gradiente decorativo (sin imagen)
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF001F54),
                        const Color(0xFF003D82),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),

                // Contenido de información
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título más grande y destacado
                      Text(
                        word.text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF001F54),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Rating destacado
                      if (rating > 0)
                        Row(
                          children: [
                            StarRating(rating: rating),
                            const SizedBox(width: 8),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF001F54),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/ 5.0',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 12),

                      // Empresa
                      if (word.empresa != null && word.empresa!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.business,
                                color: Colors.blue.shade700,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  word.empresa!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Chips de géneros (más visibles)
                      if (genres.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: genres.take(3).map((genre) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.purple.shade200),
                              ),
                              child: Text(
                                genre,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.purple.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 12),

                      // Descripción
                      if (word.descripcion != null && word.descripcion!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            word.descripcion!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      // Información práctica en cards
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            // Duración
                            if (word.duracion != null && word.duracion!.isNotEmpty)
                              _InfoRow(
                                icon: Icons.access_time,
                                label: 'Duración',
                                value: word.duracion!,
                                iconColor: Colors.orange.shade600,
                              ),

                            if (word.duracion != null && word.duracion!.isNotEmpty &&
                                word.jugadores != null && word.jugadores!.isNotEmpty)
                              Divider(height: 16, color: Colors.grey.shade300),

                            // Jugadores
                            if (word.jugadores != null && word.jugadores!.isNotEmpty)
                              _InfoRow(
                                icon: Icons.people,
                                label: 'Jugadores',
                                value: word.jugadores!
                                    .replaceAll('De ', '')
                                    .replaceAll(' jugadores', ''),
                                iconColor: Colors.green.shade600,
                              ),

                            if ((word.duracion != null && word.duracion!.isNotEmpty) ||
                                (word.jugadores != null && word.jugadores!.isNotEmpty))
                              Divider(height: 16, color: Colors.grey.shade300),

                            // Ubicación
                            _InfoRow(
                              icon: Icons.place,
                              label: 'Ubicación',
                              value: word.ubicacion,
                              iconColor: Colors.red.shade600,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Botones de acción
                      Row(
                        children: [
                          // Botón web
                          if (hasValidWeb)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _openWeb(context, word.web),
                                icon: const Icon(Icons.open_in_browser, size: 18),
                                label: const Text(
                                  'Ver sitio web',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF001F54),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ),

                          const SizedBox(width: 8),

                          // Botón Jugado
                          Container(
                            decoration: BoxDecoration(
                              color: word.isPlayed
                                  ? Colors.blue.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: word.isPlayed
                                    ? Colors.blue.shade300
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: IconButton(
                              tooltip: word.isPlayed ? 'Ya jugado' : 'Marcar como jugado',
                              icon: Icon(
                                word.isPlayed ? Icons.check_circle : Icons.circle_outlined,
                                color: word.isPlayed
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade600,
                                size: 24,
                              ),
                              onPressed: onTogglePlayed,
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Botón Pendiente
                          Container(
                            decoration: BoxDecoration(
                              color: word.isPending
                                  ? Colors.orange.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: word.isPending
                                    ? Colors.orange.shade300
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: IconButton(
                              tooltip: word.isPending ? 'En pendientes' : 'Agregar a pendientes',
                              icon: Icon(
                                word.isPending ? Icons.schedule : Icons.schedule_outlined,
                                color: word.isPending
                                    ? Colors.orange.shade700
                                    : Colors.grey.shade600,
                                size: 24,
                              ),
                              onPressed: onTogglePending,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Badge "Jugado" en la esquina superior derecha
            if (word.isPlayed)
              const Positioned(
                top: 12,
                right: 12,
                child: PlayedBadge(),
              ),
          ],
        ),
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

/// Widget auxiliar para mostrar filas de información con icono y texto
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF001F54),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
