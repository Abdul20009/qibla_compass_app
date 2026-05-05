import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Requests permission and returns the current [Position].
  /// Throws a descriptive [Exception] if permission is denied or
  /// location services are disabled.
  static Future<Position> getCurrentPosition() async {
    // 1. Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Please enable them in your device settings.',
      );
    }

    // 2. Check / request permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permission denied. Please allow location access to determine Qibla direction.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently denied. Please enable it from app settings.',
      );
    }

    // 3. Get position
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Returns a human-readable city/country string from coordinates.
  /// Falls back to coordinate string if geocoding is unavailable.
  static String formatCoordinates(double lat, double lng) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lngDir = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(4)}°$latDir, '
        '${lng.abs().toStringAsFixed(4)}°$lngDir';
  }
}