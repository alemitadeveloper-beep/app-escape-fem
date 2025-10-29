import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/word.dart';
import '../../../../core/utils/rating_utils.dart';

/// Card expandible para escape rooms jugados con reseñas
class PlayedExpansionCard extends StatelessWidget {
  final Word word;
  final VoidCallback onEdit;
  final bool isRanking;
  final int? rankingPosition;

  const PlayedExpansionCard({
    required this.word,
    required this.onEdit,
    this.isRanking = false,
    this.rankingPosition,
    super.key,
  });

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

  @override
  Widget build(BuildContext context) {
    final averageRating = RatingUtils.calculateAverageRating(word);
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
      child: hasReviewData
          ? ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: isRanking && rankingPosition != null
                  ? Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '#$rankingPosition',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : const Icon(Icons.check_circle, color: Colors.blue),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      word.text,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.blueGrey.shade900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (averageRating > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.cyan.shade300, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.blueGrey.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                // Fecha jugado
                if (word.datePlayed != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.blueGrey),
                        const SizedBox(width: 6),
                        Text(
                          'Jugado el: ${word.datePlayed!.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Comentario/Review
                if (word.review != null && word.review!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '"${word.review!}"',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: Colors.blueGrey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Ratings detallados
                if (word.historiaRating != null ||
                    word.ambientacionRating != null ||
                    word.jugabilidadRating != null ||
                    word.gameMasterRating != null ||
                    word.miedoRating != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRatingRow(Icons.menu_book, 'Historia',
                                word.historiaRating ?? 0),
                            const SizedBox(height: 6),
                            _buildRatingRow(Icons.landscape, 'Ambientación',
                                word.ambientacionRating ?? 0),
                            const SizedBox(height: 6),
                            _buildRatingRow(Icons.videogame_asset,
                                'Jugabilidad', word.jugabilidadRating ?? 0),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRatingRow(Icons.person, 'GameMaster',
                                word.gameMasterRating ?? 0),
                            const SizedBox(height: 6),
                            _buildRatingRow(
                                Icons.flash_on, 'Miedo', word.miedoRating ?? 0),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Foto
                if (word.photoPath != null && File(word.photoPath!).existsSync())
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(word.photoPath!),
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // Botón editar
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.lightBlue),
                    tooltip: 'Editar reseña',
                    onPressed: onEdit,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            )
          : ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.blue),
              title: Text(
                word.text,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.blueGrey.shade900,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.lightBlue),
                onPressed: onEdit,
              ),
            ),
    );
  }
}
