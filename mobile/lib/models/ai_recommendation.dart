import 'activity_item.dart';
import 'cognitive_domain.dart';

enum AiProcessingStatus {
  preparing,           // Organizing shared information
  personalizing,       // Finding gentle activities based on abilities, routines
  ready,               // Recommendations ready
  delayedOffline,      // Saved locally, will sync when connected
  failed,              // Error state with retry and starter fallbacks
  insufficientInfo,    // Needs more routine/preference details to refine
}

class AiRecommendation {
  final String patientId;
  final DateTime generatedAt;
  final AiProcessingStatus status;
  final List<CognitiveDomain> sixDomainOverview;
  final List<ActivityItem> recommendedActivities;
  final List<ActivityItem> fallbackStarterActivities;
  final List<String> reasoningInfluences; // e.g. "Morning tea preference", "Assam music affinity", "Low-pace touch need"
  final String supportiveExplanation;
  final bool caregiverOverrideAllowed;
  final bool isOverriddenByCaregiver;

  const AiRecommendation({
    required this.patientId,
    required this.generatedAt,
    required this.status,
    required this.sixDomainOverview,
    required this.recommendedActivities,
    required this.fallbackStarterActivities,
    required this.reasoningInfluences,
    required this.supportiveExplanation,
    this.caregiverOverrideAllowed = true,
    this.isOverriddenByCaregiver = false,
  });

  AiRecommendation copyWith({
    AiProcessingStatus? status,
    List<CognitiveDomain>? sixDomainOverview,
    List<ActivityItem>? recommendedActivities,
    List<ActivityItem>? fallbackStarterActivities,
    List<String>? reasoningInfluences,
    String? supportiveExplanation,
    bool? caregiverOverrideAllowed,
    bool? isOverriddenByCaregiver,
  }) {
    return AiRecommendation(
      patientId: patientId,
      generatedAt: generatedAt,
      status: status ?? this.status,
      sixDomainOverview: sixDomainOverview ?? this.sixDomainOverview,
      recommendedActivities: recommendedActivities ?? this.recommendedActivities,
      fallbackStarterActivities: fallbackStarterActivities ?? this.fallbackStarterActivities,
      reasoningInfluences: reasoningInfluences ?? this.reasoningInfluences,
      supportiveExplanation: supportiveExplanation ?? this.supportiveExplanation,
      caregiverOverrideAllowed: caregiverOverrideAllowed ?? this.caregiverOverrideAllowed,
      isOverriddenByCaregiver: isOverriddenByCaregiver ?? this.isOverriddenByCaregiver,
    );
  }
}
