enum SyncStatus { synced, pendingOffline, syncFailed }

class CaregiverFeedback {
  final String id;
  final String sessionId;
  final String patientId;
  final DateTime timestamp;
  
  // Quick observations
  final List<String> observationTags; // calm, engaged, tired, anxious, irritated, quiet, withdrawn
  final String comfortRating;         // 'yes', 'somewhat', 'no'
  final String? whatHelped;
  
  // Voice note & transcription
  final String? voiceNoteUri;
  final String? transcriptionText;
  final bool hasAudioAttachment;
  
  // Content sentiment
  final bool? enjoyedMusicOrMemory;
  final String recommendationPreference; // 'keep_similar', 'gentler', 'more_music', 'more_together'

  // Offline queue state
  final SyncStatus syncStatus;

  const CaregiverFeedback({
    required this.id,
    required this.sessionId,
    required this.patientId,
    required this.timestamp,
    required this.observationTags,
    this.comfortRating = 'yes',
    this.whatHelped,
    this.voiceNoteUri,
    this.transcriptionText,
    this.hasAudioAttachment = false,
    this.enjoyedMusicOrMemory = true,
    this.recommendationPreference = 'keep_similar',
    this.syncStatus = SyncStatus.synced,
  });

  CaregiverFeedback copyWith({
    String? id,
    String? sessionId,
    String? patientId,
    DateTime? timestamp,
    List<String>? observationTags,
    String? comfortRating,
    String? whatHelped,
    String? voiceNoteUri,
    String? transcriptionText,
    bool? hasAudioAttachment,
    bool? enjoyedMusicOrMemory,
    String? recommendationPreference,
    SyncStatus? syncStatus,
  }) {
    return CaregiverFeedback(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      patientId: patientId ?? this.patientId,
      timestamp: timestamp ?? this.timestamp,
      observationTags: observationTags ?? this.observationTags,
      comfortRating: comfortRating ?? this.comfortRating,
      whatHelped: whatHelped ?? this.whatHelped,
      voiceNoteUri: voiceNoteUri ?? this.voiceNoteUri,
      transcriptionText: transcriptionText ?? this.transcriptionText,
      hasAudioAttachment: hasAudioAttachment ?? this.hasAudioAttachment,
      enjoyedMusicOrMemory: enjoyedMusicOrMemory ?? this.enjoyedMusicOrMemory,
      recommendationPreference: recommendationPreference ?? this.recommendationPreference,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
