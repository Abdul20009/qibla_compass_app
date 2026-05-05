import 'dart:math' as math;

class QiblaService {
  // Kaaba coordinates
  static const double _kaabatLat = 21.4225;
  static const double _kaabatLng = 39.8262;

  /// Calculates the Qibla bearing in degrees from North (0–360)
  /// given the user's [latitude] and [longitude].
  static double calculateQiblaBearing(double latitude, double longitude) {
    final lat1 = _toRad(latitude);
    final lat2 = _toRad(_kaabatLat);
    final deltaLng = _toRad(_kaabatLng - longitude);

    final y = math.sin(deltaLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLng);

    final bearing = math.atan2(y, x);
    // Normalize to 0–360
    return (_toDeg(bearing) + 360) % 360;
  }

  /// Distance to Kaaba in km using Haversine formula
  static double distanceToKaaba(double latitude, double longitude) {
    const earthRadius = 6371.0;
    final dLat = _toRad(_kaabatLat - latitude);
    final dLng = _toRad(_kaabatLng - longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(latitude)) *
            math.cos(_toRad(_kaabatLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  /// Returns cardinal direction label from bearing degrees
  static String bearingToCardinal(double bearing) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N'];
    return directions[(bearing / 45).round() % 8];
  }

  static double _toRad(double deg) => deg * math.pi / 180;
  static double _toDeg(double rad) => rad * 180 / math.pi;
}