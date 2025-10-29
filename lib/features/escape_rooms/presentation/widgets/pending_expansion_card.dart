import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/word.dart';
import '../../../../core/widgets/genre_chip.dart';
import '../../../../core/utils/genre_utils.dart';

/// Card expandible para escape rooms pendientes
class PendingExpansionCard extends StatelessWidget {
  final Word word;
  final VoidCallback onDelete;

  const PendingExpansionCard({
    required this.word,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final genres = GenreUtils.parseGenres(word.genero);

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
              leading: const Icon(Icons.access_time, color: Colors.lightBlue),
              title: Text(
                word.text,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.blueGrey.shade900,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                // Chips de géneros
                if (genres.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GenreChipList(genres: genres, filled: false),
                  ),
                const SizedBox(height: 10),

                // Ubicación
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.place, color: Colors.blueGrey),
                    const SizedBox(width: 8),
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
                const SizedBox(height: 10),

                // Botón abrir web
                if (word.web.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: () => _openWeb(context, word.web),
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Abrir web'),
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 8),
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openWeb(BuildContext context, String web) async {
    final uri = Uri.tryParse(web);
    if (uri == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
      return;
    }
    final bool canLaunch = await canLaunchUrl(uri);
    if (!context.mounted) return;
    if (canLaunch) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }
}
