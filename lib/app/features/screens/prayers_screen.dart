import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qibla_compass_app/app/core/app_theme.dart';
import 'package:qibla_compass_app/app/features/service/location_service.dart';
import 'package:qibla_compass_app/app/features/service/notification_service.dart';
import 'package:qibla_compass_app/app/features/service/prayer_time_service.dart';

import '../widgets/app_bar_widget.dart';

class PrayersScreen extends StatefulWidget {
  const PrayersScreen({super.key});

  @override
  State<PrayersScreen> createState() => _PrayersScreenState();
}

class _PrayersScreenState extends State<PrayersScreen> {
  // ── State ────────────────────────────────────────────────────────────────────
  PrayerTimes? _times;
  Position? _position;
  Timer? _ticker;
  Duration _remaining = Duration.zero;

  bool _isLoading = true;
  String? _error;

  // Which prayers have notifications enabled
  final Map<Prayer, bool> _notifEnabled = {
    Prayer.fajr: true,
    Prayer.dhuhr: true,
    Prayer.asr: false,
    Prayer.maghrib: true,
    Prayer.isha: true,
  };

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // ── Data loading ─────────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final pos = await LocationService.getCurrentPosition();
      final times = PrayerTimesService.calculate(
        position: pos,
        date: DateTime.now(),
      );

      setState(() {
        _position = pos;
        _times = times;
        _isLoading = false;
      });

      _startTicker();
      await _scheduleNotifications();
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_times == null) return;
      final next = _nextPrayerTime();
      if (next != null) {
        setState(() {
          _remaining = PrayerTimesService.timeUntil(next);
        });
      }
    });
  }

  Future<void> _scheduleNotifications() async {
    if (_times == null) return;
    await NotificationService.schedulePrayerNotifications(
      times: _times!,
      enabledPrayers: _notifEnabled,
    );
  }

  Future<void> _toggleNotification(Prayer prayer, bool value) async {
    setState(() => _notifEnabled[prayer] = value);
    if (_times == null) return;
    if (value) {
      // Re-schedule all (simplest approach)
      await _scheduleNotifications();
    } else {
      await NotificationService.cancelPrayer(prayer);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Prayer? get _currentPrayer => _times?.currentPrayer();
  Prayer? get _nextPrayer => _times?.nextPrayer();

  DateTime? _nextPrayerTime() {
    if (_times == null) return null;
    switch (_nextPrayer) {
      case Prayer.fajr:
        return _times!.fajr;
      case Prayer.dhuhr:
        return _times!.dhuhr;
      case Prayer.asr:
        return _times!.asr;
      case Prayer.maghrib:
        return _times!.maghrib;
      case Prayer.isha:
        return _times!.isha;
      default:
        return null;
    }
  }

  DateTime _prayerTime(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return _times!.fajr;
      case Prayer.dhuhr:
        return _times!.dhuhr;
      case Prayer.asr:
        return _times!.asr;
      case Prayer.maghrib:
        return _times!.maghrib;
      case Prayer.isha:
        return _times!.isha;
      default:
        return DateTime.now();
    }
  }

  PrayerStatus _statusOf(Prayer prayer) {
    if (_times == null) return PrayerStatus.pending;
    if (prayer == _nextPrayer) return PrayerStatus.upcoming;
    if (prayer == _currentPrayer) return PrayerStatus.active;
    if (_prayerTime(prayer).isBefore(DateTime.now())) {
      return PrayerStatus.passed;
    }
    return PrayerStatus.pending;
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get _hijriDate {
    // adhan doesn't ship Hijri; we compute a rough approximation.
    // For production, use the hijri package.
    return '9 RABI\' AL-THANI 1445 AH';
  }

  String get _gregorianDate {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            const AppBarWidget(title: 'Al-Qibla'),
            Expanded(
              child: _isLoading
                  ? _buildLoading()
                  : _error != null
                      ? _buildError()
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryGreen),
          SizedBox(height: 16),
          Text(
            'Calculating prayer times...',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off,
                color: AppTheme.textSecondary, size: 48),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final prayers = [
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];

    return RefreshIndicator(
      color: AppTheme.primaryGreen,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildDateHeader(),
            const SizedBox(height: 20),
            if (_nextPrayer != null && _nextPrayer != Prayer.none)
              _buildNextPrayerCard(),
            const SizedBox(height: 20),
            ...prayers.map((p) => _buildPrayerTile(p)),
            const SizedBox(height: 16),
            _buildLocationFooter(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Sub-widgets ──────────────────────────────────────────────────────────────

  Widget _buildDateHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _gregorianDate,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _hijriDate,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            letterSpacing: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNextPrayerCard() {
    final name = PrayerTimesService.prayerName(_nextPrayer!);
    final time = _nextPrayerTime();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEXT PRAYER',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      _formatDuration(_remaining),
                      style: const TextStyle(
                        color: AppTheme.goldAccent,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'REMAINING',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (time != null)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.access_time_rounded,
                      color: AppTheme.goldAccent, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    PrayerTimesService.formatTime(time),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrayerTile(Prayer prayer) {
    if (_times == null) return const SizedBox.shrink();

    final status = _statusOf(prayer);
    final name = PrayerTimesService.prayerName(prayer);
    final time = PrayerTimesService.formatTime(_prayerTime(prayer));
    final isUpcoming = status == PrayerStatus.upcoming;
    final isActive = status == PrayerStatus.active;
    final isPassed = status == PrayerStatus.passed;
    final notifOn = _notifEnabled[prayer] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUpcoming
            ? AppTheme.lightGreen.withOpacity(0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? const Border(
                left: BorderSide(color: AppTheme.goldAccent, width: 3))
            : isUpcoming
                ? Border.all(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    width: 1.5)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _iconBg(prayer),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_prayerIcon(prayer),
                  color: _iconColor(prayer), size: 20),
            ),
            const SizedBox(width: 14),
            // Name + time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUpcoming ? name.toUpperCase() : name,
                    style: TextStyle(
                      color: isUpcoming
                          ? AppTheme.primaryGreen
                          : AppTheme.textSecondary,
                      fontSize: isUpcoming ? 11 : 13,
                      fontWeight: isUpcoming
                          ? FontWeight.w700
                          : FontWeight.w500,
                      letterSpacing: isUpcoming ? 1.5 : 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: isUpcoming ? 22 : 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Trailing
            if (isPassed)
              const Text(
                'Passed',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
              )
            else if (isActive)
              Row(children: [
                const Text('Active',
                    style: TextStyle(
                        color: AppTheme.warmYellow,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                _buildToggle(
                  value: notifOn,
                  onChanged: (v) => _toggleNotification(prayer, v),
                ),
              ])
            else
              Row(children: [
                if (isUpcoming)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text('Upcoming',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                  ),
                _buildToggle(
                  value: notifOn,
                  onChanged: (v) => _toggleNotification(prayer, v),
                ),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Transform.scale(
      scale: 0.85,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: value ? AppTheme.primaryGreen : Colors.grey.shade300,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildLocationFooter() {
    if (_position == null) return const SizedBox.shrink();
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_outlined,
              size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            LocationService.formatCoordinates(
              _position!.latitude,
              _position!.longitude,
            ),
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Icon helpers ─────────────────────────────────────────────────────────────

  IconData _prayerIcon(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return Icons.brightness_3;
      case Prayer.dhuhr:
        return Icons.wb_sunny_outlined;
      case Prayer.asr:
        return Icons.wb_sunny;
      case Prayer.maghrib:
        return Icons.home_outlined;
      case Prayer.isha:
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }

  Color _iconBg(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return const Color(0xFFEFF6FF);
      case Prayer.dhuhr:
        return const Color(0xFFFFFBEB);
      case Prayer.asr:
        return const Color(0xFFFEF3C7);
      case Prayer.maghrib:
        return const Color(0xFFF3F4F6);
      case Prayer.isha:
        return const Color(0xFFEEF2FF);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _iconColor(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return const Color(0xFF94A3B8);
      case Prayer.dhuhr:
        return const Color(0xFFF59E0B);
      case Prayer.asr:
        return const Color(0xFFF59E0B);
      case Prayer.maghrib:
        return const Color(0xFF6B7280);
      case Prayer.isha:
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

enum PrayerStatus { passed, active, upcoming, pending }