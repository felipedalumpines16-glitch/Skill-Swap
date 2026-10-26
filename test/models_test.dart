import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/models/skill.dart';
import 'package:skillswap/models/skill_request.dart';
import 'package:skillswap/models/student_profile.dart';
import 'package:skillswap/services/auth_service.dart';
import 'package:skillswap/services/profile_service.dart';
import 'package:skillswap/services/request_service.dart';
import 'package:skillswap/services/skill_service.dart';
import 'package:skillswap/utils/auth_validators.dart';

void main() {
  group('AuthValidators', () {
    test('validates name, email, password, and confirmation', () {
      expect(AuthValidators.name('Jordan Student'), isNull);
      expect(AuthValidators.name('  '), isNotNull);
      expect(AuthValidators.name('a' * 101), isNotNull);
      expect(AuthValidators.email('student@example.com'), isNull);
      expect(AuthValidators.email('invalid'), isNotNull);
      expect(AuthValidators.password('longEnough'), isNull);
      expect(AuthValidators.password('short'), isNotNull);
      expect(
          AuthValidators.confirmPassword('longEnough', 'longEnough'), isNull);
      expect(
          AuthValidators.confirmPassword('different', 'longEnough'), isNotNull);
    });
  });

  group('StudentProfile', () {
    test('serializes and deserializes its profile fields and timestamps', () {
      final createdAt = DateTime.utc(2025, 1, 2);
      final profile = StudentProfile(
        uid: 'student-1',
        name: 'Taylor Student',
        email: 'taylor@example.com',
        course: 'Information Technology',
        bio: 'I enjoy learning.',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      final restored = StudentProfile.fromMap('student-1', profile.toMap());

      expect(restored.uid, 'student-1');
      expect(restored.name, 'Taylor Student');
      expect(restored.email, 'taylor@example.com');
      expect(restored.course, 'Information Technology');
      expect(restored.bio, 'I enjoy learning.');
      expect(restored.createdAt.toUtc(), createdAt.toUtc());
    });

    test('handles malformed optional fields without throwing', () {
      final profile = StudentProfile.fromMap('student-1', {'name': 42});
      expect(profile.name, '');
      expect(profile.bio, '');
      expect(profile.createdAt.millisecondsSinceEpoch, 0);
    });
  });

  group('Skill', () {
    test('validates title, description, and supported category', () {
      expect(
        Skill.validate(
          title: '  Dart basics ',
          description: 'Learn the fundamentals.',
          category: 'Programming',
        ),
        isNull,
      );
      expect(
        Skill.validate(title: '', description: 'Details', category: 'Other'),
        isNotNull,
      );
      expect(
        Skill.validate(
          title: 't' * 61,
          description: 'Details',
          category: 'Other',
        ),
        isNotNull,
      );
      expect(
        Skill.validate(
          title: 'Valid',
          description: 'd' * 401,
          category: 'Other',
        ),
        isNotNull,
      );
      expect(
        Skill.validate(
          title: 'Valid',
          description: 'Details',
          category: 'Unlisted',
        ),
        isNotNull,
      );
    });

    test('round-trips skill data and safely defaults malformed categories', () {
      final date = DateTime.utc(2025, 3, 1);
      final skill = Skill(
        id: 'skill-1',
        title: 'Dart basics',
        description: 'Learn the fundamentals.',
        category: 'Programming',
        ownerId: 'student-1',
        ownerName: 'Taylor',
        active: true,
        createdAt: date,
        updatedAt: date,
      );
      final restored = Skill.fromMap('skill-1', skill.toMap());
      expect(restored.title, skill.title);
      expect(restored.category, skill.category);
      expect(restored.ownerId, skill.ownerId);
      expect(restored.active, isTrue);
      expect(
        Skill.fromMap('skill-2', {'category': 'not a category'}).category,
        'Other',
      );
    });
  });

  group('SkillRequest', () {
    test('serializes request identity, message, status, and timestamps', () {
      final date = DateTime.utc(2025, 4, 1);
      final request = SkillRequest(
        id: 'request-1',
        skillId: 'skill-1',
        skillTitle: 'Dart basics',
        requesterId: 'student-2',
        requesterName: 'Jordan',
        ownerId: 'student-1',
        ownerName: 'Taylor',
        message: 'I would like to learn.',
        status: 'pending',
        createdAt: date,
        updatedAt: date,
      );
      final restored = SkillRequest.fromMap('request-1', request.toMap());
      expect(restored.requesterId, request.requesterId);
      expect(restored.ownerId, request.ownerId);
      expect(restored.message, request.message);
      expect(restored.status, 'pending');
      expect(restored.updatedAt.toUtc(), date.toUtc());
    });

    test('permits only participant actions for valid transitions', () {
      expect(
        SkillRequest.canTransition('pending', 'accepted', isOwner: true),
        isTrue,
      );
      expect(
        SkillRequest.canTransition('pending', 'declined', isOwner: true),
        isTrue,
      );
      expect(
        SkillRequest.canTransition('pending', 'cancelled', isOwner: false),
        isTrue,
      );
      expect(
        SkillRequest.canTransition('accepted', 'completed', isOwner: false),
        isTrue,
      );
      expect(
        SkillRequest.canTransition('pending', 'accepted', isOwner: false),
        isFalse,
      );
      expect(
        SkillRequest.canTransition('accepted', 'completed', isOwner: true),
        isFalse,
      );
      expect(
        SkillRequest.canTransition('declined', 'accepted', isOwner: true),
        isFalse,
      );
    });
  });

  test('offline demo supports separate accounts and request transitions',
      () async {
    final auth = AuthService.instance;
    final suffix = DateTime.now().microsecondsSinceEpoch;
    final ownerEmail = 'owner-$suffix@example.com';
    final learnerEmail = 'learner-$suffix@example.com';

    await auth.register(
      name: 'Skill Owner',
      email: ownerEmail,
      password: 'password1',
    );
    final owner = auth.currentUser!;
    await ProfileService().update(
      uid: owner.uid,
      email: owner.email,
      name: 'Skill Owner',
      course: 'Design',
      bio: '',
    );
    await SkillService().save(
      title: 'Poster design',
      description: 'Learn a simple poster layout.',
      category: 'Design',
      ownerId: owner.uid,
    );
    final skill = (await SkillService().watchMine(owner.uid).first).single;

    await auth.signOut();
    await auth.register(
      name: 'Skill Learner',
      email: learnerEmail,
      password: 'password2',
    );
    final learner = auth.currentUser!;
    final requests = RequestService();
    await requests.create(
      skill: skill,
      requesterId: learner.uid,
      message: 'Please teach me.',
    );
    final request = (await requests.watchSent(learner.uid).first).single;
    expect(request.status, 'pending');

    await auth.signOut();
    await auth.signIn(email: ownerEmail, password: 'password1');
    await requests.transition(
      request,
      'accepted',
      userId: owner.uid,
    );
    final accepted = (await requests.watchIncoming(owner.uid).first).single;
    expect(accepted.status, 'accepted');

    await auth.signOut();
    await auth.signIn(email: learnerEmail, password: 'password2');
    await requests.transition(
      accepted,
      'completed',
      userId: learner.uid,
    );
    expect(
      (await requests.watchSent(learner.uid).first).single.status,
      'completed',
    );
  });
}
