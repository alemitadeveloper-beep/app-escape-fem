import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/word.dart';
import '../../../../core/widgets/genre_chip.dart';
import '../../../../core/utils/genre_utils.dart';

/// Vista de mapa de escape rooms
class EscapeRoomMapView extends StatelessWidget {
  final List<Word> words;
  final MapController mapController;
  final PopupController popupController;

  const EscapeRoomMapView({
    required this.words,
    required this.mapController,
    required this.popupController,
    super.key,
  });

  Word? _findWordByLatLng(LatLng point) {
    for (final w in words) {
      if (w.latitud == point.latitude && w.longitud == point.longitude) {
        return w;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final markers = words
        .where((w) => w.latitud != 0.0 && w.longitud != 0.0)
        .map((word) {
      return Marker(
        point: LatLng(word.latitud, word.longitud),
        width: 40,
        height: 40,
        child: const Icon(Icons.location_pin,
            color: Color(0xFF010521), size: 30),
        key: ValueKey(word.id),
      );
    }).toList();

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: const LatLng(40.4168, -3.7038),
        initialZoom: 5.5,
        interactionOptions:
            const InteractionOptions(flags: InteractiveFlag.all),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.escape_room_application',
        ),
        PopupMarkerLayer(
          options: PopupMarkerLayerOptions(
            markers: markers,
            popupController: popupController,
            markerTapBehavior: MarkerTapBehavior.togglePopupAndHideRest(),
            popupDisplayOptions: PopupDisplayOptions(
              builder: (context, marker) {
                final word = _findWordByLatLng(marker.point);
                if (word == null) return const SizedBox.shrink();

                final genres = GenreUtils.parseGenres(word.genero);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  mapController.move(marker.point, 14.0);
                });

                return Container(
                  width: 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(64),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: DefaultTextStyle(
                      style: TextStyle(
                          color: Colors.blueGrey.shade900, fontSize: 13),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            word.text,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.blueGrey.shade900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          GenreChipList(genres: genres, filled: true),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.place,
                                  size: 16, color: Colors.blueGrey),
                              const SizedBox(width: 6),
                              Expanded(
                                  child: Text('Ubicación: ${word.ubicacion}')),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: Colors.blueGrey),
                              const SizedBox(width: 6),
                              Text('Puntuación: ${word.puntuacion}'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Web: ${word.web}',
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.lightBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
