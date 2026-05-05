import 'package:flutter/material.dart';
import 'package:qibla_compass_app/app/core/app_theme.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isDark;

  const AppBarWidget({
    super.key,
    required this.title,
    this.isDark = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final Color bg = isDark ? AppTheme.darkBg : Colors.white;
    final Color iconColor = isDark ? Colors.white : AppTheme.primaryGreen;
    final Color titleColor = isDark ? Colors.white : AppTheme.primaryGreen;

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Hamburger menu
          GestureDetector(
            onTap: () {},
            child: Icon(Icons.menu, color: iconColor, size: 24),
          ),

          // App title
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),

          // Location pin
          GestureDetector(
            onTap: () {},
            child: Icon(Icons.location_on_outlined, color: iconColor, size: 24),
          ),
        ],
      ),
    );
  }
}