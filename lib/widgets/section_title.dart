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
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.navy,
            ),
          ),
        ),

        if (actionText != null)
          TextButton(
            onPressed: () {},
            child: Text(
              actionText!,
              style: const TextStyle(
                color: AppTheme.navy,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}