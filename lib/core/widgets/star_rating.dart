import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar rating en estrellas
class StarRating extends StatelessWidget {
  final double rating; // 0-10
  final int maxStars;
  final double starSize;

  const StarRating({
    required this.rating,
    this.maxStars = 5,
    this.starSize = 20,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedRating = rating / 2.0; // Convertir 0-10 a 0-5
    final fullStars = normalizedRating.floor();
    final hasHalfStar = (normalizedRating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: Colors.cyan.shade300, size: starSize);
        } else if (index == fullStars && hasHalfStar) {
          return Icon(Icons.star_half, color: Colors.cyan.shade300, size: starSize);
        } else {
          return Icon(Icons.star_border, color: Colors.blue.shade100, size: starSize);
        }
      }),
    );
  }
}
