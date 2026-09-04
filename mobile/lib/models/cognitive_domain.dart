import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum CognitiveDomainType {
  memory,
  attention,
  language,
  executive,
  orientation,
  visuospatial,
}

enum DomainSupportPriority {
  gentle,   // For areas where low stimulation and familiar content are most comforting
  support,  // For areas where guided participation provides pleasant stimulation
  maintain, // For strengths where existing capability brings confidence
}

class CognitiveDomain {
  final CognitiveDomainType type;
  final String formalName;
  final String patientFriendlyName;
  final String description;
  final IconData icon;
  final Color accentColor;
  final DomainSupportPriority priority;

  const CognitiveDomain({
    required this.type,
    required this.formalName,
    required this.patientFriendlyName,
    required this.description,
    required this.icon,
    required this.accentColor,
    this.priority = DomainSupportPriority.support,
  });

  String get priorityDisplayLabel {
    switch (priority) {
      case DomainSupportPriority.gentle:
        return 'Gentle Pace';
      case DomainSupportPriority.support:
        return 'Guided Support';
      case DomainSupportPriority.maintain:
        return 'Maintain Confidence';
    }
  }

  static List<CognitiveDomain> get defaultDomains => [
    const CognitiveDomain(
      type: CognitiveDomainType.memory,
      formalName: 'Memory & Recognition',
      patientFriendlyName: 'Remember',
      description: 'Familiar people, cherished objects, photographs, and gentle recall.',
      icon: Icons.favorite_outline,
      accentColor: AppColors.domainMemory,
      priority: DomainSupportPriority.support,
    ),
    const CognitiveDomain(
      type: CognitiveDomainType.attention,
      formalName: 'Attention & Focus',
      patientFriendlyName: 'Notice',
      description: 'Gentle noticing, looking closely, and relaxed sustained attention.',
      icon: Icons.center_focus_strong_outlined,
      accentColor: AppColors.domainAttention,
      priority: DomainSupportPriority.gentle,
    ),
    const CognitiveDomain(
      type: CognitiveDomainType.language,
      formalName: 'Language & Communication',
      patientFriendlyName: 'Talk & Share',
      description: 'Word association, listening, song lyrics, and simple warm expression.',
      icon: Icons.chat_bubble_outline,
      accentColor: AppColors.domainLanguage,
      priority: DomainSupportPriority.support,
    ),
    const CognitiveDomain(
      type: CognitiveDomainType.executive,
      formalName: 'Executive Function',
      patientFriendlyName: 'Plan & Sort',
      description: 'Sequencing daily rituals, gentle sorting, and unhurried choices.',
      icon: Icons.auto_awesome_motion_outlined,
      accentColor: AppColors.domainExecutive,
      priority: DomainSupportPriority.maintain,
    ),
    const CognitiveDomain(
      type: CognitiveDomainType.orientation,
      formalName: 'Orientation & Daily Context',
      patientFriendlyName: 'Today & Places',
      description: 'Time of day, familiar seasons, hometown places, and daily anchors.',
      icon: Icons.wb_sunny_outlined,
      accentColor: AppColors.domainOrientation,
      priority: DomainSupportPriority.support,
    ),
    const CognitiveDomain(
      type: CognitiveDomainType.visuospatial,
      formalName: 'Visuospatial Skills',
      patientFriendlyName: 'Explore & Match',
      description: 'Recognizing traditional patterns, colors, shapes, and spatial harmony.',
      icon: Icons.extension_outlined,
      accentColor: AppColors.domainVisuospatial,
      priority: DomainSupportPriority.maintain,
    ),
  ];
}
