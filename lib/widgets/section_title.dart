import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;

  const SectionTitle({
    super.key,
    required this.title,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark
        ? Colors.white
        : AppTheme.navy;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),

        if (actionText != null)
          TextButton(
            onPressed: () {},
            child: Text(
              actionText!,
              style: TextStyle(
                color: isDark
                    ? AppTheme.orange
                    : AppTheme.navy,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}