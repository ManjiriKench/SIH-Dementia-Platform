import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Warm, elder-friendly container card with subtle borders, generous padding,
/// and calm elevation.
class CalmCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color? borderColor;
  final double borderWidth;

  const CalmCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor = AppColors.cardSurface,
    this.padding = const EdgeInsets.all(20.0),
    this.margin = const EdgeInsets.symmetric(vertical: 8.0),
    this.borderRadius = 20.0,
    this.borderColor,
    this.borderWidth = 1.4,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.borderSoft,
          width: borderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.forestPrimary.withValues(alpha: 0.06),
          highlightColor: AppColors.forestPrimary.withValues(alpha: 0.04),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    return cardContent;
  }
}
