import 'package:flutter/material.dart';
import 'package:qibla_compass_app/app/core/app_theme.dart';
import 'package:qibla_compass_app/app/features/service/notification_service.dart';
import 'package:qibla_compass_app/app/features/service/prayer_time_service.dart';
import 'package:qibla_compass_app/app/features/service/settings_service.dart';
import 'package:qibla_compass_app/app/features/widgets/app_bar_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ── State (loaded from SettingsService) ────────────────────────────────────
  late bool _prayerAlerts;
  late bool _vibrateOnQibla;
  late String _selectedMethod;
  late String _selectedAsr;
  late Map<String, bool> _prayerNotifs;

  static const _asrMethods = ['Standard', 'Hanafi'];

  @override
  void initState() {
    super.initState();
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    _prayerAlerts = SettingsService.prayerAlerts;
    _vibrateOnQibla = SettingsService.vibrateOnQibla;
    _selectedMethod = SettingsService.prayerMethod;
    _selectedAsr = SettingsService.asrMethod;
    _prayerNotifs = Map.from(SettingsService.allPrayerNotifs);
  }

  // ── Handlers ─────────────────────────────────────────────────────────────────

  Future<void> _onPrayerAlertsChanged(bool value) async {
    setState(() => _prayerAlerts = value);
    await SettingsService.setPrayerAlerts(value);
    if (!value) {
      await NotificationService.cancelAll();
    }
  }

  Future<void> _onVibrateChanged(bool value) async {
    setState(() => _vibrateOnQibla = value);
    await SettingsService.setVibrateOnQibla(value);
  }

  Future<void> _onMethodChanged(String? value) async {
    if (value == null) return;
    setState(() => _selectedMethod = value);
    await SettingsService.setPrayerMethod(value);
    _showRestartSnack('Calculation method updated. Pull to refresh Prayer Times.');
  }

  Future<void> _onAsrChanged(String? value) async {
    if (value == null) return;
    setState(() => _selectedAsr = value);
    await SettingsService.setAsrMethod(value);
    _showRestartSnack('Asr method updated. Pull to refresh Prayer Times.');
  }

  Future<void> _onPrayerNotifChanged(String prayer, bool value) async {
    setState(() => _prayerNotifs[prayer] = value);
    await SettingsService.setPrayerNotif(prayer, value);
    if (!value) {
      // cancel specific prayer
      final prayerEnum = _nameToEnum(prayer);
      if (prayerEnum != null) {
        await NotificationService.cancelPrayer(prayerEnum);
      }
    }
  }

  void _showRestartSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  dynamic _nameToEnum(String name) {
    // Using adhan Prayer enum indirectly through NotificationService
    // This avoids importing adhan here
    switch (name) {
      case 'Fajr':
        return _PrayerRef.fajr;
      case 'Dhuhr':
        return _PrayerRef.dhuhr;
      case 'Asr':
        return _PrayerRef.asr;
      case 'Maghrib':
        return _PrayerRef.maghrib;
      case 'Isha':
        return _PrayerRef.isha;
      default:
        return null;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

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
                    _buildSectionTitle('Calculation Methods'),
                    const SizedBox(height: 12),
                    _buildCalculationCard(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('Notifications'),
                    const SizedBox(height: 12),
                    _buildNotificationsCard(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('Compass'),
                    const SizedBox(height: 12),
                    _buildCompassCard(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('About'),
                    const SizedBox(height: 12),
                    _buildAboutCard(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppTheme.textPrimary,
      ),
    );
  }

  // ── Calculation Card ──────────────────────────────────────────────────────────

  Widget _buildCalculationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDropdownRow(
            icon: Icons.grid_view_outlined,
            title: 'Prayer Method',
            subtitle: 'Calculation authority',
            value: _selectedMethod,
            items: PrayerTimesService.supportedMethods,
            onChanged: _onMethodChanged,
            showDivider: true,
          ),
          _buildDropdownRow(
            icon: Icons.do_not_disturb_alt_outlined,
            title: 'Asr Jurisprudence',
            subtitle: _selectedAsr == 'Hanafi'
                ? 'Hanafi (later shadow ratio)'
                : 'Standard (Shafi, Maliki, Hanbali)',
            value: _selectedAsr,
            items: _asrMethods,
            onChanged: _onAsrChanged,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.tealAccent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    color: AppTheme.primaryGreen, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        )),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        )),
                  ],
                ),
              ),
              DropdownButton<String>(
                value: value,
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppTheme.textSecondary, size: 20),
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                items: items
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m,
                              style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
              height: 1, indent: 68, color: AppTheme.dividerColor),
      ],
    );
  }

  // ── Notifications Card ────────────────────────────────────────────────────────

  Widget _buildNotificationsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Master toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.tealAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: AppTheme.primaryGreen, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Prayer Alerts',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          )),
                      Text('Enable notifications for all prayers',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          )),
                    ],
                  ),
                ),
                _buildSwitch(
                  value: _prayerAlerts,
                  onChanged: _onPrayerAlertsChanged,
                ),
              ],
            ),
          ),

          // Per-prayer toggles
          if (_prayerAlerts) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: _prayerNotifs.entries.map((entry) {
                    return _buildPrayerNotifRow(
                      entry.key,
                      entry.value,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],

          const Divider(height: 1, indent: 16, endIndent: 16,
              color: AppTheme.dividerColor),

          // Vibrate toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.tealAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.vibration,
                      color: AppTheme.primaryGreen, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vibrate on Qibla',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          )),
                      Text('Haptic feedback when aligned',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          )),
                    ],
                  ),
                ),
                _buildSwitch(
                  value: _vibrateOnQibla,
                  onChanged: _onVibrateChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerNotifRow(String name, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(_prayerIcon(name),
                  size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  )),
            ],
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: (v) => _onPrayerNotifChanged(name, v),
              activeColor: Colors.white,
              activeTrackColor: AppTheme.primaryGreen,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  IconData _prayerIcon(String name) {
    switch (name) {
      case 'Fajr':
        return Icons.brightness_3;
      case 'Dhuhr':
        return Icons.wb_sunny_outlined;
      case 'Asr':
        return Icons.wb_sunny;
      case 'Maghrib':
        return Icons.home_outlined;
      case 'Isha':
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }

  // ── Compass Card ──────────────────────────────────────────────────────────────

  Widget _buildCompassCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.tealAccent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.vibration,
                  color: AppTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vibrate on Qibla',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      )),
                  Text('Haptic pulse when facing Makkah',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      )),
                ],
              ),
            ),
            _buildSwitch(
              value: _vibrateOnQibla,
              onChanged: _onVibrateChanged,
            ),
          ],
        ),
      ),
    );
  }

  // ── About Card ────────────────────────────────────────────────────────────────

  Widget _buildAboutCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow('App Version', '1.0.0', Icons.info_outline),
          const Divider(height: 1, indent: 68, color: AppTheme.dividerColor),
          _buildInfoRow(
              'Qibla Calculation', 'Spherical Trigonometry',
              Icons.explore_outlined),
          const Divider(height: 1, indent: 68, color: AppTheme.dividerColor),
          _buildInfoRow('Mosque Data', 'OpenStreetMap (Overpass)',
              Icons.mosque_outlined),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.tealAccent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child:
                Icon(icon, color: AppTheme.primaryGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                )),
          ),
          Text(value,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              )),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  Widget _buildSwitch({
    required bool value,
    required Future<void> Function(bool) onChanged,
  }) {
    return Transform.scale(
      scale: 0.85,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: AppTheme.primaryGreen,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey.shade300,
      ),
    );
  }
}

// Internal enum proxy to avoid importing adhan here
enum _PrayerRef { fajr, dhuhr, asr, maghrib, isha }