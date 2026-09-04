import 'package:flutter/foundation.dart';
import '../models/memory_item.dart';
import 'mock_data_repository.dart';

/// Service managing the caregiver's curated memory vault.
/// Enforces caregiver consent and approval before exposing personal media to the patient.
class MemoryService extends ChangeNotifier {
  static final MemoryService instance = MemoryService._internal();
  MemoryService._internal();

  final List<MemoryItem> _memories = [];
  bool _isInitialized = false;

  List<MemoryItem> get memories => List.unmodifiable(_memories);

  void initialize() {
    if (!_isInitialized) {
      _memories.addAll(MockDataRepository.getSampleMemories());
      _isInitialized = true;
      notifyListeners();
    }
  }

  List<MemoryItem> getMemoriesByType(MemoryType type) {
    initialize();
    return _memories.where((m) => m.type == type).toList();
  }

  List<MemoryItem> getApprovedMemoriesForPatient() {
    initialize();
    return _memories.where((m) => m.isCaregiverApproved).toList();
  }

  void addMemory(MemoryItem item) {
    initialize();
    _memories.insert(0, item);
    notifyListeners();
  }

  void deleteMemory(String id) {
    _memories.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void toggleApproval(String id) {
    final index = _memories.indexWhere((m) => m.id == id);
    if (index != -1) {
      final existing = _memories[index];
      _memories[index] = MemoryItem(
        id: existing.id,
        title: existing.title,
        type: existing.type,
        relationOrContext: existing.relationOrContext,
        audioAssetPath: existing.audioAssetPath,
        iconOrImagePath: existing.iconOrImagePath,
        tags: existing.tags,
        allowedUsage: existing.allowedUsage,
        isCaregiverApproved: !existing.isCaregiverApproved,
        syncStatus: existing.syncStatus,
        dateAdded: existing.dateAdded,
      );
      notifyListeners();
    }
  }
}
