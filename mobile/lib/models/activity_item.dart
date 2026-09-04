import 'package:flutter/material.dart';
import 'cognitive_domain.dart';

enum ActivityModality {
  independent,       // Solo elder-facing activity, low pressure
  cognitiveTogether, // 2-person collaborative cognitive game with caregiver hints
  connectionTogether,// Low-pressure shared experience (Look & Talk, Story, Music)
}

class ActivityItem {
  final String id;
  final String title;
  final String patientFriendlyTitle;
  final String subtitle;
  final CognitiveDomainType domain;
  final ActivityModality modality;
  final String difficultyLabel; // 'Gentle', 'Standard', 'Expanded'
  final int estimatedDurationMinutes;
  final bool requiresCaregiver;
  final bool supportsPersonalizedMedia;
  final bool supportsAudioGuidance;
  final List<String> culturalTags;
  final IconData icon;
  final Color themeColor;
  final String routeName;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.patientFriendlyTitle,
    required this.subtitle,
    required this.domain,
    required this.modality,
    this.difficultyLabel = 'Gentle',
    this.estimatedDurationMinutes = 4,
    this.requiresCaregiver = false,
    this.supportsPersonalizedMedia = true,
    this.supportsAudioGuidance = true,
    this.culturalTags = const ['Familiar Nature', 'Daily Comfort'],
    required this.icon,
    required this.themeColor,
    required this.routeName,
  });

  String get modalityBadgeText {
    switch (modality) {
      case ActivityModality.independent:
        return 'Independent Gentle Play';
      case ActivityModality.cognitiveTogether:
        return 'Cognitive Together';
      case ActivityModality.connectionTogether:
        return 'Heartfelt Connection';
    }
  }
}
