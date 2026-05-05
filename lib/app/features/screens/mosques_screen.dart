import 'package:flutter/material.dart';
import 'package:qibla_compass_app/app/core/app_theme.dart';
import 'package:qibla_compass_app/app/features/widgets/app_bar_widget.dart';

class MosquesScreen extends StatelessWidget {
  const MosquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            const AppBarWidget(title: 'Al-Qibla'),
            Expanded(
              child: Stack(
                children: [
                  _buildMapBackground(),
                  _buildSearchBar(),
                  _buildMosqueMarker(),
                  _buildBottomCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _MapGridPainter(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 16,
      left: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(
                Icons.search,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search nearby mosques...',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.tune,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMosqueMarker() {
    return const Positioned(
      top: 160,
      left: 0,
      right: 0,
      child: Center(
        child: _MosqueMarker(),
      ),
    );
  }

  Widget _buildBottomCard() {
    return Positioned(
      bottom: 16,
      left: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sultan Ahmed Mosque',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'OPEN',
                          style: TextStyle(
                            color: Color(0xFF856404),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Binbirdirek, At Meydanı Cd\nNo:10, Istanbul',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppTheme.dividerColor),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.near_me_outlined,
                          label: 'Distance',
                          value: '0.4 km',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.directions_walk,
                          label: 'Walking',
                          value: '6 mins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.navigation_outlined, size: 18),
                  label: const Text(
                    'Navigate',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MosqueMarker extends StatelessWidget {
  const _MosqueMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.mosque,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppTheme.textSecondary),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()
      ..color = const Color(0xFFCDD8D0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Grid lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 0.8;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    // Diagonal road-like shapes
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.5),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.4, 0),
      Offset(size.width * 0.6, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, 0),
      Offset(size.width * 0.3, size.height * 0.6),
      roadPaint..strokeWidth = 10,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}