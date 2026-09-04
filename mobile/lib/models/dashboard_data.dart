import 'activity_item.dart';
import 'caregiver_feedback.dart';
import 'cognitive_domain.dart';

class DailyContextPoint {
  final String dayLabel; // "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
  final int completedActivitiesCount;
  final double engagementLevel; // 1.0 - 5.0 (Gentle scale)
  final String primaryMood;     // 'calm', 'engaged', 'tired', 'joyful'
  final bool hadTogetherSession;
  final bool hadMusicActivity;

  const DailyContextPoint({
    required this.dayLabel,
    required this.completedActivitiesCount,
    required this.engagementLevel,
    required this.primaryMood,
    this.hadTogetherSession = false,
    this.hadMusicActivity = false,
  });
}

class DomainExposureMetric {
  final CognitiveDomainType domain;
  final String domainName;
  final int sessionsCountThisWeek;
  final String comfortSummary; // 'Comfortable & unhurried', 'Enjoyed music prompts'

  const DomainExposureMetric({
    required this.domain,
    required this.domainName,
    required this.sessionsCountThisWeek,
    required this.comfortSummary,
  });
}

class DashboardData {
  final String patientName;
  final int completedTodayCount;
  final int targetDailyActivities;
  final int pendingFeedbackCount;
  final List<ActivityItem> recommendedNextActivities;
  final List<DailyContextPoint> weeklyConsistency;
  final List<DomainExposureMetric> domainExposure;
  final List<CaregiverFeedback> recentFeedback;
  final SyncStatus syncStatus;
  final DateTime lastUpdated;
  final String disclaimer;

  const DashboardData({
    required this.patientName,
    this.completedTodayCount = 2,
    this.targetDailyActivities = 3,
    this.pendingFeedbackCount = 1,
    required this.recommendedNextActivities,
    required this.weeklyConsistency,
    required this.domainExposure,
    required this.recentFeedback,
    this.syncStatus = SyncStatus.synced,
    required this.lastUpdated,
    this.disclaimer = 'These are activity and engagement trends, not a medical assessment or diagnostic conclusion.',
  });
}
