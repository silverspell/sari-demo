import 'package:flutter_test/flutter_test.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/shared_preferences_session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferencesSessionStore> createStore() async {
    final preferences = await SharedPreferences.getInstance();
    return SharedPreferencesSessionStore(preferences);
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('boş depoda read null döner', () async {
    final store = await createStore();

    expect(await store.read(), isNull);
  });

  test('yazılan oturum aynen geri okunur', () async {
    final store = await createStore();
    const session = Session(
      phone: '+905551112233',
      name: 'Şükrü',
      surname: 'Ağrı',
      locationPermission: LocationPermissionStatus.granted,
    );

    await store.write(session);

    expect(await store.read(), session);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('sari.session'), contains('Şükrü'));
  });

  test('clear oturumu siler', () async {
    final store = await createStore();
    const session = Session(
      phone: '+905551112233',
      name: 'Şükrü',
      surname: 'Ağrı',
    );
    await store.write(session);

    await store.clear();

    expect(await store.read(), isNull);
  });

  test('bozuk JSON null döner', () async {
    SharedPreferences.setMockInitialValues({'sari.session': '{bozuk'});
    final store = await createStore();

    expect(await store.read(), isNull);
  });
}
