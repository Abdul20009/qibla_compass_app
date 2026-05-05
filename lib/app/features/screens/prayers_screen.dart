import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qibla_compass_app/app/core/app_theme.dart';
import 'package:qibla_compass_app/app/features/widgets/app_bar_widget.dart';

class PrayersScreen extends StatefulWidget {
  const PrayersScreen({super.key});

  @override
  State<PrayersScreen> createState() => _PrayersScreenState();
}

class _PrayersScreenState extends State<PrayersScreen> {
  late Timer _timer;
  Duration _remaining = const Duration(hours: 1, minutes: 24, seconds: 15);

  final List<_PrayerData> _prayers = [
    _PrayerData(
      name: 'Fajr',
      time: '05:12',
      status: PrayerStatus.passed,
      icon: Icons.brightness_3,
      iconColor: Color(0xFF94A3B8),
      bgColor: Color(0xFFEFF6FF),
      notifEnabled: false,
    ),
    _PrayerData(
      name: 'Dhuhr',
      time: '12:34',
      status: PrayerStatus.active,
      icon: Icons.wb_sunny_outlined,
      iconColor: Color(0xFFF59E0B),
      bgColor: Color(0xFFFFFBEB),
      notifEnabled: true,
    ),
    _PrayerData(
      name: 'Asr',
      time: '15:42',
      status: PrayerStatus.upcoming,
      icon: Icons.wb_sunny,
      iconColor: Color(0xFFF59E0B),
      bgColor: Color(0xFFFEF3C7),
      notifEnabled: true,
    ),
    _PrayerData(
      name: 'Maghrib',
      time: '18:15',
      status: PrayerStatus.pending,
      icon: Icons.home_outlined,
      iconColor: Color(0xFF6B7280),
      bgColor: Color(0xFFF3F4F6),
      notifEnabled: false,
    ),
    _PrayerData(
      name: 'Isha',
      time: '19:38',
      status: PrayerStatus.pending,
      icon: Icons.nightlight_round,
      iconColor: Color(0xFF6366F1),
      bgColor: Color(0xFFEEF2FF),
      notifEnabled: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds > 0) {
        setState(() {
          _remaining = _remaining - const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            const AppBarWidget(title: 'Al-Qibla'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildDateHeader(),
                    const SizedBox(height: 20),
                    _buildNextPrayerCard(),
                    const SizedBox(height: 20),
                    ..._prayers.map((p) => _buildPrayerTile(p)),
                    const SizedBox(height: 16),
                    _buildLocationFooter(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tuesday, Oct 24',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '9 RABI\' AL-THANI 1445 AH',
          style: TextStyle(
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
                const Text(
                  'Asr',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      _formatTime(_remaining),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: AppTheme.goldAccent,
                  size: 22,
                ),
                const SizedBox(height: 4),
                const Text(
                  '15:42',
                  style: TextStyle(
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

  Widget _buildPrayerTile(_PrayerData prayer) {
    final isUpcoming = prayer.status == PrayerStatus.upcoming;
    final isActive = prayer.status == PrayerStatus.active;

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
                    color: AppTheme.primaryGreen.withOpacity(0.2), width: 1.5)
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
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: prayer.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(prayer.icon, color: prayer.iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUpcoming ? prayer.name.toUpperCase() : prayer.name,
                    style: TextStyle(
                      color: isUpcoming
                          ? AppTheme.primaryGreen
                          : AppTheme.textSecondary,
                      fontSize: isUpcoming ? 11 : 13,
                      fontWeight: isUpcoming ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: isUpcoming ? 1.5 : 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    prayer.time,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: isUpcoming ? 22 : 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (prayer.status == PrayerStatus.passed)
              const Text(
                'Passed',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              )
            else if (prayer.status == PrayerStatus.active)
              Row(
                children: [
                  const Text(
                    'Active',
                    style: TextStyle(
                      color: AppTheme.warmYellow,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildToggle(true),
                ],
              )
            else if (prayer.status == PrayerStatus.upcoming)
              Row(
                children: [
                  const Text(
                    'Upcoming',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildToggle(prayer.notifEnabled),
                ],
              )
            else
              _buildToggle(prayer.notifEnabled),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(bool value) {
    return Transform.scale(
      scale: 0.85,
      child: Switch(
        value: value,
        onChanged: (_) {},
        activeColor: Colors.white,
        activeTrackColor: value ? AppTheme.goldAccent : Colors.grey.shade300,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildLocationFooter() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 14,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 4),
          const Text(
            'Mecca, Saudi Arabia (Umm al-Qura)',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

enum PrayerStatus { passed, active, upcoming, pending }

class _PrayerData {
  final String name;
  final String time;
  final PrayerStatus status;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final bool notifEnabled;

  const _PrayerData({
    required this.name,
    required this.time,
    required this.status,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.notifEnabled,
  });
}