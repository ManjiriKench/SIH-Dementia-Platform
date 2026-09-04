import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/cognitive_domain.dart';

/// Caregiver domain indicator tag showing formal name, patient-friendly name,
/// and constructive support priority (Gentle Pace / Guided Support / Maintain Confidence).
class DomainBadge extends StatelessWidget {
  final CognitiveDomain domain;
  final bool isCompact;
  final VoidCallback? onOverrideTap;

  const DomainBadge({
    super.key,
    required this.domain,
    this.isCompact = false,
    this.onOverrideTap,
  });

  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    switch (domain.priority) {
      case DomainSupportPriority.gentle:
        priorityColor = AppColors.sage;
        break;
      case DomainSupportPriority.support:
        priorityColor = AppColors.forestPrimary;
        break;
      case DomainSupportPriority.maintain:
        priorityColor = AppColors.peachDark;
        break;
    }

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: domain.accentColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: domain.accentColor.withValues(alpha: 0.4), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(domain.icon, size: 16, color: domain.accentColor),
            const SizedBox(width: 6),
            Text(
              domain.patientFriendlyName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: domain.accentColor,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSoft, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: domain.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(domain.icon, size: 28, color: domain.accentColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      domain.patientFriendlyName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${domain.formalName})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  domain.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Support Style: ${domain.priorityDisplayLabel}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: priorityColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onOverrideTap != null)
            IconButton(
              icon: const Icon(Icons.tune, color: AppColors.forestPrimary),
              tooltip: 'Adjust support style',
              onPressed: onOverrideTap,
            ),
        ],
      ),
    );
  }
}
