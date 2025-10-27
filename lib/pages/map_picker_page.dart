import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng initial;
  const MapPickerPage({super.key, required this.initial});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final _map = MapController();
  LatLng? _picked;

  @override
  void initState() {
    super.initState();
    _picked = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegir ubicación'),
        backgroundColor: const Color(0xFF000D17),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(context, _picked),
            tooltip: 'Usar estas coordenadas',
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _map,
        options: MapOptions(
          initialCenter: widget.initial,
          initialZoom: 6.0,
          onTap: (tapPos, latLng) => setState(() => _picked = latLng),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a','b','c'],
            userAgentPackageName: 'com.example.escape_room_application',
          ),
          if (_picked != null)
            MarkerLayer(markers: [
              Marker(
                point: _picked!,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_pin, size: 36, color: Color(0xFF010521)),
              )
            ])
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: Text(
          _picked == null
              ? 'Toca en el mapa para seleccionar'
              : 'Lat: ${_picked!.latitude.toStringAsFixed(6)}  ·  Lng: ${_picked!.longitude.toStringAsFixed(6)}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
