import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';

/// Medium-sized language toggle button positioned on the top right.
/// Allows instant switching between English, Hindi, and Assamese.
class LanguageToggleWidget extends StatelessWidget {
  final bool compact;

  const LanguageToggleWidget({super.key, this.compact = false});

  static const List<Map<String, String>> languages = [
    {'code': 'as', 'label': 'Assamese', 'native': 'অসমীয়া', 'sub': 'Assam • North-East'},
    {'code': 'bn', 'label': 'Bengali', 'native': 'বাংলা', 'sub': 'Tripura & Barak • North-East'},
    {'code': 'brx', 'label': 'Bodo', 'native': 'बर\' / बड़ो', 'sub': 'Bodoland • North-East'},
    {'code': 'mni', 'label': 'Manipuri', 'native': 'মৈতৈলোন্', 'sub': 'Manipur • North-East'},
    {'code': 'lus', 'label': 'Mizo', 'native': 'Mizo ṭawng', 'sub': 'Mizoram • North-East'},
    {'code': 'en', 'label': 'English', 'native': 'English', 'sub': 'Standard'},
    {'code': 'hi', 'label': 'Hindi', 'native': 'हिंदी', 'sub': 'National'},
  ];

  String _getCurrentDisplay(String code) {
    if (compact) {
      switch (code) {
        case 'as':
          return 'AS';
        case 'bn':
          return 'BN';
        case 'brx':
          return 'BRX';
        case 'mni':
          return 'MNI';
        case 'lus':
          return 'MIZ';
        case 'hi':
          return 'HI';
        case 'en':
        default:
          return 'EN';
      }
    }
    switch (code) {
      case 'as':
        return 'অসমীয়া';
      case 'bn':
        return 'বাংলা';
      case 'brx':
        return 'बर\'';
      case 'mni':
        return 'মৈতৈলোন্';
      case 'lus':
        return 'Mizo';
      case 'hi':
        return 'हिंदी';
      case 'en':
      default:
        return 'English';
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWarm,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceWarm,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.language, color: AppColors.forestPrimary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Select Language • ভাষা বাছক',
                        style: AppTypography.patientTitle,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'The entire application will immediately update to your preferred language.',
                  style: AppTypography.caregiverBody,
                ),
                const SizedBox(height: 18),
                ...languages.map((lang) {
                  final isSelected = AppStrings.currentLanguage == lang['code'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: InkWell(
                      onTap: () {
                        AppStrings.setLanguage(lang['code']!);
                        Navigator.of(ctx).pop();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.surfaceWarm : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.forestPrimary : AppColors.borderSoft,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isSelected ? AppColors.forestPrimary : AppColors.textTertiary,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang['native']!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${lang['label']} (${lang['sub']})',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.forestPrimary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.forestPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppStrings.languageNotifier,
      builder: (context, currentLang, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showLanguageDialog(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 8 : 12,
                vertical: compact ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.forestPrimary.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.forestPrimary.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.language,
                    size: compact ? 16 : 18,
                    color: AppColors.forestPrimary,
                  ),
                  SizedBox(width: compact ? 4 : 6),
                  Text(
                    _getCurrentDisplay(currentLang),
                    style: TextStyle(
                      fontSize: compact ? 12 : 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestPrimary,
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.forestPrimary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
