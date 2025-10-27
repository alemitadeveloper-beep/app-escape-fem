import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../db/word_database.dart';
import '../models/word.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late Future<List<Word>> _wordsFuture;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _wordsFuture = WordDatabase.instance.getAllWords();
  }

  void _onMarkerTap(Word word) {
    if (!word.latitud.isFinite || !word.longitud.isFinite) return;

    // Mover el mapa con zoom antes de mostrar el popup
    Future.delayed(Duration.zero, () {
      try {
        _mapController.move(LatLng(word.latitud, word.longitud), 14.0);
      } catch (e) {
        debugPrint('Error al mover el mapa: $e');
      }

      showModalBottomSheet(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                word.text,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (word.puntuacion.isNotEmpty)
                Text("⭐ ${word.puntuacion}", style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Text(word.ubicacion),
              const SizedBox(height: 12),
              if (word.web.isNotEmpty && word.web != '/')
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Ver ficha"),
                )
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa de Escape Rooms")),
      body: FutureBuilder<List<Word>>(
        future: _wordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Error cargando escapes"));
          }

          final words = snapshot.data!;
          final markers = words
              .where((w) => w.latitud != 0.0 && w.longitud != 0.0)
              .map((w) => Marker(
                    point: LatLng(w.latitud, w.longitud),
                    width: 40,
                    height: 40,
                    key: ValueKey(w.id), // ✅ Clave única por ID
                    child: GestureDetector(
                      onTap: () => _onMarkerTap(w),
                      child: const Icon(Icons.location_on, color: Colors.red, size: 32),
                    ),
                  ))
              .toList();

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(40.4168, -3.7038),
              initialZoom: 5.5,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.app',
                retinaMode: true,
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }
}
