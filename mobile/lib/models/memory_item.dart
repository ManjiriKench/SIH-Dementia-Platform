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
}
