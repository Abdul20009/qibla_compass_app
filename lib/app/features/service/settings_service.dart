import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyMethod = 'prayer_method';
  static const _keyAsr = 'asr_method';
  static const _keyAlerts = 'prayer_alerts';
  static const _keyVibrate = 'vibrate_on_qibla';
  static const _keyNotifPrefix = 'notif_';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    assert(_prefs != null, 'Call SettingsService.init() first');
    return _prefs!;
  }

  // ── Prayer calculation method ──────────────────────────────────────────────

  static String get prayerMethod =>
      _p.getString(_keyMethod) ?? 'Umm al-Qura';

  static Future<void> setPrayerMethod(String method) =>
      _p.setString(_keyMethod, method);

  // ── Asr jurisprudence ──────────────────────────────────────────────────────

  static String get asrMethod => _p.getString(_keyAsr) ?? 'Standard';

  static Future<void> setAsrMethod(String method) =>
      _p.setString(_keyAsr, method);

  // ── Global prayer alerts toggle ────────────────────────────────────────────

  static bool get prayerAlerts => _p.getBool(_keyAlerts) ?? true;

  static Future<void> setPrayerAlerts(bool value) =>
      _p.setBool(_keyAlerts, value);

  // ── Vibrate on Qibla ──────────────────────────────────────────────────────

  static bool get vibrateOnQibla => _p.getBool(_keyVibrate) ?? true;

  static Future<void> setVibrateOnQibla(bool value) =>
      _p.setBool(_keyVibrate, value);

  // ── Per-prayer notification toggles ───────────────────────────────────────

  static bool getPrayerNotif(String prayer) =>
      _p.getBool('$_keyNotifPrefix$prayer') ??
      (prayer == 'Asr' ? false : true); // Asr off by default

  static Future<void> setPrayerNotif(String prayer, bool value) =>
      _p.setBool('$_keyNotifPrefix$prayer', value);

  static Map<String, bool> get allPrayerNotifs => {
        'Fajr': getPrayerNotif('Fajr'),
        'Dhuhr': getPrayerNotif('Dhuhr'),
        'Asr': getPrayerNotif('Asr'),
        'Maghrib': getPrayerNotif('Maghrib'),
        'Isha': getPrayerNotif('Isha'),
      };
}