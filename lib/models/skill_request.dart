class SkillRequest {
  const SkillRequest({
    required this.id,
    required this.skillId,
    required this.skillTitle,
    required this.requesterId,
    required this.requesterName,
    required this.ownerId,
    required this.ownerName,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  static const statuses = [
    'pending',
    'accepted',
    'declined',
    'cancelled',
    'completed',
  ];

  final String id;
  final String skillId;
  final String skillTitle;
  final String requesterId;
  final String requesterName;
  final String ownerId;
  final String ownerName;
  final String message;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory SkillRequest.fromMap(String id, Map<String, dynamic> map) =>
      SkillRequest(
        id: id,
        skillId: _requestString(map['skillId']),
        skillTitle: _requestString(map['skillTitle']),
        requesterId: _requestString(map['requesterId']),
        requesterName: _requestString(map['requesterName']),
        ownerId: _requestString(map['ownerId']),
        ownerName: _requestString(map['ownerName']),
        message: _requestString(map['message']),
        status: statuses.contains(map['status'])
            ? map['status'] as String
            : 'pending',
        createdAt: _requestDate(map['createdAt']),
        updatedAt: _requestDate(map['updatedAt']),
      );

  Map<String, dynamic> toMap() => {
        'skillId': skillId,
        'skillTitle': skillTitle,
        'requesterId': requesterId,
        'requesterName': requesterName,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'message': message,
        'status': status,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  SkillRequest copyWith({
    String? status,
    DateTime? updatedAt,
  }) =>
      SkillRequest(
        id: id,
        skillId: skillId,
        skillTitle: skillTitle,
        requesterId: requesterId,
        requesterName: requesterName,
        ownerId: ownerId,
        ownerName: ownerName,
        message: message,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  static bool canTransition(String from, String to, {required bool isOwner}) {
    if (from != 'pending') {
      return from == 'accepted' && to == 'completed' && !isOwner;
    }
    if (isOwner) return to == 'accepted' || to == 'declined';
    return to == 'cancelled';
  }
}

String _requestString(Object? value) => value is String ? value : '';

DateTime _requestDate(Object? value) {
  if (value is DateTime) return value;
  return DateTime.fromMillisecondsSinceEpoch(0);
}
