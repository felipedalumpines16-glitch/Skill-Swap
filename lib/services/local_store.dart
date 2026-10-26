import 'dart:async';

import '../models/skill.dart';
import '../models/skill_request.dart';
import '../models/student_profile.dart';

class LocalStore {
  LocalStore._();

  static final instance = LocalStore._();

  final profiles = <String, StudentProfile>{};
  final skills = <String, Skill>{};
  final requests = <String, SkillRequest>{};
  final _changes = StreamController<void>.broadcast(sync: true);

  Stream<T> watch<T>(T Function() read) {
    return Stream<T>.multi((sink) {
      sink.add(read());
      final subscription = _changes.stream.listen(
        (_) => sink.add(read()),
        onError: sink.addError,
      );
      sink.onCancel = subscription.cancel;
    });
  }

  void notifyChanged() => _changes.add(null);
}
