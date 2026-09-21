import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/navigation/app_routes.dart';
import '../../models/activity_item.dart';
import '../../models/appointment.dart';
import '../../models/cognitive_domain.dart';
import '../../models/dashboard_data.dart';
import '../../models/medication.dart';
import '../../services/alert_service.dart';
import '../../services/care_plan_service.dart';
import '../../services/feedback_service.dart';
import '../../services/memory_service.dart';
import '../../services/mock_data_repository.dart';
import '../../services/profile_service.dart';
import '../../services/recommendation_service.dart';
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
/// Organized cleanly with an Alert Banner and 5 collapsible section cards.
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
    'Evening Family Song & Prayer (7:00 PM)': true,
  };

  @override
  void initState() {
    super.initState();
    FeedbackService.instance.addListener(_onServiceUpdate);
    ProfileService.instance.addListener(_onServiceUpdate);
    SessionService.instance.addListener(_onServiceUpdate);
    AlertService.instance.addListener(_onServiceUpdate);
    CarePlanService.instance.addListener(_onServiceUpdate);
    RecommendationService.instance.addListener(_onServiceUpdate);
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    FeedbackService.instance.removeListener(_onServiceUpdate);
    ProfileService.instance.removeListener(_onServiceUpdate);
    SessionService.instance.removeListener(_onServiceUpdate);
    AlertService.instance.removeListener(_onServiceUpdate);
    CarePlanService.instance.removeListener(_onServiceUpdate);
    RecommendationService.instance.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _showAddMedicationDialog() {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();
    final timingCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundWarm,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.medication_outlined, color: AppColors.forestPrimary),
            SizedBox(width: 8),
            Text('Add Medication', style: AppTypography.caregiverHeading),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Medication Name',
                  hintText: 'e.g. Donepezil',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dosageCtrl,
                decoration: InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'e.g. 5mg or 1 capsule',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timingCtrl,
                decoration: InputDecoration(
                  labelText: 'Timing',
                  hintText: 'e.g. Morning after breakfast',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                CarePlanService.instance.addMedication(
                  Medication(
                    id: 'med_${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    dosage: dosageCtrl.text.trim().isEmpty ? 'As prescribed' : dosageCtrl.text.trim(),
                    timing: timingCtrl.text.trim().isEmpty ? 'Daily' : timingCtrl.text.trim(),
                  ),
                );
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save Medication'),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentDialog() {
    final titleCtrl = TextEditingController();
    final doctorCtrl = TextEditingController();
    final locationCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundWarm,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.calendar_month_outlined, color: AppColors.forestPrimary),
            SizedBox(width: 8),
            Text('Add Appointment', style: AppTypography.caregiverHeading),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Appointment Purpose',
                  hintText: 'e.g. Memory Clinic Routine Checkup',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: doctorCtrl,
                decoration: InputDecoration(
                  labelText: 'Doctor / Specialist',
                  hintText: 'e.g. Dr. Sharma (Neurologist)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locationCtrl,
                decoration: InputDecoration(
                  labelText: 'Location / Hospital',
                  hintText: 'e.g. GMCH Guwahati',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final title = titleCtrl.text.trim();
              if (title.isNotEmpty) {
                CarePlanService.instance.addAppointment(
                  Appointment(
                    id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
                    title: title,
                    doctorName: doctorCtrl.text.trim().isEmpty ? 'Consultant' : doctorCtrl.text.trim(),
                    location: locationCtrl.text.trim().isEmpty ? 'Local Clinic' : locationCtrl.text.trim(),
                    scheduledAt: DateTime.now().add(const Duration(days: 7)),
                  ),
                );
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save Appointment'),
          ),
        ],
      ),
    );
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
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
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
    final todayWeekday = now.weekday;
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
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
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
    final hasPendingFeedback = feedbackList.isEmpty || dashboardData.pendingFeedbackCount > 0;
    final activeAlerts = AlertService.instance.activeAlerts;
    final medications = CarePlanService.instance.medications;
    final appointments = CarePlanService.instance.upcomingAppointments;
    final activityInsights = RecommendationService.instance.getInsightsForCaregiver();
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. ACTIVE ALERTS BANNER (Topmost if stress/frustration raised)
              if (activeAlerts.isNotEmpty) ...[
                ...activeAlerts.map((alert) {
                  final timeFormatted = '${alert.time.hour.toString().padLeft(2, '0')}:${alert.time.minute.toString().padLeft(2, '0')}';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.errorGentle, width: 1.5),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEE2E2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.warning_amber_rounded, color: AppColors.errorGentle, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Gentle Attention Needed',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.errorGentle,
                                    ),
                                  ),
                                  Text(
                                    timeFormatted,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Discomfort or stress was noted during ${alert.activityTitle} (${alert.reason}). Consider checking in with a warm beverage or quiet companionship.',
                                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => AlertService.instance.clearAlert(alert.id),
                                  icon: const Icon(Icons.check, size: 16, color: AppColors.forestPrimary),
                                  label: const Text(
                                    'Acknowledge & Clear',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.forestPrimary),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: const BorderSide(color: AppColors.borderSoft),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 6),
              ],

              // 2. Patient Profile Summary Card
              CalmCard(
                borderColor: AppColors.forestPrimary.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceWarm,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, size: 32, color: AppColors.forestPrimary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(patientName, style: AppTypography.caregiverHeading),
                              Text(
                                '${patient.ageRange} • ${patient.relationshipToCaregiver}',
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                              ),
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
                    const SizedBox(height: 10),
                    const Divider(color: AppColors.borderSoft),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
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

              const SizedBox(height: 14),

              // 3. Quick Actions Row
              Row(
                children: [
                  Expanded(
                    child: ElderButton(
                      label: "Today's Journey",
                      icon: Icons.play_arrow,
                      variant: ElderButtonVariant.primary,
                      height: 48,
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.todaysJourney);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElderButton(
                      label: 'Memory Space (${memories.length})',
                      icon: Icons.photo_library_outlined,
                      variant: ElderButtonVariant.peach,
                      height: 48,
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.memoryVault);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // 4. FIVE COLLAPSIBLE SECTION CARDS

              // SECTION 1: 📊 Insights (Weekly chart, Domain exposure, Per-activity engagement)
              _DashboardSectionCard(
                title: 'Activity Insights & Engagement',
                icon: Icons.insights_rounded,
                initialExpanded: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CollapsibleTrendGraph(weeklyData: dashboardData.weeklyConsistency),
                    const SizedBox(height: 10),

                    // Domain exposure header
                    Row(
                      children: [
                        const Icon(Icons.pie_chart_outline_rounded, color: AppColors.forestPrimary, size: 18),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text('Domain Balance This Week', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.domainOverview),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: const Text('Explain', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...dashboardData.domainExposure.map((exposure) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getDomainColor(exposure.domain),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(exposure.domainName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                            Text(
                              '${exposure.sessionsCountThisWeek} sessions',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 16),
                    const Divider(color: AppColors.borderSoft),
                    const SizedBox(height: 8),

                    // Per-Activity engagement scores (Caregiver view only)
                    const Row(
                      children: [
                        Icon(Icons.psychology_outlined, color: AppColors.forestPrimary, size: 18),
                        SizedBox(width: 6),
                        Text('Per-Activity Comfort (Private to Caregiver)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...activityInsights.map((insight) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWarm.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderSoft),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(insight.activityTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: insight.skipRate > 35 ? AppColors.peachLight : AppColors.sageLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    insight.engagementLevel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: insight.skipRate > 35 ? AppColors.warningWarm : AppColors.forestDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(insight.recommendationNote, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // SECTION 2: ⏰ Routine Reminders
              _DashboardSectionCard(
                title: 'Daily Routine Reminders',
                icon: Icons.alarm_on_rounded,
                trailingBadge: IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.forestPrimary, size: 20),
                  tooltip: 'Add Reminder',
                  onPressed: _showAddReminderDialog,
                ),
                child: Column(
                  children: [
                    ..._routineReminders.entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderSoft),
                        ),
                        child: CheckboxListTile(
                          value: entry.value,
                          activeColor: AppColors.forestPrimary,
                          title: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 13,
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
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // SECTION 3: 💊 Medications
              _DashboardSectionCard(
                title: 'Medications Plan',
                icon: Icons.medication_outlined,
                trailingBadge: IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.forestPrimary, size: 20),
                  tooltip: 'Add Medication',
                  onPressed: _showAddMedicationDialog,
                ),
                child: Column(
                  children: [
                    if (medications.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No medications added yet.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      )
                    else
                      ...medications.map((med) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderSoft),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  med.isTakenToday ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: med.isTakenToday ? AppColors.forestPrimary : AppColors.borderSoft,
                                ),
                                onPressed: () => CarePlanService.instance.toggleMedicationTaken(med.id),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      med.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        decoration: med.isTakenToday ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    Text(
                                      '${med.dosage} • ${med.timing}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textTertiary),
                                onPressed: () => CarePlanService.instance.removeMedication(med.id),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // SECTION 4: 📅 Doctor Appointments
              _DashboardSectionCard(
                title: 'Doctor Appointments',
                icon: Icons.calendar_month_outlined,
                trailingBadge: IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.forestPrimary, size: 20),
                  tooltip: 'Add Appointment',
                  onPressed: _showAddAppointmentDialog,
                ),
                child: Column(
                  children: [
                    if (appointments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No upcoming appointments scheduled.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      )
                    else
                      ...appointments.map((appt) {
                        final dateStr = '${appt.scheduledAt.day}/${appt.scheduledAt.month}/${appt.scheduledAt.year}';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderSoft),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceWarm,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.event_available, color: AppColors.forestPrimary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(appt.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('${appt.doctorName} • $dateStr', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    if (appt.location != null)
                                      Text(appt.location!, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textTertiary),
                                onPressed: () => CarePlanService.instance.removeAppointment(appt.id),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // SECTION 5: 📝 Observations & Feedback
              _DashboardSectionCard(
                key: ValueKey('feedback_section_$hasPendingFeedback'),
                title: 'Caregiver Observations & Feedback',
                icon: Icons.rate_review_outlined,
                initialExpanded: hasPendingFeedback,
                trailingBadge: hasPendingFeedback
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.errorGentle),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline_rounded, size: 12, color: AppColors.errorGentle),
                            SizedBox(width: 4),
                            Text(
                              'URGENT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.errorGentle,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Submitted ✓',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.forestDark),
                        ),
                      ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasPendingFeedback) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.errorGentle.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFEE2E2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.warning_amber_rounded, color: AppColors.errorGentle, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Feedback Submission Urgent',
                                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.errorGentle),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Sharing observations adapts tomorrow’s difficulty & activity selection.',
                                    style: TextStyle(fontSize: 11.5, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.errorGentle,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.caregiverFeedback),
                              child: const Text('Submit Now'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (feedbackList.isNotEmpty) ...[
                      ...feedbackList.take(3).map((fb) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderSoft),
                          ),
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
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.sageLight,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          tag,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.forestDark),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  Text(
                                    'Rating: ${fb.comfortRating}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              if (fb.whatHelped != null && fb.whatHelped!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  '"${fb.whatHelped}"',
                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textPrimary),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.caregiverFeedback),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Observation', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

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

/// Expandable and collapsible card component for clean caregiver dashboard sections.
class _DashboardSectionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailingBadge;
  final bool initialExpanded;

  const _DashboardSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailingBadge,
    this.initialExpanded = false,
  });

  @override
  State<_DashboardSectionCard> createState() => _DashboardSectionCardState();
}

class _DashboardSectionCardState extends State<_DashboardSectionCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWarm,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, size: 20, color: AppColors.forestPrimary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ),
                  if (widget.trailingBadge != null) widget.trailingBadge!,
                  Icon(
                    _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: AppColors.forestPrimary,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: widget.child,
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Collapsible sliding weekly consistency chart (hidden by default with arrow toggle)
class _CollapsibleTrendGraph extends StatefulWidget {
  final List<DailyContextPoint> weeklyData;
  const _CollapsibleTrendGraph({required this.weeklyData});

  @override
  State<_CollapsibleTrendGraph> createState() => _CollapsibleTrendGraphState();
}

class _CollapsibleTrendGraphState extends State<_CollapsibleTrendGraph> {
  bool _isGraphOpen = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isGraphOpen = !_isGraphOpen),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.bar_chart_rounded, color: AppColors.forestPrimary, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Weekly Consistency Chart',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.forestDark),
                    ),
                  ),
                  Text(
                    _isGraphOpen ? 'Hide' : 'Slide to View',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.forestPrimary),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _isGraphOpen ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.expand_more_rounded, color: AppColors.forestPrimary, size: 20),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isGraphOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              child: TrendBarChart(weeklyData: widget.weeklyData),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

