import 'dart:math';

/// Playable trial specification for Face-Name Recall.
class FaceRecallTrial {
  final String personId;
  final String photoUrl;
  final String correctName;
  final String relationship;
  final String? audioHint;
  final List<String> options;
  final int correctIndex;

  const FaceRecallTrial({
    required this.personId,
    required this.photoUrl,
    required this.correctName,
    required this.relationship,
    this.audioHint,
    required this.options,
    required this.correctIndex,
  });
}

/// Playable trial specification for Routine Sequencing.
class RoutineSequenceTrial {
  final int numSteps;
  final List<String> groundTruthOrder;
  final List<Map<String, dynamic>> shuffledCards;

  const RoutineSequenceTrial({
    required this.numSteps,
    required this.groundTruthOrder,
    required this.shuffledCards,
  });
}

/// Pure Dart Client-Side Procedural Compiler for Caregiver Personal Memory Bank.
///
/// Dynamically turns uploaded photos, family names, and daily routines into
/// playable game sessions on-device without internet access.
class MemoryGameCompiler {
  static final MemoryGameCompiler _instance = MemoryGameCompiler._internal();
  factory MemoryGameCompiler() => _instance;
  MemoryGameCompiler._internal();

  final Random _rng = Random();

  static const List<String> _syntheticNames = [
    'Meera', 'Arup', 'Nagen', 'Pranita', 'Bonti', 'Bhaben',
    'Devi', 'Gautam', 'Jyoti', 'Hitesh', 'Ananya', 'Ramen'
  ];

  static const List<Map<String, dynamic>> _fallbackRoutines = [
    {'step': 1, 'task': 'Wake up & rinse face', 'icon': 'sunrise'},
    {'step': 2, 'task': 'Morning Assam tea', 'icon': 'cup'},
    {'step': 3, 'task': 'Blood pressure medicine', 'icon': 'pill'},
    {'step': 4, 'task': 'Water courtyard plants', 'icon': 'plant'},
    {'step': 5, 'task': 'Afternoon gentle rest', 'icon': 'bed'},
  ];

  /// Compiles a Face-Name Recall trial round.
  FaceRecallTrial compileFaceRecallTrial(List<Map<String, dynamic>> familiarPeople, {int difficulty = 2}) {
    final List<Map<String, dynamic>> pool = familiarPeople.isNotEmpty
        ? familiarPeople
        : [
            {
              'person_id': 'p_meera',
              'name': 'Meera',
              'relation': 'Granddaughter',
              'photo_url': 'assets/images/default_granddaughter.jpg',
            }
          ];

    final target = pool[_rng.nextInt(pool.length)];
    final String correctName = target['name'] ?? 'Meera';
    final int numOptions = difficulty <= 1 ? 2 : (difficulty == 2 ? 3 : 4);

    final List<String> distractors = [];
    for (final p in pool) {
      final name = p['name'] as String?;
      if (name != null && name != correctName && !distractors.contains(name)) {
        distractors.add(name);
      }
    }

    // Backfill from synthetic cultural names if needed
    final shuffledSynthetic = List<String>.from(_syntheticNames)..shuffle(_rng);
    for (final syn in shuffledSynthetic) {
      if (distractors.length >= numOptions - 1) break;
      if (syn != correctName && !distractors.contains(syn)) {
        distractors.add(syn);
      }
    }

    final List<String> options = List<String>.from(distractors.take(numOptions - 1))..add(correctName);
    options.shuffle(_rng);

    return FaceRecallTrial(
      personId: target['person_id'] ?? 'p1',
      photoUrl: target['photo_url'] ?? '',
      correctName: correctName,
      relationship: target['relation'] ?? 'Family',
      audioHint: target['audio_hint'],
      options: options,
      correctIndex: options.indexOf(correctName),
    );
  }

  /// Compiles a Routine Sequencing trial round.
  RoutineSequenceTrial compileRoutineSequenceTrial(List<Map<String, dynamic>>? dailyRoutines, {int difficulty = 2}) {
    final List<Map<String, dynamic>> pool = (dailyRoutines != null && dailyRoutines.length >= 3)
        ? dailyRoutines
        : _fallbackRoutines;

    final int numSteps = min(difficulty <= 2 ? 3 : (difficulty <= 4 ? 4 : 5), pool.length);
    final selectedSteps = pool.take(numSteps).toList()
      ..sort((a, b) => ((a['step'] as int?) ?? 1).compareTo((b['step'] as int?) ?? 1));

    final groundTruth = selectedSteps.map((s) => s['task'] as String).toList();
    final shuffled = List<Map<String, dynamic>>.from(selectedSteps)..shuffle(_rng);

    return RoutineSequenceTrial(
      numSteps: numSteps,
      groundTruthOrder: groundTruth,
      shuffledCards: shuffled,
    );
  }
}
