import 'package:flutter/material.dart';

import '../theme/sari_theme.dart';

void showComingSoonSnackBar(
  BuildContext context, {
  String message = 'Yakında',
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    return;
  }
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),
      backgroundColor: colorScheme.inverseSurface,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(SariSpacing.md),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SariRadius.button),
      ),
      duration: const Duration(milliseconds: 1800),
    ),
  );
}
