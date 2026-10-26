// lib/widgets/custom_button.dart

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;
  final bool expanded;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final callback = isLoading ? null : onPressed;

    final Widget content;
    if (isLoading) {
      final spinnerColor = variant == AppButtonVariant.secondary ||
              variant == AppButtonVariant.ghost
          ? AppTheme.primary
          : Colors.white;
      content = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          color: spinnerColor,
        ),
      );
    } else if (icon != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      );
    } else {
      content = Text(label);
    }

    final Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = FilledButton(onPressed: callback, child: content);
      case AppButtonVariant.secondary:
        button = OutlinedButton(onPressed: callback, child: content);
      case AppButtonVariant.ghost:
        button = TextButton(onPressed: callback, child: content);
      case AppButtonVariant.danger:
        button = FilledButton(
          onPressed: callback,
          style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
          child: content,
        );
    }

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
