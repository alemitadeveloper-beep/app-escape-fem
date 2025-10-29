import 'package:flutter/material.dart';
import '../../data/models/word.dart';

/// Card simple para favoritos (sin expansión)
class FavoriteCard extends StatelessWidget {
  final Word word;
  final VoidCallback onDelete;

  const FavoriteCard({
    required this.word,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.blue.shade100),
      ),
      child: ListTile(
        leading: const Icon(Icons.favorite, color: Colors.redAccent),
        title: Text(
          word.text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.blueGrey.shade900,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
