/// Doctor appointment data model for the caregiver care plan.
class Appointment {
  final String id;
  final String title;
  final String doctorName;
  final DateTime scheduledAt;
  final String? location;
  final String? notes;

  const Appointment({
    required this.id,
    required this.title,
    required this.doctorName,
    required this.scheduledAt,
    this.location,
    this.notes,
  });

  bool get isUpcoming => scheduledAt.isAfter(DateTime.now());

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'doctorName': doctorName,
    'scheduledAt': scheduledAt.toIso8601String(),
    'location': location, 'notes': notes,
  };

  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
    id: j['id'] as String, title: j['title'] as String,
    doctorName: j['doctorName'] as String,
    scheduledAt: DateTime.parse(j['scheduledAt'] as String),
    location: j['location'] as String?,
    notes: j['notes'] as String?,
  );
}
