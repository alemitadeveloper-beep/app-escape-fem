import 'package:flutter/material.dart';

/// Badge "Jugado" para mostrar en la esquina de las tarjetas
class PlayedBadge extends StatelessWidget {
  const PlayedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF015526), // verde oscuro
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          topRight: Radius.circular(10),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check, size: 14, color: Colors.white),
          SizedBox(width: 6),
          Text(
            'Jugado',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
