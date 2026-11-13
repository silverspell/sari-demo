import 'package:flutter_test/flutter_test.dart';
import 'package:sari/session/location_point.dart';
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

    test('konum JSON gidiş dönüşünde korunur', () {
      const session = Session(
        phone: '+905551112233',
        name: 'Şükrü',
        surname: 'Ağrı',
        locationPermission: LocationPermissionStatus.granted,
        location: DefaultLocations.modaKadikoy,
      );

      final restored = Session.fromJson(session.toJson());

      expect(restored, session);
      expect(restored.location, DefaultLocations.modaKadikoy);
    });

    test('eksik konum null olur', () {
      final session = Session.fromJson({
        'phone': '+905551112233',
        'name': 'Şükrü',
        'surname': 'Ağrı',
        'locationPermission': 'granted',
      });

      expect(session.location, isNull);
    });

    test('geçersiz konum null olur', () {
      final session = Session.fromJson({
        'phone': '+905551112233',
        'name': 'Şükrü',
        'surname': 'Ağrı',
        'locationPermission': 'granted',
        'location': {'latitude': 'geçersiz', 'longitude': 29.0255},
      });

      expect(session.location, isNull);
    });

    test('konum nesne olmayan değerde null olur', () {
      final session = Session.fromJson({
        'phone': '+905551112233',
        'name': 'Şükrü',
        'surname': 'Ağrı',
        'location': 'bozuk',
      });

      expect(session.location, isNull);
    });

    test('copyWith konumu değiştirir, diğer alanları korur', () {
      const session = Session(
        phone: '+905551112233',
        name: 'Şükrü',
        surname: 'Ağrı',
        locationPermission: LocationPermissionStatus.notRequested,
      );

      final updated = session.copyWith(
        locationPermission: LocationPermissionStatus.denied,
        location: DefaultLocations.modaKadikoy,
      );

      expect(updated.phone, session.phone);
      expect(updated.name, session.name);
      expect(updated.surname, session.surname);
      expect(updated.locationPermission, LocationPermissionStatus.denied);
      expect(updated.location, DefaultLocations.modaKadikoy);
    });

    test('eşitlik konumu da kapsar', () {
      const withoutLocation = Session(
        phone: '+905551112233',
        name: 'Şükrü',
        surname: 'Ağrı',
      );
      const withLocation = Session(
        phone: '+905551112233',
        name: 'Şükrü',
        surname: 'Ağrı',
        location: DefaultLocations.modaKadikoy,
      );

      expect(withoutLocation, isNot(withLocation));
      expect(withoutLocation.hashCode, isNot(withLocation.hashCode));
    });
  });
}
