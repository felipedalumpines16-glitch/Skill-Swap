class Skill {
  const Skill({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.ownerId,
    required this.ownerName,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  static const categories = [
    'Programming',
    'Design',
    'Networking',
    'School',
    'Creative',
    'Other',
  ];

  final String id;
  final String title;
  final String description;
  final String category;
  final String ownerId;
  final String ownerName;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Skill.fromMap(String id, Map<String, dynamic> map) => Skill(
        id: id,
        title: _asString(map['title']),
        description: _asString(map['description']),
        category: Skill.categories.contains(map['category'])
            ? map['category'] as String
            : 'Other',
        ownerId: _asString(map['ownerId']),
        ownerName: _asString(map['ownerName']),
        active: map['active'] == true,
        createdAt: _asDate(map['createdAt']),
        updatedAt: _asDate(map['updatedAt']),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'active': active,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  static String? validate({
    required String title,
    required String description,
    required String category,
  }) {
    if (title.trim().isEmpty || title.trim().length > 60) {
      return 'Enter a title of 1 to 60 characters.';
    }
    if (description.trim().isEmpty || description.trim().length > 400) {
      return 'Enter a description of 1 to 400 characters.';
    }
    if (!categories.contains(category)) return 'Choose a valid category.';
    return null;
  }
}

String _asString(Object? value) => value is String ? value : '';

DateTime _asDate(Object? value) {
  if (value is DateTime) return value;
  return DateTime.fromMillisecondsSinceEpoch(0);
}
