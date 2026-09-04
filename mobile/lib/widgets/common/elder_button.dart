import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

enum ElderButtonVariant {
  primary,   // Deep Forest Teal
  secondary, // Outlined Forest Teal
  sage,      // Calm Sage Green
  peach,     // Soft Warm Peach Accent
}

/// Elder-accessible button with guaranteed 56dp+ touch height,
/// clear icon-plus-text styling, and high-contrast typography.
class ElderButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ElderButtonVariant variant;
  final double height;
  final bool isFullWidth;
  final String? subtitle;

  const ElderButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.variant = ElderButtonVariant.primary,
    this.height = 60.0,
    this.isFullWidth = true,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border;

    switch (variant) {
      case ElderButtonVariant.primary:
        bg = AppColors.forestPrimary;
        fg = Colors.white;
        border = BorderSide.none;
        break;
      case ElderButtonVariant.secondary:
        bg = AppColors.backgroundWarm;
        fg = AppColors.forestPrimary;
        border = const BorderSide(color: AppColors.forestPrimary, width: 2.2);
        break;
      case ElderButtonVariant.sage:
        bg = AppColors.sage;
        fg = Colors.white;
        border = BorderSide.none;
        break;
      case ElderButtonVariant.peach:
        bg = AppColors.peach;
        fg = Colors.white;
        border = BorderSide.none;
        break;
    }

    final buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 28, color: fg),
          const SizedBox(width: 14),
        ],
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTypography.patientButton.copyWith(color: fg),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 14,
                    color: fg.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: height,
        minWidth: isFullWidth ? double.infinity : 0,
      ),
      child: Material(
        color: onPressed == null ? AppColors.borderSoft : bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: border,
        ),
        elevation: variant == ElderButtonVariant.primary ? 1.5 : 0,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          splashColor: fg.withValues(alpha: 0.12),
          highlightColor: fg.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: buttonContent,
          ),
        ),
      ),
    );
  }
}
