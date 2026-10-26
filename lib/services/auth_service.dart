import 'dart:async';
import 'dart:math';

import '../models/app_user.dart';
import '../models/student_profile.dart';
import 'local_store.dart';

class AuthService {
  AuthService._();

  static final instance = AuthService._();

  final _store = LocalStore.instance;
  final _accounts = <String, _LocalAccount>{};
  final _changes = StreamController<AppUser?>.broadcast(sync: true);
  AppUser? currentUser;

  Stream<AppUser?> get authChanges => Stream<AppUser?>.multi((sink) {
        sink.add(currentUser);
        final subscription = _changes.stream.listen(
          sink.add,
          onError: sink.addError,
        );
        sink.onCancel = subscription.cancel;
      });

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (_accounts.containsKey(normalizedEmail)) {
      throw StateError('An account already exists for this email.');
    }

    final user = AppUser(
      uid: _newId(),
      email: normalizedEmail,
      displayName: name.trim(),
    );
    _accounts[normalizedEmail] = _LocalAccount(user, password);
    final now = DateTime.now();
    _store.profiles[user.uid] = StudentProfile(
      uid: user.uid,
      name: user.displayName,
      email: user.email,
      course: '',
      bio: '',
      createdAt: now,
      updatedAt: now,
    );
    currentUser = user;
    _changes.add(user);
    _store.notifyChanged();
  }

  Future<void> signIn({required String email, required String password}) async {
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw StateError('Email or password is incorrect.');
    }
    currentUser = account.user;
    _changes.add(currentUser);
  }

  Future<void> sendPasswordReset(String email) async {
    if (email.trim().isEmpty) {
      throw ArgumentError('Enter an email address first.');
    }
    throw UnsupportedError(
      'Password reset is unavailable in offline demo mode.',
    );
  }

  Future<void> signOut() async {
    currentUser = null;
    _changes.add(null);
  }

  String _newId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}';
}

class _LocalAccount {
  const _LocalAccount(this.user, this.password);

  final AppUser user;
  final String password;
}
