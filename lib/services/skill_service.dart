import '../models/skill.dart';
import 'local_store.dart';

class SkillService {
  final _store = LocalStore.instance;

  Stream<List<Skill>> watchMine(String uid) => _store.watch(
        () =>
            _store.skills.values.where((skill) => skill.ownerId == uid).toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );

  Stream<List<Skill>> watchDiscover() => _store.watch(
        () => _store.skills.values.where((skill) => skill.active).toList(),
      );

  Future<void> save({
    String? id,
    required String title,
    required String description,
    required String category,
    required String ownerId,
  }) async {
    final validation = Skill.validate(
      title: title,
      description: description,
      category: category,
    );
    if (validation != null) throw ArgumentError(validation);
    final profile = _store.profiles[ownerId];
    if (profile == null) throw StateError('Profile is unavailable.');
    final now = DateTime.now();
    final existing = id == null ? null : _store.skills[id];
    if (id != null && existing?.ownerId != ownerId) {
      throw StateError('This skill is no longer available.');
    }
    final skillId = id ?? _newId();
    _store.skills[skillId] = Skill(
      id: skillId,
      title: title.trim(),
      description: description.trim(),
      category: category,
      ownerId: ownerId,
      ownerName: profile.name,
      active: true,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    _store.notifyChanged();
  }

  Future<void> delete(String id) async {
    final skill = _store.skills.remove(id);
    if (skill == null) return;
    for (final entry in _store.requests.entries.toList()) {
      final request = entry.value;
      if (request.skillId == id && request.status == 'pending') {
        _store.requests[entry.key] = request.copyWith(
          status: 'declined',
          updatedAt: DateTime.now(),
        );
      }
    }
    _store.notifyChanged();
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();
}
