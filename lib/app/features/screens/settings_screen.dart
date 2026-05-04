import 'package:flutter/material.dart';
import 'package:qibla_compass_app/app/core/app_theme.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _prayerAlerts = true;
  bool _vibrateOnQibla = true;

  final Map<String, bool> _prayerNotifs = {
    'Fajr': true,
    'Dhuhr': true,
    'Asr': false,
    'Maghrib': true,
  };

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
                    _buildSectionTitle('Location'),
                    const SizedBox(height: 12),
                    _buildLocationCard(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('Calculation Methods'),
                    const SizedBox(height: 12),
                    _buildCalculationCard(),
                    const SizedBox(height: 28),
                    _buildSectionTitle('Notifications'),
                    const SizedBox(height: 12),
                    _buildNotificationsCard(),
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

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location label
          const Text(
            'CURRENT LOCATION',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mecca, Saudi Arabia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.goldAccent,
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Map preview placeholder
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A4A3A),
                  Color(0xFF2D7A5E),
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 100),
                  painter: _MiniMapPainter(),
                ),
                const Icon(
                  Icons.location_on,
                  color: AppTheme.goldAccent,
                  size: 40,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // GPS Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.my_location, size: 18),
              label: const Text(
                'Use GPS',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Manual Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text(
                'Set Manually',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryGreen,
                side: const BorderSide(color: AppTheme.primaryGreen),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          _SettingsRow(
            icon: Icons.grid_view_outlined,
            title: 'Prayer Method',
            subtitle: 'Umm al-Qura University, Makkah',
            showDivider: true,
          ),
          _SettingsRow(
            icon: Icons.do_not_disturb_alt_outlined,
            title: 'Asr Jurisprudence',
            subtitle: 'Standard (Shafi, Maliki, Hanbali)',
            showDivider: true,
          ),
          _SettingsRow(
            icon: Icons.swap_vert,
            title: 'High Latitude Adjustment',
            subtitle: 'Angle Based',
            showDivider: false,
          ),
        ],
      ),
    );
  }

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
          // Prayer alerts row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.tealAccent.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: AppTheme.primaryGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prayer Alerts',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Enable notifications for all prayers',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: _prayerAlerts,
                        onChanged: (v) => setState(() => _prayerAlerts = v),
                        activeColor: Colors.white,
                        activeTrackColor: AppTheme.primaryGreen,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Individual prayer toggles
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 3.5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: _prayerNotifs.entries.map((entry) {
                      return _PrayerToggleChip(
                        name: entry.key,
                        value: entry.value,
                        onChanged: (v) =>
                            setState(() => _prayerNotifs[entry.key] = v),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          // Vibrate on Qibla
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
                  child: const Icon(
                    Icons.vibration,
                    color: AppTheme.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vibrate on Qibla',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Haptic feedback when aligned',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: _vibrateOnQibla,
                    onChanged: (v) => setState(() => _vibrateOnQibla = v),
                    activeColor: Colors.white,
                    activeTrackColor: AppTheme.primaryGreen,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showDivider;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
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
                child: Icon(icon, color: AppTheme.primaryGreen, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 68, color: AppTheme.dividerColor),
      ],
    );
  }
}

class _PrayerToggleChip extends StatelessWidget {
  final String name;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrayerToggleChip({
    required this.name,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          Icon(
            Icons.volume_up_outlined,
            size: 18,
            color: value ? AppTheme.primaryGreen : AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}