import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

class Mosque {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double distanceKm;

  const Mosque({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
  });

  String get distanceLabel {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// Estimated walking time in minutes (avg 5 km/h)
  String get walkingTime {
    final minutes = (distanceKm / 5 * 60).round();
    if (minutes < 1) return '< 1 min';
    return '$minutes min';
  }

  /// Google Maps directions URL
  String get mapsUrl =>
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=walking';

  /// Google Maps search URL fallback
  static String searchUrl(double lat, double lng) =>
      'https://www.google.com/maps/search/mosque/@$lat,$lng,15z';
}

class MosqueService {
  static const String _overpassUrl =
      'https://overpass-api.de/api/interpreter';

  /// Fetch mosques within [radiusMeters] of [lat],[lng].
  /// Returns up to [limit] results sorted by distance.
  static Future<List<Mosque>> fetchNearby({
    required double lat,
    required double lng,
    int radiusMeters = 3000,
    int limit = 15,
  }) async {
    final query = '''
[out:json][timeout:25];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$lat,$lng);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$lat,$lng);
  relation["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$lat,$lng);
);
out center tags;
''';

    final response = await http.post(
      Uri.parse(_overpassUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'data=${Uri.encodeComponent(query)}',
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch mosques (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = data['elements'] as List<dynamic>;

    final mosques = <Mosque>[];

    for (final el in elements) {
      final tags = el['tags'] as Map<String, dynamic>? ?? {};
      final name = tags['name'] ??
          tags['name:en'] ??
          tags['name:ar'] ??
          'Mosque';

      double? elLat;
      double? elLng;

      if (el['type'] == 'node') {
        elLat = (el['lat'] as num?)?.toDouble();
        elLng = (el['lon'] as num?)?.toDouble();
      } else {
        // way/relation → use center
        final center = el['center'] as Map<String, dynamic>?;
        elLat = (center?['lat'] as num?)?.toDouble();
        elLng = (center?['lon'] as num?)?.toDouble();
      }

      if (elLat == null || elLng == null) continue;

      final dist = _haversine(lat, lng, elLat, elLng);

      mosques.add(Mosque(
        id: el['id'].toString(),
        name: name.toString(),
        latitude: elLat,
        longitude: elLng,
        distanceKm: dist,
      ));
    }

    mosques.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return mosques.take(limit).toList();
  }

  static double _haversine(
      double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _rad(double deg) => deg * math.pi / 180;
}