import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/app_routes.dart';
import '../../models/activity_item.dart';
import '../../models/cognitive_domain.dart';
import '../../models/dashboard_data.dart';
import '../../services/feedback_service.dart';
import '../../services/memory_service.dart';
import '../../services/mock_data_repository.dart';
import '../../services/profile_service.dart';
import '../../services/session_service.dart';
import '../../widgets/caregiver/trend_bar_chart.dart';
import '../../widgets/common/calm_card.dart';
import '../../widgets/common/elder_button.dart';
import '../../widgets/common/gentle_back_button.dart';
import '../../widgets/common/language_toggle_widget.dart';
import '../activities/activities_catalog_sheet.dart';

/// Caregiver Dashboard Screen.
/// Provides a comprehensive, compassionate window into the loved one's comfort,
/// 6-domain exposure, activity history, memory vault, daily observations,
/// and secondary wellness/routine reminders without clinical or diagnostic pressure.
class CaregiverDashboardScreen extends StatefulWidget {
  const CaregiverDashboardScreen({super.key});

  @override
  State<CaregiverDashboardScreen> createState() => _CaregiverDashboardScreenState();
}

class _CaregiverDashboardScreenState extends State<CaregiverDashboardScreen> {
  final Map<String, bool> _routineReminders = {
    'Morning Hydration & Assam Tea (8:30 AM)': true,
    'Doctor’s Recommended Gentle Walk (10:00 AM)': true,
    'Afternoon Quiet Rest & Veranda Pause (2:00 PM)': true,
    'Evening Medication & Family Prayer (7:00 PM)': true,
  };

  @override
  void initState() {
    super.initState();
    FeedbackService.instance.addListener(_onServiceUpdate);
    ProfileService.instance.addListener(_onServiceUpdate);
    SessionService.instance.addListener(_onServiceUpdate);
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    FeedbackService.instance.removeListener(_onServiceUpdate);
    ProfileService.instance.removeListener(_onServiceUpdate);
    SessionService.instance.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _showAddReminderDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundWarm,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Add Routine Reminder', style: AppTypography.caregiverHeading),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Secondary reminder to support daily rhythm (e.g. hydration, doctor check-in).',
              style: AppTypography.caregiverCaption,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'e.g. Doctor visit Friday 11 AM',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _routineReminders[text] = false;
                });
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Reminder'),
          ),
        ],
      ),
    );
  }

  DashboardData _buildDynamicDashboardData(String patientName) {
    final base = MockDataRepository.getSampleDashboardData(patientName);
    final history = SessionService.instance.completedSessionsHistory;

    if (history.isEmpty) return base;

    // 1. Calculate live domain exposures
    final Map<CognitiveDomainType, int> domainCounts = {};
    for (final s in history) {
      domainCounts[s.domain] = (domainCounts[s.domain] ?? 0) + 1;
    }

    final updatedDomainExposure = base.domainExposure.map((exposure) {
      final liveCount = domainCounts[exposure.domain] ?? 0;
      return DomainExposureMetric(
        domain: exposure.domain,
        domainName: exposure.domainName,
        sessionsCountThisWeek: exposure.sessionsCountThisWeek + liveCount,
        comfortSummary: liveCount > 0
            ? 'Active engagement: $liveCount session${liveCount > 1 ? "s" : ""} recorded today'
            : exposure.comfortSummary,
      );
    }).toList();

    // 2. Calculate today's completions for weekly consistency
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1 = Mon, 7 = Sun
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayLabel = dayLabels[todayWeekday - 1];

    final todaySessions = history.where((s) =>
        s.startTime.year == now.year &&
        s.startTime.month == now.month &&
        s.startTime.day == now.day).length;

    final updatedWeekly = base.weeklyConsistency.map((point) {
      if (point.dayLabel == todayLabel) {
        return DailyContextPoint(
          dayLabel: point.dayLabel,
          completedActivitiesCount: point.completedActivitiesCount + todaySessions,
          engagementLevel: point.engagementLevel,
          primaryMood: point.primaryMood,
          hadTogetherSession: point.hadTogetherSession || history.any((s) => s.modality == ActivityModality.cognitiveTogether),
          hadMusicActivity: point.hadMusicActivity || history.any((s) => s.activityId.contains('music')),
        );
      }
      return point;
    }).toList();

    return DashboardData(
      patientName: patientName,
      completedTodayCount: base.completedTodayCount + todaySessions,
      targetDailyActivities: base.targetDailyActivities,
      pendingFeedbackCount: base.pendingFeedbackCount,
      recommendedNextActivities: base.recommendedNextActivities,
      weeklyConsistency: updatedWeekly,
      domainExposure: updatedDomainExposure,
      recentFeedback: base.recentFeedback,
      syncStatus: base.syncStatus,
      lastUpdated: now,
    );
  }

  void _confirmResetDemo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.restart_alt_rounded, color: AppColors.forestPrimary),
            SizedBox(width: 8),
            Text('Reset Demo Story', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          'This will reset the active session to the fresh Bonti Baruah demo profile with baseline activity consistency for your presentation.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await ProfileService.instance.resetToDemoProfile();
              await SessionService.instance.clearHistory();
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Demo profile reset successfully for presentation.'),
                    backgroundColor: AppColors.forestPrimary,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Reset Demo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = ProfileService.instance.activeProfile ?? MockDataRepository.createSamplePatient();
    final patientName = patient.preferredName;
    final dashboardData = _buildDynamicDashboardData(patientName);
    final feedbackList = FeedbackService.instance.feedbackList;
    MemoryService.instance.initialize();
    final memories = MemoryService.instance.memories;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWarm,
        elevation: 0,
        leading: const GentleBackButton(),
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text('Caregiver Dashboard', style: AppTypography.caregiverHeading),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 4.0),
            child: LanguageToggleWidget(compact: true),
          ),
          IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: AppColors.forestPrimary),
            tooltip: 'All 8 Activities',
            onPressed: () => ActivitiesCatalogSheet.show(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.forestPrimary),
            tooltip: 'More options & diagnostics',
            onSelected: (val) {
              if (val == 'reset') _confirmResetDemo();
              if (val == 'states') Navigator.of(context).pushNamed(AppRoutes.systemStatesShowcase);
              if (val == 'diagnostics') Navigator.of(context).pushNamed('/backend_test');
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restart_alt_rounded, size: 20, color: AppColors.forestPrimary),
                    SizedBox(width: 10),
                    Text('Reset Demo Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'states',
                child: Row(
                  children: [
                    Icon(Icons.tune, size: 20, color: AppColors.forestPrimary),
                    SizedBox(width: 10),
                    Text('15 System States'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'diagnostics',
                child: Row(
                  children: [
                    Icon(Icons.science_outlined, size: 20, color: AppColors.forestPrimary),
                    SizedBox(width: 10),
                    Text('AI & Diagnostics'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient Profile Summary Card
              CalmCard(
                borderColor: AppColors.forestPrimary.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceWarm,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, size: 36, color: AppColors.forestPrimary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(patientName, style: AppTypography.caregiverHeading),
                              const SizedBox(height: 2),
                              Text(
                                '${patient.ageRange} • ${patient.relationshipToCaregiver}',
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Comfort: Large text • ${patient.hearingSupport.replaceAll("_", " ")}',
                                style: AppTypography.caregiverCaption,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.forestPrimary),
                          tooltip: 'Edit Profile & Preferences',
                          onPressed: () {
                            Navigator.of(context).pushNamed(AppRoutes.caregiverOnboarding);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: AppColors.borderSoft),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ...patient.interestsAndHobbies.take(3).map((h) => Chip(
                              label: Text(h, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              backgroundColor: AppColors.surfaceWarm,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )),
                        ...patient.favoriteMusicGenres.take(2).map((m) => Chip(
                              label: Text(m, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              backgroundColor: AppColors.surfaceWarm,
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick Actions Bar
              Row(
                children: [
                  Expanded(
                    child: ElderButton(
                      label: "Today's Journey",
                      icon: Icons.play_arrow,
                      variant: ElderButtonVariant.primary,
                      height: 50,
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.todaysJourney);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElderButton(
                      label: 'All 8 Activities',
                      icon: Icons.grid_view,
                      variant: ElderButtonVariant.peach,
                      height: 50,
                      onPressed: () => ActivitiesCatalogSheet.show(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Personal Memory Space Tile
              CalmCard(
                backgroundColor: AppColors.surfaceWarm,
                padding: const EdgeInsets.all(16),
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.memoryVault);
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.photo_library_outlined, size: 28, color: AppColors.forestPrimary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Personal Memory Space', style: AppTypography.caregiverSubheading),
                          const SizedBox(height: 2),
                          Text(
                            '${memories.length} cherished photos, songs, and stories anchored into games.',
                            style: AppTypography.caregiverCaption,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.forestPrimary),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Weekly Activity Consistency Bar Chart
              TrendBarChart(weeklyData: dashboardData.weeklyConsistency),

              const SizedBox(height: 24),

              // 6 Cognitive Domains Overview (Non-diagnostic framing)
              Row(
                children: [
                  const Icon(Icons.pie_chart_outline_rounded, color: AppColors.forestPrimary, size: 22),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Six Cognitive Domains Covered', style: AppTypography.caregiverHeading),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.domainOverview),
                    child: const Text('Explain', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Natural areas of engagement. Never medical tests or diagnostic scores.',
                style: AppTypography.caregiverCaption,
              ),
              const SizedBox(height: 12),

              ...dashboardData.domainExposure.map((exposure) {
                return CalmCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _getDomainColor(exposure.domain),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(exposure.domainName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            Text(exposure.comfortSummary, style: AppTypography.caregiverCaption),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWarm,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${exposure.sessionsCountThisWeek} sessions',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.forestDark),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Secondary Routine & Wellness Reminders
              Row(
                children: [
                  const Icon(Icons.alarm_on_rounded, color: AppColors.forestPrimary, size: 22),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Daily Routine & Wellness Reminders', style: AppTypography.caregiverHeading),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.forestPrimary),
                    tooltip: 'Add reminder',
                    onPressed: _showAddReminderDialog,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Secondary support for hydration, walks, and medications.',
                style: AppTypography.caregiverCaption,
              ),
              const SizedBox(height: 12),

              ..._routineReminders.entries.map((entry) {
                return CalmCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: CheckboxListTile(
                    value: entry.value,
                    activeColor: AppColors.forestPrimary,
                    title: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: entry.value ? TextDecoration.none : TextDecoration.lineThrough,
                        color: entry.value ? AppColors.textPrimary : AppColors.textTertiary,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: (val) {
                      setState(() {
                        _routineReminders[entry.key] = val ?? false;
                      });
                    },
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Recent Daily Observations & Caregiver Feedback
              Row(
                children: [
                  const Icon(Icons.rate_review_outlined, color: AppColors.forestPrimary, size: 22),
                  const SizedBox(width: 8),
                  const Text('Recent Caregiver Observations', style: AppTypography.caregiverHeading),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Observations provided after recent sessions that shape upcoming recommendations.',
                style: AppTypography.caregiverCaption,
              ),
              const SizedBox(height: 12),

              if (feedbackList.isEmpty)
                CalmCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(Icons.note_alt_outlined, color: AppColors.textTertiary, size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'No session observations submitted today. Observations will appear here after finishing activities.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.caregiverFeedback),
                        child: const Text('Add Now'),
                      ),
                    ],
                  ),
                )
              else
                ...feedbackList.take(3).map((fb) {
                  return CalmCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Wrap(
                              spacing: 6,
                              children: fb.observationTags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.sageLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.forestDark),
                                  ),
                                );
                              }).toList(),
                            ),
                            Text(
                              'Comfortable: ${fb.comfortRating}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        if (fb.whatHelped != null && fb.whatHelped!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '"${fb.whatHelped}"',
                            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textPrimary),
                          ),
                        ],
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 24),

              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.forestPrimary),
                  label: const Text(
                    'Export Supportive Caregiver Summary (Offline)',
                    style: TextStyle(color: AppColors.forestPrimary, fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Caregiver summary generated locally. Zero external cloud dependency.'),
                        backgroundColor: AppColors.forestPrimary,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDomainColor(CognitiveDomainType type) {
    switch (type) {
      case CognitiveDomainType.memory:
        return AppColors.domainMemory;
      case CognitiveDomainType.attention:
        return AppColors.domainAttention;
      case CognitiveDomainType.language:
        return AppColors.domainLanguage;
      case CognitiveDomainType.executive:
        return AppColors.domainExecutive;
      case CognitiveDomainType.orientation:
        return AppColors.domainOrientation;
      case CognitiveDomainType.visuospatial:
        return AppColors.domainVisuospatial;
    }
  }
}
