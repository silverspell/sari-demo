import 'package:flutter_test/flutter_test.dart';
import 'package:sari/session/location_point.dart';

void main() {
  group('LocationPoint', () {
    test('Taksim varsayılanı doğru koordinatlardadır', () {
      expect(DefaultLocations.taksimMeydani.latitude, 41.0369);
      expect(DefaultLocations.taksimMeydani.longitude, 28.9850);
    });

    test('JSON gidiş dönüşü koordinatları korur', () {
      const point = LocationPoint(latitude: 41.0369, longitude: 28.9850);

      final restored = LocationPoint.fromJson(point.toJson());

      expect(restored, point);
      expect(restored.latitude, 41.0369);
      expect(restored.longitude, 28.9850);
    });

    test('eşitlik ve hashCode koordinatlara göre çalışır', () {
      const first = LocationPoint(latitude: 41.0369, longitude: 28.9850);
      const second = LocationPoint(latitude: 41.0369, longitude: 28.9850);
      const different = LocationPoint(latitude: 41.0, longitude: 29.0);

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(different));
      expect(first.hashCode, isNot(different.hashCode));
    });
  });
}
