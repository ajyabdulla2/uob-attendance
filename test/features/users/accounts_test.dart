import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uob_attendance/features/auth/domain/app_user.dart';
import 'package:uob_attendance/features/auth/domain/permissions.dart';
import 'package:uob_attendance/features/users/data/accounts_repository.dart';
import 'package:uob_attendance/features/users/domain/account_form.dart';

const admin = 'admin@uob.iq';

void main() {
  group('AccountForm', () {
    test('drops stage scopes unless stage manager, keeps them in stage order, trims text', () {
      const teacher = AppUser(email: 't@uob.iq', name: ' علي ', stageScopes: ['3-morning']);
      expect(AccountForm.normalize(teacher).stageScopes, isEmpty);
      expect(AccountForm.normalize(teacher).name, 'علي');

      final manager = AccountForm.normalize(const AppUser(
        email: 'm@uob.iq',
        name: 'م',
        roles: {UserRole.stageManager},
        stageScopes: ['4-evening', '1-morning', 'bogus'],
      ));
      expect(manager.stageScopes, ['1-morning', '4-evening']);
    });

    test('reports every missing piece', () {
      expect(AccountForm.validate(const AppUser(email: 'ok@uob.iq', name: 'س')), isEmpty);
      expect(
        AccountForm.validate(const AppUser(email: 'nope', name: ' ', roles: {})),
        [AccountIssue.invalidEmail, AccountIssue.nameRequired, AccountIssue.noRole],
      );
      expect(
        AccountForm.validate(const AppUser(email: 'm@uob.iq', name: 'م', roles: {UserRole.stageManager})),
        [AccountIssue.noStageScope],
      );
    });
  });

  test('Permissions.canChangeAccessOf: never one\'s own account; deputies never admins', () {
    const superAdmin = AppUser(email: admin, name: 'م', roles: {UserRole.superAdmin});
    const deputy = AppUser(email: 'd@uob.iq', name: 'د', roles: {UserRole.deputyAdmin});
    const teacher = AppUser(email: 't@uob.iq', name: 'ت');
    expect(const Permissions(superAdmin).canChangeAccessOf(superAdmin), isFalse);
    expect(const Permissions(superAdmin).canChangeAccessOf(deputy), isTrue);
    expect(const Permissions(deputy).canChangeAccessOf(teacher), isTrue);
    expect(const Permissions(deputy).canChangeAccessOf(superAdmin), isFalse);
    expect(const Permissions(teacher).canChangeAccessOf(teacher), isFalse);
  });

  group('AccountsRepository', () {
    late FakeFirebaseFirestore db;
    late AccountsRepository repo;

    setUp(() {
      db = FakeFirebaseFirestore();
      repo = AccountsRepository(db);
    });

    Future<Map<String, dynamic>?> data(String path) async => (await db.doc(path).get()).data();
    Future<List<Map<String, dynamic>>> audit() async =>
        [for (final d in (await db.collection('auditLog').get()).docs) d.data()];

    test('join request: submit (lower-cased id), watch, cancel', () async {
      expect(await repo.watchRequest('New@uob.iq').first, isNull);
      await repo.submitRequest(email: 'New@uob.iq', name: ' جديد ', note: ' مدرس ');
      final mine = await repo.watchRequest('new@uob.iq').first;
      expect(mine!.email, 'new@uob.iq');
      expect(mine.name, 'جديد');
      expect(mine.note, 'مدرس');
      expect((await repo.watchRequests().first).single.email, 'new@uob.iq');
      await repo.cancelRequest('NEW@uob.iq');
      expect(await repo.watchRequest('new@uob.iq').first, isNull);
    });

    test('approve creates the account, removes the request and audits', () async {
      await repo.submitRequest(email: 'new@uob.iq', name: 'جديد');
      await repo.approve(
        const AppUser(email: 'new@uob.iq', name: 'جديد', roles: {UserRole.teacher, UserRole.stageManager}, stageScopes: ['2-evening']),
        actor: admin,
      );
      final user = await data('users/new@uob.iq');
      expect(user!['roles'], ['stageManager', 'teacher']);
      expect(user['stageScopes'], ['2-evening']);
      expect(user['active'], isTrue);
      expect(user['updatedBy'], admin);
      expect(await data('accessRequests/new@uob.iq'), isNull);
      expect((await audit()).single, containsPair('action', 'user.approve'));
    });

    test('approve never overwrites an account created meanwhile (e.g. by import)', () async {
      await db.doc('users/new@uob.iq').set(const AppUser(email: 'new@uob.iq', name: 'من الاستيراد', title: 'مدرس').toMap());
      await repo.submitRequest(email: 'new@uob.iq', name: 'جديد');
      await repo.approve(const AppUser(email: 'new@uob.iq', name: 'جديد'), actor: admin);
      expect((await data('users/new@uob.iq'))!['name'], 'من الاستيراد');
      expect(await data('accessRequests/new@uob.iq'), isNull);
    });

    test('reject removes the request and audits', () async {
      await repo.submitRequest(email: 'new@uob.iq', name: 'جديد');
      final request = (await repo.watchRequests().first).single;
      await repo.reject(request, actor: admin);
      expect(await data('accessRequests/new@uob.iq'), isNull);
      expect((await audit()).single, containsPair('action', 'user.reject'));
    });

    test('create refuses an existing e-mail instead of overwriting it', () async {
      await repo.create(const AppUser(email: 'a@uob.iq', name: 'أ'), actor: admin);
      expect((await data('users/a@uob.iq'))!['roles'], ['teacher']);
      await expectLater(
        repo.create(const AppUser(email: 'a@uob.iq', name: 'آخر', roles: {UserRole.superAdmin}), actor: admin),
        throwsA(isA<AccountExistsException>()),
      );
      expect((await data('users/a@uob.iq'))!['name'], 'أ');
      expect(await audit(), hasLength(1));
    });

    test('update saves the editor fields, keeps teachingStages, audits before/after', () async {
      const before = AppUser(email: 't@uob.iq', name: 'ت', teachingStages: ['3-morning']);
      await db.doc('users/t@uob.iq').set(before.toMap());
      final after = before.copyWith(
        name: 'ت معدّل',
        roles: {UserRole.teacher, UserRole.stageManager},
        stageScopes: ['3-morning'],
        active: false,
      );
      await repo.update(before, after, actor: admin);
      final saved = await data('users/t@uob.iq');
      expect(saved!['name'], 'ت معدّل');
      expect(saved['roles'], ['stageManager', 'teacher']);
      expect(saved['stageScopes'], ['3-morning']);
      expect(saved['active'], isFalse);
      expect(saved['teachingStages'], ['3-morning']);
      final entry = (await audit()).single;
      expect(entry['action'], 'user.update');
      expect((entry['before'] as Map)['roles'], ['teacher']);
      expect((entry['after'] as Map)['active'], isFalse);
    });
  });
}
