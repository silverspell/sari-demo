import 'package:flutter_test/flutter_test.dart';
import 'package:sari/session/location_point.dart';

void main() {
  group('LocationPoint', () {
    test('Moda varsayılanı doğru koordinatlardadır', () {
      expect(DefaultLocations.modaKadikoy.latitude, 40.9812);
      expect(DefaultLocations.modaKadikoy.longitude, 29.0255);
    });

    test('JSON gidiş dönüşü koordinatları korur', () {
      const point = LocationPoint(latitude: 40.9812, longitude: 29.0255);

      final restored = LocationPoint.fromJson(point.toJson());

      expect(restored, point);
      expect(restored.latitude, 40.9812);
      expect(restored.longitude, 29.0255);
    });

    test('eşitlik ve hashCode koordinatlara göre çalışır', () {
      const first = LocationPoint(latitude: 40.9812, longitude: 29.0255);
      const second = LocationPoint(latitude: 40.9812, longitude: 29.0255);
      const different = LocationPoint(latitude: 41.0, longitude: 29.0);

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(different));
      expect(first.hashCode, isNot(different.hashCode));
    });
  });
}
