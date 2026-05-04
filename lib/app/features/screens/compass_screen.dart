import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:qibla_compass_app/app/core/app_theme.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _needleAnimation;
  // Qibla bearing: 119 degrees SE (as shown in design)
  final double _qiblaBearing = 119.0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _needleAnimation = Tween<double>(
      begin: 0,
      end: (_qiblaBearing * math.pi) / 180,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.elasticOut,
    ));
    _rotationController.forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            AppBarWidget(
              title: 'Al-Qibla',
              isDark: true,
            ),
            Expanded(
              child: SingleChildScrollView(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBearingLabel() {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: '119°',
                style: TextStyle(
                  color: AppTheme.goldAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: ' SE',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
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
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldAccent.withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.goldAccent.withOpacity(0.3),
                width: 2,
              ),
              gradient: RadialGradient(
                colors: [
                  Colors.white,
                  const Color(0xFFF0EDE8),
                ],
              ),
            ),
          ),
          // Tick marks
          CustomPaint(
            size: const Size(260, 260),
            painter: _CompassTickPainter(),
          ),
          // Center dot
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.darkBg,
            ),
          ),
          // North needle (gray)
          AnimatedBuilder(
            animation: _needleAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _needleAnimation.value,
                child: CustomPaint(
                  size: const Size(260, 260),
                  painter: _NorthNeedlePainter(),
                ),
              );
            },
          ),
          // Qibla needle (gold)
          AnimatedBuilder(
            animation: _needleAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _needleAnimation.value,
                child: CustomPaint(
                  size: const Size(260, 260),
                  painter: _QiblaNeedlePainter(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlignmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.goldAccent,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Perfect Alignment',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'You are currently facing the Kaaba',
                style: TextStyle(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CURRENT PRAYER',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
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
              const Text(
                '12:15 PM',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
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
            value: '4,782 km',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            icon: Icons.wb_sunny_outlined,
            label: 'Solar Noon',
            value: '12:12 PM',
          ),
        ),
      ],
    );
  }
}

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
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassTickPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 72; i++) {
      final angle = (i * 5) * math.pi / 180;
      final isMajor = i % 9 == 0;
      final tickLength = isMajor ? 12.0 : 6.0;

      final start = Offset(
        center.dx + (radius - 10) * math.cos(angle),
        center.dy + (radius - 10) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius - 10 - tickLength) * math.cos(angle),
        center.dy + (radius - 10 - tickLength) * math.sin(angle),
      );

      canvas.drawLine(start, end, paint..strokeWidth = isMajor ? 1.5 : 0.8);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NorthNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Points opposite direction (north when not rotated = up)
    canvas.drawLine(
      center,
      Offset(center.dx - radius * math.sin(0), center.dy - radius * math.cos(0)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QiblaNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Gold gradient needle
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppTheme.goldAccent.withOpacity(0.5),
          AppTheme.goldAccent,
          AppTheme.goldAccent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Qibla direction needle (pointing in bearing direction)
    canvas.drawLine(
      center,
      Offset(center.dx + radius * math.sin(0), center.dy + radius * math.cos(0)),
      paint,
    );

    // Tip circle
    final tipOffset = Offset(
      center.dx + radius * math.sin(0),
      center.dy + radius * math.cos(0),
    );
    canvas.drawCircle(tipOffset, 6, Paint()..color = AppTheme.goldAccent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}