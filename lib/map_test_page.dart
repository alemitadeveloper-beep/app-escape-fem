import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa de prueba")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(40.4168, -3.7038),
          initialZoom: 6.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            retinaMode: true,
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: const LatLng(40.4168, -3.7038),
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.red, size: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
