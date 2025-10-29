import 'package:flutter/material.dart';

/// Barra de búsqueda reutilizable con estética de card
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;

  const SearchBarWidget({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'Buscar...',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.blue.shade100),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(color: Colors.blueGrey.shade900),
          cursorColor: Colors.blueGrey.shade700,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.blueGrey.shade600),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.blueGrey.shade400),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Limpiar',
                    icon: Icon(Icons.clear, color: Colors.blueGrey.shade500),
                    onPressed: onClear,
                  ),
          ),
        ),
      ),
    );
  }
}
