import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import 'calm_card.dart';
import 'elder_button.dart';

enum ViewUiState {
  ready,
  loading,
  processing,
  empty,
  offline,
  insufficientData,
  recoverableError,
  nonRecoverableError,
}

/// Unified container widget supporting all required UI states:
/// Loading, Multi-step processing, Empty, Offline, Error with Retry, and Insufficient Data.
class StateContainer extends StatelessWidget {
  final ViewUiState state;
  final Widget child;
  final String? loadingMessage;
  final String? emptyTitle;
  final String? emptyMessage;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionLabel;

  const StateContainer({
    super.key,
    required this.state,
    required this.child,
    this.loadingMessage,
    this.emptyTitle,
    this.emptyMessage,
    this.errorMessage,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.onSecondaryAction,
    this.secondaryActionLabel,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ViewUiState.ready:
        return child;

      case ViewUiState.loading:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.forestPrimary),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  loadingMessage ?? 'Loading gentle content...',
                  style: AppTypography.patientBody.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );

      case ViewUiState.processing:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.sage),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  loadingMessage ?? 'Personalizing gentle activities...',
                  style: AppTypography.patientTitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Organizing familiar preferences, routines, and comfortable pace.',
                  style: AppTypography.caregiverBody,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );

      case ViewUiState.empty:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: CalmCard(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.spa_outlined,
                    size: 64,
                    color: AppColors.sage,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    emptyTitle ?? 'No Activities Right Now',
                    style: AppTypography.patientTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    emptyMessage ??
                        'Everything is calm and up to date. You can add new memories or take a peaceful rest.',
                    style: AppTypography.caregiverBody,
                    textAlign: TextAlign.center,
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 22),
                    ElderButton(
                      label: retryLabel ?? 'Refresh',
                      icon: Icons.refresh,
                      onPressed: onRetry,
                      variant: ElderButtonVariant.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );

      case ViewUiState.offline:
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.offlineAmber.withValues(alpha: 0.14),
              child: const Row(
                children: [
                  Icon(Icons.cloud_off, size: 20, color: AppColors.offlineAmber),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Offline Mode — Activities are loaded safely from device storage.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        );

      case ViewUiState.insufficientData:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: CalmCard(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 58,
                    color: AppColors.peachDark,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'More Details Will Help Personalize',
                    style: AppTypography.patientTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Adding favorite songs, daily tea anchors, or comfort needs helps craft better gentle recommendations.',
                    style: AppTypography.caregiverBody,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  if (onSecondaryAction != null) ...[
                    ElderButton(
                      label: secondaryActionLabel ?? 'Add Details to Profile',
                      icon: Icons.edit_note,
                      onPressed: onSecondaryAction,
                      variant: ElderButtonVariant.primary,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (onRetry != null)
                    ElderButton(
                      label: 'Continue with Starter Activities',
                      icon: Icons.play_arrow,
                      onPressed: onRetry,
                      variant: ElderButtonVariant.secondary,
                    ),
                ],
              ),
            ),
          ),
        );

      case ViewUiState.recoverableError:
      case ViewUiState.nonRecoverableError:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: CalmCard(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 58,
                    color: AppColors.peach,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "That's Okay. We Can Take Our Time.",
                    style: AppTypography.patientTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    errorMessage ??
                        'We had a small hiccup reaching the service. Your saved activities and progress remain completely safe.',
                    style: AppTypography.caregiverBody,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  if (onRetry != null) ...[
                    ElderButton(
                      label: retryLabel ?? 'Try Again Gently',
                      icon: Icons.refresh,
                      onPressed: onRetry,
                      variant: ElderButtonVariant.primary,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (onSecondaryAction != null)
                    ElderButton(
                      label: secondaryActionLabel ?? 'Continue with Starter Activities',
                      icon: Icons.arrow_forward,
                      onPressed: onSecondaryAction,
                      variant: ElderButtonVariant.secondary,
                    ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
