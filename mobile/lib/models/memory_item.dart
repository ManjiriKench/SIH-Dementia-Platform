import 'caregiver_feedback.dart';

enum MemoryType {
  photo,
  person,
  place,
  music,
  story,
  object,
  conversationPrompt,
}

class MemoryItem {
  final String id;
  final String title;
  final MemoryType type;
  final String? relationOrContext; // e.g. "Eldest daughter", "Childhood home in Tezpur", "Favourite tea stall"
  final String? audioAssetPath;
  final String? iconOrImagePath;
  final List<String> tags;
  final List<String> allowedUsage; // e.g. ['recognition', 'conversation', 'music_together']
  final bool isCaregiverApproved;
  final SyncStatus syncStatus;
  final DateTime dateAdded;

  const MemoryItem({
    required this.id,
    required this.title,
    required this.type,
    this.relationOrContext,
    this.audioAssetPath,
    this.iconOrImagePath,
    this.tags = const ['Family', 'Assam'],
    this.allowedUsage = const ['recognition', 'conversation'],
    this.isCaregiverApproved = true,
    this.syncStatus = SyncStatus.synced,
    required this.dateAdded,
  });

  String get typeLabel {
    switch (type) {
      case MemoryType.photo:
        return 'Family Photo';
      case MemoryType.person:
        return 'Cherished Person';
      case MemoryType.place:
        return 'Familiar Place';
      case MemoryType.music:
        return 'Favourite Song';
      case MemoryType.story:
        return 'Family Memory';
      case MemoryType.object:
        return 'Beloved Object';
      case MemoryType.conversationPrompt:
        return 'Conversation Prompt';
    }
  }

  List<String> get activityUsageLabels {
    switch (type) {
      case MemoryType.photo:
      case MemoryType.person:
        return ['Family Match & Tell', 'Look & Talk', 'Story from Photo'];
      case MemoryType.place:
        return ['Look & Talk', 'Story from Photo', 'Orientation Reminiscing'];
      case MemoryType.music:
        return ['Music & Memory', 'Listen & Remember'];
      case MemoryType.story:
      case MemoryType.conversationPrompt:
        return ['Look & Talk', 'Together Conversation', 'Story from Photo'];
      case MemoryType.object:
        return ['Familiar Object Match', 'Remember & Recall'];
    }
  }

  MemoryItem copyWith({
    String? title,
    MemoryType? type,
    String? relationOrContext,
    String? audioAssetPath,
    String? iconOrImagePath,
    List<String>? tags,
    List<String>? allowedUsage,
    bool? isCaregiverApproved,
    SyncStatus? syncStatus,
  }) {
    return MemoryItem(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      relationOrContext: relationOrContext ?? this.relationOrContext,
      audioAssetPath: audioAssetPath ?? this.audioAssetPath,
      iconOrImagePath: iconOrImagePath ?? this.iconOrImagePath,
      tags: tags ?? this.tags,
      allowedUsage: allowedUsage ?? this.allowedUsage,
      isCaregiverApproved: isCaregiverApproved ?? this.isCaregiverApproved,
      syncStatus: syncStatus ?? this.syncStatus,
      dateAdded: dateAdded,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.name,
    'relationOrContext': relationOrContext,
    'audioAssetPath': audioAssetPath,
    'iconOrImagePath': iconOrImagePath,
    'tags': tags,
    'allowedUsage': allowedUsage,
    'isCaregiverApproved': isCaregiverApproved,
    'syncStatus': syncStatus.name,
    'dateAdded': dateAdded.toIso8601String(),
  };

  factory MemoryItem.fromJson(Map<String, dynamic> json) {
    return MemoryItem(
      id: json['id'] as String? ?? 'mem_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Family Memory',
      type: MemoryType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => MemoryType.photo,
      ),
      relationOrContext: json['relationOrContext'] as String?,
      audioAssetPath: json['audioAssetPath'] as String?,
      iconOrImagePath: json['iconOrImagePath'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['Family'],
      allowedUsage: (json['allowedUsage'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const ['recognition', 'conversation'],
      isCaregiverApproved: json['isCaregiverApproved'] as bool? ?? true,
      syncStatus: SyncStatus.values.firstWhere(
        (s) => s.name == json['syncStatus'],
        orElse: () => SyncStatus.synced,
      ),
      dateAdded: json['dateAdded'] != null
          ? DateTime.tryParse(json['dateAdded'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
