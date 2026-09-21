/// Medication data model for the caregiver care plan.
class Medication {
  final String id;
  final String name;
  final String dosage;
  final String timing;
  bool isTakenToday;
  final String? notes;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.timing,
    this.isTakenToday = false,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'dosage': dosage, 'timing': timing,
    'isTakenToday': isTakenToday, 'notes': notes,
  };

  factory Medication.fromJson(Map<String, dynamic> j) => Medication(
    id: j['id'] as String, name: j['name'] as String,
    dosage: j['dosage'] as String, timing: j['timing'] as String,
    isTakenToday: j['isTakenToday'] as bool? ?? false,
    notes: j['notes'] as String?,
  );

  Medication copyWith({String? name, String? dosage, String? timing, bool? isTakenToday, String? notes}) {
    return Medication(
      id: id, name: name ?? this.name, dosage: dosage ?? this.dosage,
      timing: timing ?? this.timing, isTakenToday: isTakenToday ?? this.isTakenToday,
      notes: notes ?? this.notes,
    );
  }
}
