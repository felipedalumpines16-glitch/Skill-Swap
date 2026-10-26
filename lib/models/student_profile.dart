class StudentProfile {
  const StudentProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.course,
    required this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uid;
  final String name;
  final String email;
  final String course;
  final String bio;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory StudentProfile.fromMap(String uid, Map<String, dynamic> map) {
    return StudentProfile(
      uid: uid,
      name: _string(map['name']),
      email: _string(map['email']),
      course: _string(map['course']),
      bio: _string(map['bio']),
      createdAt: _date(map['createdAt']),
      updatedAt: _date(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'course': course,
        'bio': bio,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

String _string(Object? value) => value is String ? value : '';

DateTime _date(Object? value) {
  if (value is DateTime) return value;
  return DateTime.fromMillisecondsSinceEpoch(0);
}
