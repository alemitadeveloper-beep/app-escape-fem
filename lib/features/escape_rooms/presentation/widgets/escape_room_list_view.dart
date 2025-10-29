import 'package:flutter/material.dart';
import '../../data/models/word.dart';
import 'escape_room_card.dart';

/// Vista de lista de escape rooms
class EscapeRoomListView extends StatelessWidget {
  final List<Word> words;
  final Function(Word) onToggleFavorite;
  final Function(Word) onTogglePlayed;
  final Function(Word) onTogglePending;

  const EscapeRoomListView({
    required this.words,
    required this.onToggleFavorite,
    required this.onTogglePlayed,
    required this.onTogglePending,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Center(
        child: Text(
          'No hay elementos para mostrar.',
          style: TextStyle(color: Colors.blueGrey.shade700),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        return EscapeRoomCard(
          word: word,
          onToggleFavorite: () => onToggleFavorite(word),
          onTogglePlayed: () => onTogglePlayed(word),
          onTogglePending: () => onTogglePending(word),
        );
      },
    );
  }
}
