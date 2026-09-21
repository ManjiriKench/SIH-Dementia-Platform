import 'package:flutter/foundation.dart';

/// Extracted profile keywords from a voice or typed response.
class ProfileKeywords {
  final String? extractedName;
  final String? extractedAgeRange;
  final String? extractedHometown;
  final List<String> musicGenres;
  final List<String> foods;
  final List<String> routines;
  final List<String> moodTags;
  final String? doctorAdvice;
  final String? rawText;

  const ProfileKeywords({
    this.extractedName,
    this.extractedAgeRange,
    this.extractedHometown,
    this.musicGenres = const [],
    this.foods = const [],
    this.routines = const [],
    this.moodTags = const [],
    this.doctorAdvice,
    this.rawText,
  });

  bool get isEmpty =>
      extractedName == null &&
      extractedAgeRange == null &&
      extractedHometown == null &&
      musicGenres.isEmpty &&
      foods.isEmpty &&
      routines.isEmpty &&
      moodTags.isEmpty &&
      doctorAdvice == null;

  ProfileKeywords mergeWith(ProfileKeywords other) {
    return ProfileKeywords(
      extractedName: other.extractedName ?? extractedName,
      extractedAgeRange: other.extractedAgeRange ?? extractedAgeRange,
      extractedHometown: other.extractedHometown ?? extractedHometown,
      musicGenres: {...musicGenres, ...other.musicGenres}.toList(),
      foods: {...foods, ...other.foods}.toList(),
      routines: {...routines, ...other.routines}.toList(),
      moodTags: {...moodTags, ...other.moodTags}.toList(),
      doctorAdvice: other.doctorAdvice ?? doctorAdvice,
      rawText: [if (rawText != null) rawText!, if (other.rawText != null) other.rawText!].join(' '),
    );
  }
}

enum ProfileQuestion { generalInfo, abilitiesPrefs, routinesMeds }

/// Offline NLP keyword extractor using Dart regex + cultural vocabulary dictionaries.
class NlpKeywordExtractor {
  NlpKeywordExtractor._();

  static const List<String> _musicKeywords = [
    'borgeet', 'bihu', 'rabindra', 'rabindranath', 'sangeet', 'flute',
    'hindi', 'classical', 'devotional', 'bhajan', 'ghazal', 'folk',
    'assamese', 'bengali', 'carnatic', 'hindustani', 'old songs',
    'bollywood', 'filmi', 'instrumental', 'radio', 'melodies',
  ];

  static const Map<String, String> _musicNormalized = {
    'borgeet': 'Borgeet Flute', 'bihu': 'Bihu Folk Melodies',
    'rabindra': 'Rabindra Sangeet', 'sangeet': 'Rabindra Sangeet',
    'rabindranath': 'Rabindra Sangeet', 'flute': 'Borgeet Flute',
    'hindi': 'Old Hindi Classics', 'old songs': 'Old Hindi Classics',
    'bollywood': 'Old Hindi Classics', 'filmi': 'Old Hindi Classics',
    'classical': 'Hindustani Classical', 'hindustani': 'Hindustani Classical',
    'carnatic': 'Carnatic Classical', 'devotional': 'Devotional Bhajans',
    'bhajan': 'Devotional Bhajans', 'ghazal': 'Ghazals',
    'folk': 'Bihu Folk Melodies', 'assamese': 'Bihu Folk Melodies',
    'bengali': 'Rabindra Sangeet', 'radio': 'Old Hindi Classics',
    'instrumental': 'Flute & Instrumental',
  };

  static const List<String> _foodKeywords = [
    'pitha', 'laru', 'masor tenga', 'masor', 'tenga', 'dal', 'rice',
    'chai', 'tea', 'assam tea', 'khichdi', 'fish', 'biryani',
    'sandesh', 'rasgulla', 'payasam', 'kheer', 'ladoo',
  ];

  static const Map<String, String> _foodNormalized = {
    'pitha': 'Pitha & Laru', 'laru': 'Pitha & Laru',
    'masor': 'Masor Tenga', 'tenga': 'Masor Tenga', 'masor tenga': 'Masor Tenga',
    'chai': 'Assam Chai', 'tea': 'Assam Chai', 'assam tea': 'Assam Chai',
    'fish': 'Fish Curry', 'biryani': 'Biryani',
    'kheer': 'Kheer & Payasam', 'payasam': 'Kheer & Payasam',
    'ladoo': 'Ladoo & Sweets', 'sandesh': 'Bengali Sweets', 'rasgulla': 'Bengali Sweets',
    'rice': 'Rice & Dal', 'dal': 'Rice & Dal',
  };

  static const List<String> _routineKeywords = [
    'morning', 'evening', 'afternoon', 'night', 'prayer', 'namaz', 'puja',
    'walk', 'garden', 'veranda', 'tea', 'breakfast', 'lunch', 'dinner',
    'radio', 'news', 'nap', 'rest', 'sleep', 'music', 'reading',
    'family', 'children', 'grandchildren', 'call', 'phone',
  ];

  static const Map<String, String> _routineNormalized = {
    'morning tea': 'Morning Assam tea on veranda',
    'morning': 'Morning routine', 'evening': 'Evening family time',
    'prayer': 'Evening family prayer', 'puja': 'Morning puja',
    'namaz': 'Daily namaz', 'walk': 'Morning garden walk',
    'garden': 'Garden time', 'veranda': 'Veranda relaxation',
    'nap': 'Afternoon quiet rest', 'rest': 'Afternoon quiet rest',
    'radio': 'Listening to morning radio', 'news': 'Watching evening news',
    'family': 'Evening family gathering', 'grandchildren': 'Time with grandchildren',
  };

  static const Map<String, List<String>> _moodKeywords = {
    'calm': ['calm', 'peaceful', 'quiet', 'relaxed', 'gentle', 'soft'],
    'engaged': ['engaged', 'interested', 'curious', 'alert', 'active', 'responsive'],
    'anxious': ['anxious', 'worried', 'nervous', 'restless', 'agitated', 'stressed'],
    'tired': ['tired', 'fatigue', 'exhausted', 'sleepy', 'drowsy', 'slow'],
  };

  static const List<String> _hometownKeywords = [
    'tezpur', 'guwahati', 'jorhat', 'dibrugarh', 'silchar',
    'shillong', 'kolkata', 'calcutta', 'delhi', 'mumbai',
    'chennai', 'bangalore', 'hyderabad', 'jaipur', 'pune',
    'assam', 'bengal', 'meghalaya', 'tripura', 'brahmaputra', 'majuli',
  ];

  static ProfileKeywords extract(String text, {ProfileQuestion question = ProfileQuestion.generalInfo}) {
    if (text.trim().isEmpty) return const ProfileKeywords();
    final lower = text.toLowerCase().trim();
    debugPrint('[NLP] Extracting from: "$lower"');

    return ProfileKeywords(
      extractedName: _extractName(lower, text),
      extractedAgeRange: _extractAgeRange(lower),
      extractedHometown: _extractHometown(lower),
      musicGenres: (question == ProfileQuestion.abilitiesPrefs || question == ProfileQuestion.generalInfo)
          ? _extractMusic(lower) : [],
      foods: question == ProfileQuestion.abilitiesPrefs ? _extractFoods(lower) : [],
      routines: (question == ProfileQuestion.abilitiesPrefs || question == ProfileQuestion.routinesMeds)
          ? _extractRoutines(lower) : [],
      moodTags: _extractMoods(lower),
      doctorAdvice: question == ProfileQuestion.routinesMeds ? _extractDoctorAdvice(text) : null,
      rawText: text,
    );
  }

  static String? _extractName(String lower, String originalText) {
    final patterns = [
      RegExp(r'(?:name is|called|her name is|his name is|known as|they call (?:her|him))\s+([A-Z][a-z]+(?: [A-Z][a-z]+)?)', caseSensitive: false),
      RegExp(r'^([A-Z][a-z]+(?: [A-Z][a-z]+)+)\b'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(originalText);
      if (m != null && m.groupCount >= 1) {
        final n = m.group(1)?.trim();
        if (n != null && n.length >= 2 && n.length <= 40) return n;
      }
    }
    return null;
  }

  static String? _extractAgeRange(String lower) {
    final numMatch = RegExp(r'\b(\d{2})\b').firstMatch(lower);
    if (numMatch != null) {
      final age = int.tryParse(numMatch.group(1) ?? '');
      if (age != null) {
        if (age >= 60 && age <= 69) return '60-69 years';
        if (age >= 70 && age <= 79) return '70-79 years';
        if (age >= 80 && age <= 89) return '80-89 years';
        if (age >= 90) return '90+ years';
      }
    }
    if (lower.contains('seventy') || lower.contains('seventi')) return '70-79 years';
    if (lower.contains('sixty') || lower.contains('sixti')) return '60-69 years';
    if (lower.contains('eighty') || lower.contains('eighti')) return '80-89 years';
    if (lower.contains('ninety') || lower.contains('nineti')) return '90+ years';
    return null;
  }

  static String? _extractHometown(String lower) {
    for (final place in _hometownKeywords) {
      if (lower.contains(place)) {
        return place.split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
      }
    }
    return null;
  }

  static List<String> _extractMusic(String lower) {
    final found = <String>{};
    for (final k in _musicKeywords) {
      if (lower.contains(k)) {
        final n = _musicNormalized[k];
        if (n != null) found.add(n);
      }
    }
    return found.toList();
  }

  static List<String> _extractFoods(String lower) {
    final found = <String>{};
    for (final k in _foodKeywords) {
      if (lower.contains(k)) {
        final n = _foodNormalized[k];
        if (n != null) found.add(n);
      }
    }
    return found.toList();
  }

  static List<String> _extractRoutines(String lower) {
    final found = <String>{};
    for (final entry in _routineNormalized.entries) {
      if (entry.key.contains(' ') && lower.contains(entry.key)) found.add(entry.value);
    }
    for (final k in _routineKeywords) {
      if (lower.contains(k) && !k.contains(' ')) {
        final n = _routineNormalized[k];
        if (n != null && !found.any((r) => r.startsWith(n.split(' ').first))) found.add(n);
      }
    }
    return found.take(4).toList();
  }

  static List<String> _extractMoods(String lower) {
    final found = <String>{};
    for (final entry in _moodKeywords.entries) {
      for (final k in entry.value) {
        if (lower.contains(k)) { found.add(entry.key); break; }
      }
    }
    return found.toList();
  }

  static String? _extractDoctorAdvice(String text) {
    final lower = text.toLowerCase();
    final terms = ['doctor', 'physician', 'avoid', 'medication', 'medicine', 'exercise',
      'walk', 'hydration', 'water', 'rest', 'diet', 'pressure', 'sugar', 'diabetes',
      'heart', 'tablet', 'pill'];
    if (terms.any((t) => lower.contains(t)) && text.trim().length > 10) return text.trim();
    return null;
  }

  static ProfileKeywords mergeAll(List<ProfileKeywords> extractions) {
    if (extractions.isEmpty) return const ProfileKeywords();
    return extractions.reduce((a, b) => a.mergeWith(b));
  }
}
