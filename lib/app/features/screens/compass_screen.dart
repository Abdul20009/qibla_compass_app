import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qibla_compass_app/app/core/app_theme.dart';
import 'package:qibla_compass_app/app/features/service/location_service.dart';
import 'package:qibla_compass_app/app/features/service/qibla_service.dart';

import '../widgets/app_bar_widget.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  StreamSubscription<CompassEvent>? _compassSub;

  double _deviceHeading = 0;
  double _qiblaBearing = 0;
  double _distanceKm = 0;

  bool _isLoadingLocation = true;
  String? _locationError;

  static const double _alignThreshold = 5.0;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _startCompass();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  // ── Location ─────────────────────────────────────────────────────────────────

  Future<void> _initLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });
    try {
      final pos = await LocationService.getCurrentPosition();
      final bearing = QiblaService.calculateQiblaBearing(
        pos.latitude,
        pos.longitude,
      );
      final distance = QiblaService.distanceToKaaba(
        pos.latitude,
        pos.longitude,
      );
      setState(() {
        _qiblaBearing = bearing;
        _distanceKm = distance;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingLocation = false;
      });
    }
  }

  // ── Compass sensor ────────────────────────────────────────────────────────────

  void _startCompass() {
    _compassSub = FlutterCompass.events?.listen((CompassEvent event) {
      if (event.heading == null) return;
      if (mounted) setState(() => _deviceHeading = event.heading!);
    });
  }

  // ── Derived ───────────────────────────────────────────────────────────────────

  double get _qiblaNeedleAngle =>
      _degToRad(_qiblaBearing - _deviceHeading);

  bool get _isAligned {
    final diff = (_qiblaBearing - _deviceHeading + 360) % 360;
    return diff <= _alignThreshold || diff >= (360 - _alignThreshold);
  }

  String get _bearingLabel =>
      '${_qiblaBearing.toStringAsFixed(0)}° '
      '${QiblaService.bearingToCardinal(_qiblaBearing)}';

  static double _degToRad(double deg) => deg * math.pi / 180;

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            const AppBarWidget(title: 'Al-Qibla', isDark: true),
            Expanded(
              child: _isLoadingLocation
                  ? _buildLoading()
                  : _locationError != null
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
          CircularProgressIndicator(color: AppTheme.goldAccent),
          SizedBox(height: 16),
          Text(
            'Getting your location...',
            style: TextStyle(color: Colors.white54, fontSize: 14),
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
            const Icon(Icons.location_off, color: Colors.white38, size: 48),
            const SizedBox(height: 16),
            Text(
              _locationError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initLocation,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildBearingLabel(),
          const SizedBox(height: 24),
          _buildCompassDial(),
          const SizedBox(height: 28),
          _buildAlignmentCard(),
          const SizedBox(height: 12),
          _buildCurrentPrayerCard(),
          const SizedBox(height: 12),
          _buildInfoRow(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBearingLabel() {
    return Column(
      children: [
        Text(
          _bearingLabel,
          style: const TextStyle(
            color: AppTheme.goldAccent,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'BEARING TO MAKKAH',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 11,
            letterSpacing: 2.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCompassDial() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow ring
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _isAligned
                      ? AppTheme.goldAccent.withOpacity(0.4)
                      : AppTheme.goldAccent.withOpacity(0.12),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Dial — rotates so the world stays fixed, device rotates under it
          Transform.rotate(
            angle: _degToRad(-_deviceHeading),
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.goldAccent.withOpacity(0.3),
                  width: 2,
                ),
                gradient: const RadialGradient(
                  colors: [Colors.white, Color(0xFFF0EDE8)],
                ),
              ),
              child: CustomPaint(painter: _CompassTickPainter()),
            ),
          ),
          // North needle (fixed red, always points up = north on screen)
          CustomPaint(
            size: const Size(260, 260),
            painter: _NorthNeedlePainter(),
          ),
          // Qibla needle (gold, rotates to Kaaba direction)
          Transform.rotate(
            angle: _qiblaNeedleAngle,
            child: CustomPaint(
              size: const Size(260, 260),
              painter: _QiblaNeedlePainter(isAligned: _isAligned),
            ),
          ),
          // Center dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.darkBg,
              border: Border.all(color: AppTheme.goldAccent, width: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlignmentCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: _isAligned
            ? Border.all(color: AppTheme.goldAccent, width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isAligned ? AppTheme.goldAccent : Colors.grey.shade300,
            ),
            child: Icon(
              _isAligned ? Icons.check : Icons.explore,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isAligned ? 'Perfect Alignment' : 'Finding Qibla...',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _isAligned
                    ? 'You are currently facing the Kaaba'
                    : 'Rotate your device to face Makkah',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPrayerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: AppTheme.goldAccent, width: 3),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CURRENT PRAYER',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Dhuhr',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '12:15 PM',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Ends in 2h 45m',
                style: TextStyle(
                  color: AppTheme.warmYellow,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: Icons.straighten,
            label: 'Distance',
            value: _distanceKm > 0
                ? '${_distanceKm.toStringAsFixed(0)} km'
                : '—',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            icon: Icons.explore_outlined,
            label: 'Heading',
            value: '${_deviceHeading.toStringAsFixed(0)}°',
          ),
        ),
      ],
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class _CompassTickPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 72; i++) {
      final angle = (i * 5 - 90) * math.pi / 180;
      final isCardinal = i % 18 == 0;
      final isMajor = i % 9 == 0;
      final tickLen = isCardinal ? 14.0 : isMajor ? 10.0 : 5.0;

      final paint = Paint()
        ..color = isCardinal ? Colors.grey.shade600 : Colors.grey.withOpacity(0.35)
        ..strokeWidth = isCardinal ? 2.0 : 0.8
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(center.dx + (radius - 8) * math.cos(angle),
            center.dy + (radius - 8) * math.sin(angle)),
        Offset(center.dx + (radius - 8 - tickLen) * math.cos(angle),
            center.dy + (radius - 8 - tickLen) * math.sin(angle)),
        paint,
      );

      if (isCardinal) {
        final labels = ['N', 'E', 'S', 'W'];
        final label = labels[(i ~/ 18) % 4];
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: label == 'N' ? Colors.red.shade400 : Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final lx = center.dx + (radius - 34) * math.cos(angle);
        final ly = center.dy + (radius - 34) * math.sin(angle);
        tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _NorthNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - size.height / 2 + 28),
      Paint()
        ..color = Colors.red.shade400
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _QiblaNeedlePainter extends CustomPainter {
  final bool isAligned;
  const _QiblaNeedlePainter({required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final tip = Offset(center.dx, center.dy - size.height / 2 + 28);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          AppTheme.goldAccent.withOpacity(0.3),
          AppTheme.goldAccent,
        ],
      ).createShader(Rect.fromPoints(center, tip))
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, tip, paint);
    canvas.drawCircle(tip, 7, Paint()..color = AppTheme.goldAccent);

    if (isAligned) {
      canvas.drawCircle(
        tip,
        13,
        Paint()
          ..color = AppTheme.goldAccent.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QiblaNeedlePainter old) =>
      old.isAligned != isAligned;
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}