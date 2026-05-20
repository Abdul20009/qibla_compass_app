import 'package:adhan/adhan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qibla_compass_app/app/features/service/prayer_time_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channelId = 'prayer_times';
  static const _channelName = 'Prayer Times';
  static const _channelDesc = 'Adhan notifications for each prayer time';

  static const Map<Prayer, int> _notifIds = {
    Prayer.fajr: 1,
    Prayer.dhuhr: 2,
    Prayer.asr: 3,
    Prayer.maghrib: 4,
    Prayer.isha: 5,
  };

  static Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
    );

    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true;
  }

  static Future<void> schedulePrayerNotifications({
    required PrayerTimes times,
    required Map<Prayer, bool> enabledPrayers,
  }) async {
    await cancelAll();

    final prayers = {
      Prayer.fajr: times.fajr,
      Prayer.dhuhr: times.dhuhr,
      Prayer.asr: times.asr,
      Prayer.maghrib: times.maghrib,
      Prayer.isha: times.isha,
    };

    for (final entry in prayers.entries) {
      final prayer = entry.key;
      final time = entry.value;

      if (!(enabledPrayers[prayer] ?? false)) continue;
      if (time.isBefore(DateTime.now())) continue;

      await _scheduleOne(
        id: _notifIds[prayer]!,
        title: '🕌 ${PrayerTimesService.prayerName(prayer)} Prayer',
        body: "It's time for ${PrayerTimesService.prayerName(prayer)} — "
            '${PrayerTimesService.formatTime12h(time)}',
        scheduledTime: time,
      );
    }
  }

  static Future<void> _scheduleOne({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: tzTime,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      title: title,
      body: body,
      payload: 'prayer_$id',
    );
  }

  static Future<void> cancelPrayer(Prayer prayer) async {
    final id = _notifIds[prayer];
    if (id != null) await _plugin.cancel(id: id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}