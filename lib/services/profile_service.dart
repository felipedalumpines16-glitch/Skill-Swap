import '../models/student_profile.dart';
import 'local_store.dart';

class ProfileService {
  final _store = LocalStore.instance;

  Stream<StudentProfile?> watch(String uid) =>
      _store.watch(() => _store.profiles[uid]);

  Future<void> update({
    required String uid,
    required String email,
    required String name,
    required String course,
    required String bio,
  }) async {
    if (name.trim().isEmpty || name.trim().length > 100) {
      throw ArgumentError('Name must be 1 to 100 characters.');
    }
    if (course.trim().length > 100) {
      throw ArgumentError('Course must be 100 characters or fewer.');
    }
    if (bio.trim().length > 500) {
      throw ArgumentError('Biography must be 500 characters or fewer.');
    }
    final previous = _store.profiles[uid];
    if (previous == null) throw StateError('Profile is unavailable.');
    _store.profiles[uid] = StudentProfile(
      uid: uid,
      name: name.trim(),
      email: email,
      course: course.trim(),
      bio: bio.trim(),
      createdAt: previous.createdAt,
      updatedAt: DateTime.now(),
    );
    _store.notifyChanged();
  }
}
