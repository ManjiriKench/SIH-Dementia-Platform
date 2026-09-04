import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/app_routes.dart';
import '../../models/cognitive_domain.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/caregiver/domain_badge.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';

/// Screen presenting the 6 Cognitive Domains support overview,
/// constructive support priorities, and caregiver override capabilities.
class DomainOverviewScreen extends StatefulWidget {
  const DomainOverviewScreen({super.key});

  @override
  State<DomainOverviewScreen> createState() => _DomainOverviewScreenState();
}

class _DomainOverviewScreenState extends State<DomainOverviewScreen> {
  @override
  void initState() {
    super.initState();
    RecommendationService.instance.addListener(_onUpdate);
  }

  @override
  void dispose() {
    RecommendationService.instance.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  void _showOverrideSheet(BuildContext context, CognitiveDomain domain) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundWarm,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.borderSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(domain.icon, color: domain.accentColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Adjust: ${domain.patientFriendlyName}',
                  style: AppTypography.caregiverHeading,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Formal domain: ${domain.formalName}. Caregivers can override the AI recommendation anytime.',
              style: AppTypography.caregiverBody,
            ),
            const SizedBox(height: 20),
            const Text('Choose Preferred Support Style:', style: AppTypography.caregiverSubheading),
            const SizedBox(height: 12),
            _buildOverrideChoice(
              ctx,
              domain,
              DomainSupportPriority.gentle,
              'Gentle Pace',
              'Low stimulation, maximum familiar content and unhurried time.',
              AppColors.sage,
            ),
            const SizedBox(height: 8),
            _buildOverrideChoice(
              ctx,
              domain,
              DomainSupportPriority.support,
              'Guided Support',
              'Comfortable stimulation with caregiver prompts and hints.',
              AppColors.forestPrimary,
            ),
            const SizedBox(height: 8),
            _buildOverrideChoice(
              ctx,
              domain,
              DomainSupportPriority.maintain,
              'Maintain Confidence',
              'Celebrate existing strengths to reinforce independence.',
              AppColors.peachDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverrideChoice(
    BuildContext ctx,
    CognitiveDomain domain,
    DomainSupportPriority priority,
    String label,
    String description,
    Color color,
  ) {
    final isSelected = domain.priority == priority;

    return InkWell(
      onTap: () {
        RecommendationService.instance.overrideDomainPriority(domain.type, priority);
        Navigator.of(ctx).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Support style for "${domain.patientFriendlyName}" updated to $label.'),
            backgroundColor: AppColors.forestPrimary,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : AppColors.borderSoft,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? color : AppColors.textTertiary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
                  ),
                  Text(description, style: AppTypography.caregiverCaption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rec = RecommendationService.instance.currentRecommendation;
    final domains = rec?.sixDomainOverview ?? CognitiveDomain.defaultDomains;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        title: const Text('Six Cognitive Domains', style: AppTypography.caregiverHeading),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_outlined, color: AppColors.forestPrimary),
            tooltip: 'Caregiver Dashboard',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.caregiverDashboard);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Caregiver guidance card
              CalmCard(
                backgroundColor: AppColors.surfaceWarm,
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.support, color: AppColors.forestPrimary, size: 28),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Support Plan (Caregiver Overview)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'All activities map to these 6 domains. Tap the tune icon on any card to adjust support pace.',
                            style: AppTypography.caregiverBody,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text('Active Domain Recommendations', style: AppTypography.caregiverHeading),
              const SizedBox(height: 10),
              // 6 Domain Cards
              ...domains.map((domain) => DomainBadge(
                    domain: domain,
                    onOverrideTap: () => _showOverrideSheet(context, domain),
                  )),
              const SizedBox(height: 24),
              ElderButton(
                label: 'Start Today’s Gentle Journey',
                icon: Icons.play_arrow,
                variant: ElderButtonVariant.primary,
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.todaysJourney);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
