import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import 'elder_button.dart';

/// Non-punitive, accessible back and exit control with optional confirmation.
class GentleBackButton extends StatelessWidget {
  final String label;
  final bool showConfirmation;
  final String confirmationTitle;
  final String confirmationMessage;
  final VoidCallback? onExitConfirmed;

  const GentleBackButton({
    super.key,
    this.label = 'Back',
    this.showConfirmation = false,
    this.confirmationTitle = 'Take a Peaceful Rest?',
    this.confirmationMessage =
        'You can return to today’s activities anytime. Everything you have done is safely preserved.',
    this.onExitConfirmed,
  });

  Future<void> _handlePress(BuildContext context) async {
    if (!showConfirmation) {
      if (onExitConfirmed != null) {
        onExitConfirmed!();
      } else {
        Navigator.of(context).maybePop();
      }
      return;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundWarm,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(confirmationTitle, style: AppTypography.patientTitle),
        content: Text(confirmationMessage, style: AppTypography.caregiverBody),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        actions: [
          ElderButton(
            label: 'Stay Here',
            variant: ElderButtonVariant.primary,
            height: 52,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          const SizedBox(height: 10),
          ElderButton(
            label: 'Pause & Exit Gently',
            variant: ElderButtonVariant.secondary,
            height: 52,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (shouldExit == true && context.mounted) {
      if (onExitConfirmed != null) {
        onExitConfirmed!();
      } else {
        Navigator.of(context).maybePop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handlePress(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.arrow_back_ios_new,
              size: 22,
              color: AppColors.forestPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.forestPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
