import 'package:flutter_test/flutter_test.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/session_controller.dart';

import '../support/fake_session_store.dart';

void main() {
  const session = Session(
    phone: '+905551112233',
    name: 'Şükrü',
    surname: 'Ağrı',
    locationPermission: LocationPermissionStatus.granted,
  );

  test('load mevcut oturumu yükler', () async {
    final store = FakeSessionStore(session);
    final controller = SessionController(store);

    await controller.load();

    expect(controller.session, session);
    expect(controller.hasSession, isTrue);
  });

  test('load boş depoda oturumsuz kalır', () async {
    final controller = SessionController(FakeSessionStore());

    await controller.load();

    expect(controller.session, isNull);
    expect(controller.hasSession, isFalse);
  });

  test('save depoya yazar ve bir kez haber verir', () async {
    final store = FakeSessionStore();
    final controller = SessionController(store);
    var notifications = 0;
    controller.addListener(() => notifications++);

    await controller.save(session);

    expect(store.session, session);
    expect(controller.session, session);
    expect(notifications, 1);
  });

  test('clear depoyu ve durumu temizler ve haber verir', () async {
    final store = FakeSessionStore(session);
    final controller = SessionController(store);
    await controller.load();
    var notifications = 0;
    controller.addListener(() => notifications++);

    await controller.clear();

    expect(store.session, isNull);
    expect(controller.session, isNull);
    expect(notifications, 1);
  });

  test('clear sonrası aynı depodan yeni controller oturumsuz açılır', () async {
    final store = FakeSessionStore(session);
    final controller = SessionController(store);
    await controller.load();
    await controller.clear();

    final restarted = SessionController(store);
    await restarted.load();

    expect(restarted.hasSession, isFalse);
  });

  test('hasCompletedSession oturum yokken false', () async {
    final controller = SessionController(FakeSessionStore());

    await controller.load();

    expect(controller.hasSession, isFalse);
    expect(controller.hasCompletedSession, isFalse);
  });

  test('hasCompletedSession yalnızca telefon olan oturumda false', () async {
    final controller = SessionController(
      FakeSessionStore(
        const Session(phone: '+905551112233', name: '', surname: ''),
      ),
    );

    await controller.load();

    expect(controller.hasSession, isTrue);
    expect(controller.hasCompletedSession, isFalse);
  });

  test('hasCompletedSession ad ve konum izni tamamlanınca true', () async {
    final controller = SessionController(FakeSessionStore(session));

    await controller.load();

    expect(controller.hasCompletedSession, isTrue);
  });

  test('hasCompletedSession boş soyadla tamamlanmış sayılır', () async {
    final controller = SessionController(
      FakeSessionStore(
        const Session(
          phone: '+905551112233',
          name: 'Şükrü',
          surname: '',
          locationPermission: LocationPermissionStatus.granted,
        ),
      ),
    );

    await controller.load();

    expect(controller.hasCompletedSession, isTrue);
  });

  test('hasCompletedSession boş adla tamamlanmış sayılmaz', () async {
    final controller = SessionController(
      FakeSessionStore(
        const Session(
          phone: '+905551112233',
          name: '',
          surname: 'Ağrı',
          locationPermission: LocationPermissionStatus.granted,
        ),
      ),
    );

    await controller.load();

    expect(controller.hasCompletedSession, isFalse);
  });

  test('hasCompletedSession konum izni istenmemişse false', () async {
    final controller = SessionController(
      FakeSessionStore(
        const Session(phone: '+905551112233', name: 'Şükrü', surname: 'Ağrı'),
      ),
    );

    await controller.load();

    expect(controller.hasSession, isTrue);
    expect(controller.hasCompletedSession, isFalse);
  });

  test('hasCompletedSession izin reddedilse de boş soyadla true', () async {
    final controller = SessionController(
      FakeSessionStore(
        const Session(
          phone: '+905551112233',
          name: 'Şükrü',
          surname: '',
          locationPermission: LocationPermissionStatus.denied,
        ),
      ),
    );

    await controller.load();

    expect(controller.hasCompletedSession, isTrue);
  });

  test('hasCompletedSession konum koordinatı olmadan da true', () async {
    final controller = SessionController(
      FakeSessionStore(
        const Session(
          phone: '+905551112233',
          name: 'Şükrü',
          surname: 'Ağrı',
          locationPermission: LocationPermissionStatus.granted,
        ),
      ),
    );

    await controller.load();

    expect(controller.session?.location, isNull);
    expect(controller.hasCompletedSession, isTrue);
  });
}
