import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memory_item.dart';
import 'mock_data_repository.dart';

/// Service managing the caregiver's curated memory vault with offline local disk persistence.
/// Enforces caregiver consent and approval before exposing personal media to the patient.
class MemoryService extends ChangeNotifier {
  static final MemoryService instance = MemoryService._internal();
  MemoryService._internal();

  static const String _memoriesStorageKey = 'smriti_memory_vault_items';

  final List<MemoryItem> _memories = [];
  bool _isInitialized = false;

  List<MemoryItem> get memories => List.unmodifiable(_memories);

  void initialize() {
    if (!_isInitialized) {
      _memories.addAll(MockDataRepository.getSampleMemories());
      _isInitialized = true;
      loadFromDisk();
    }
  }

  /// Loads persisted memory items from local disk
  Future<void> loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_memoriesStorageKey);
      if (savedJson != null && savedJson.isNotEmpty) {
        final decoded = jsonDecode(savedJson) as List<dynamic>;
        _memories.clear();
        for (final item in decoded) {
          _memories.add(MemoryItem.fromJson(item as Map<String, dynamic>));
        }
        _isInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading memories from disk: $e');
    }
  }

  Future<void> _persistMemoriesToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = _memories.map((m) => m.toJson()).toList();
      await prefs.setString(_memoriesStorageKey, jsonEncode(listJson));
    } catch (e) {
      debugPrint('Error saving memories to disk: $e');
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
    _persistMemoriesToDisk();
  }

  void updateMemory(MemoryItem item) {
    initialize();
    final index = _memories.indexWhere((m) => m.id == item.id);
    if (index != -1) {
      _memories[index] = item;
      notifyListeners();
      _persistMemoriesToDisk();
    }
  }

  void deleteMemory(String id) {
    _memories.removeWhere((m) => m.id == id);
    notifyListeners();
    _persistMemoriesToDisk();
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
      _persistMemoriesToDisk();
    }
  }
}
