import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? const Color(0xFF1E293B)
        : Colors.white;

    final iconColor = isDark
        ? AppTheme.orange
        : AppTheme.navy;

    final iconBackground = isDark
        ? AppTheme.orange.withOpacity(0.12)
        : AppTheme.navy.withOpacity(0.1);

    final textColor = isDark
        ? Colors.white
        : Colors.black87;

    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),

      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: iconColor,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}