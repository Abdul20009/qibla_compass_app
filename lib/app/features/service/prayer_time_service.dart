import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimesService {
  /// Calculates prayer times for [position] on [date].
  /// Uses Umm al-Qura calculation method by default (matches settings screen).
  static PrayerTimes calculate({
    required Position position,
    required DateTime date,
    CalculationParameters? params,
  }) {
    final coordinates = Coordinates(position.latitude, position.longitude);
    final dateComponents = DateComponents.from(date);
    final parameters = params ?? CalculationMethod.umm_al_qura.getParameters();

    return PrayerTimes(coordinates, dateComponents, parameters);
  }

  /// Returns the [Prayer] that is currently active, or null if between Isha and Fajr.
  static Prayer? currentPrayer(PrayerTimes times) {
    return times.currentPrayer();
  }

  /// Returns the next [Prayer] after now.
  static Prayer? nextPrayer(PrayerTimes times) {
    return times.nextPrayer();
  }

  /// Time remaining until [target] from [now].
  static Duration timeUntil(DateTime target) {
    final diff = target.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Human-readable prayer name from [Prayer] enum.
  static String prayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      case Prayer.none:
        return 'None';
    }
  }

  /// Formats a [DateTime] to a 24h time string e.g. "05:12".
  static String formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Formats a [DateTime] to 12h time string e.g. "5:12 AM".
  static String formatTime12h(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Returns a CalculationParameters for a given method name.
  static CalculationParameters paramsForMethod(String method) {
    switch (method) {
      case 'Muslim World League':
        return CalculationMethod.muslim_world_league.getParameters();
      case 'Egyptian':
        return CalculationMethod.egyptian.getParameters();
      case 'Karachi':
        return CalculationMethod.karachi.getParameters();
      case 'North America':
        return CalculationMethod.north_america.getParameters();
      case 'Kuwait':
        return CalculationMethod.kuwait.getParameters();
      case 'Qatar':
        return CalculationMethod.qatar.getParameters();
      case 'Singapore':
        return CalculationMethod.singapore.getParameters();
      case 'Tehran':
        return CalculationMethod.tehran.getParameters();
      case 'Turkey':
        return CalculationMethod.turkey.getParameters();
      case 'Umm al-Qura':
      default:
        return CalculationMethod.umm_al_qura.getParameters();
    }
  }

  /// All supported calculation method names.
  static List<String> get supportedMethods => [
        'Umm al-Qura',
        'Muslim World League',
        'Egyptian',
        'Karachi',
        'North America',
        'Kuwait',
        'Qatar',
        'Singapore',
        'Tehran',
        'Turkey',
      ];
}