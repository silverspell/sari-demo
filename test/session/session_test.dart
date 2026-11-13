import 'package:flutter_test/flutter_test.dart';
import 'package:sari/session/session.dart';

void main() {
  group('Session', () {
    test('JSON gidiş dönüşü Türkçe karakterleri korur', () {
      const session = Session(
        phone: '+905551112233',
        name: 'Şükrü',
        surname: 'Ağrı',
        locationPermission: LocationPermissionStatus.granted,
      );

      final restored = Session.fromJson(session.toJson());

      expect(restored, session);
      expect(restored.name, 'Şükrü');
      expect(restored.surname, 'Ağrı');
      expect(restored.locationPermission, LocationPermissionStatus.granted);
    });

    test('bilinmeyen konum izni notRequested olur', () {
      final session = Session.fromJson({
        'phone': '+905551112233',
        'name': 'Şükrü',
        'surname': 'Ağrı',
        'locationPermission': 'bilinmiyor',
      });

      expect(session.locationPermission, LocationPermissionStatus.notRequested);
    });

    test('eksik konum izni notRequested olur', () {
      final session = Session.fromJson({
        'phone': '+905551112233',
        'name': 'Şükrü',
        'surname': 'Ağrı',
      });

      expect(session.locationPermission, LocationPermissionStatus.notRequested);
    });

    test('copyWith yalnızca verilen alanları değiştirir', () {
      const session = Session(
        phone: '+905551112233',
        name: 'Şükrü',
        surname: 'Ağrı',
        locationPermission: LocationPermissionStatus.granted,
      );

      final updated = session.copyWith(
        name: 'Mehmet',
        locationPermission: LocationPermissionStatus.denied,
      );

      expect(updated.phone, session.phone);
      expect(updated.name, 'Mehmet');
      expect(updated.surname, session.surname);
      expect(updated.locationPermission, LocationPermissionStatus.denied);
    });
  });
}
