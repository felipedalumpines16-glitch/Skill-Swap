import '../models/skill.dart';
import '../models/skill_request.dart';
import 'local_store.dart';

class RequestService {
  final _store = LocalStore.instance;

  Stream<List<SkillRequest>> watchIncoming(String uid) => _store.watch(
        () => _store.requests.values
            .where((request) => request.ownerId == uid)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );

  Stream<List<SkillRequest>> watchSent(String uid) => _store.watch(
        () => _store.requests.values
            .where((request) => request.requesterId == uid)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );

  Future<void> create({
    required Skill skill,
    required String requesterId,
    required String message,
  }) async {
    if (message.trim().length > 400) {
      throw ArgumentError('Message must be 400 characters or fewer.');
    }
    if (skill.ownerId == requesterId) {
      throw ArgumentError('You cannot request your own skill.');
    }
    final current = _store.skills[skill.id];
    if (current == null || !current.active) {
      throw ArgumentError('This skill is no longer available.');
    }
    if (_store.requests.values.any(
      (request) =>
          request.skillId == skill.id &&
          request.requesterId == requesterId &&
          (request.status == 'pending' || request.status == 'accepted'),
    )) {
      throw ArgumentError('You already have an active request for this skill.');
    }
    final profile = _store.profiles[requesterId];
    if (profile == null) throw StateError('Profile is unavailable.');
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    _store.requests[id] = SkillRequest(
      id: id,
      skillId: current.id,
      skillTitle: current.title,
      requesterId: requesterId,
      requesterName: profile.name,
      ownerId: current.ownerId,
      ownerName: current.ownerName,
      message: message.trim(),
      status: 'pending',
      createdAt: now,
      updatedAt: now,
    );
    _store.notifyChanged();
  }

  Future<void> transition(
    SkillRequest request,
    String nextStatus, {
    required String userId,
  }) async {
    final current = _store.requests[request.id];
    final isOwner = request.ownerId == userId;
    final isRequester = request.requesterId == userId;
    if (current == null ||
        (!isOwner && !isRequester) ||
        !SkillRequest.canTransition(
          current.status,
          nextStatus,
          isOwner: isOwner,
        )) {
      throw ArgumentError('You cannot perform that request action.');
    }
    _store.requests[request.id] = current.copyWith(
      status: nextStatus,
      updatedAt: DateTime.now(),
    );
    _store.notifyChanged();
  }
}
