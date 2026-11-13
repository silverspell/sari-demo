import 'package:flutter_test/flutter_test.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/data/fake_route_path.dart';
import 'package:sari/session/location_point.dart';

void main() {
  const origin = DefaultLocations.modaKadikoy;
  const kadikoy = FakeRideData.kadikoyIskele;

  group('FakeRoutePath', () {
    test('ilk ve son nokta çıkış ile varışa tam eşittir', () {
      final points = FakeRoutePath.between(
        origin: origin,
        destination: kadikoy.location,
      );

      expect(points.first, origin);
      expect(points.last, kadikoy.location);
    });

    test('sabit sayıda nokta üretir ve deterministiktir', () {
      final first = FakeRoutePath.between(
        origin: origin,
        destination: kadikoy.location,
      );
      final second = FakeRoutePath.between(
        origin: origin,
        destination: kadikoy.location,
      );

      expect(first.length, FakeRoutePath.pointCount);
      expect(first.length, greaterThanOrEqualTo(24));
      expect(first, second);
    });

    test('düz bir doğru değildir', () {
      final points = FakeRoutePath.between(
        origin: origin,
        destination: kadikoy.location,
      );
      final middle = points[points.length ~/ 2];
      final deltaLat = kadikoy.location.latitude - origin.latitude;
      final deltaLng = kadikoy.location.longitude - origin.longitude;
      final cross =
          deltaLng * (middle.latitude - origin.latitude) -
          deltaLat * (middle.longitude - origin.longitude);

      expect(cross.abs(), greaterThan(1e-9));
    });

    test('farklı hedefler farklı yollar üretir', () {
      final kadikoyPath = FakeRoutePath.between(
        origin: origin,
        destination: kadikoy.location,
      );
      final taksimPath = FakeRoutePath.between(
        origin: origin,
        destination: FakeRideData.taksim.location,
      );

      expect(kadikoyPath, isNot(taksimPath));
    });

    test('tüm koordinatlar sonludur', () {
      final points = FakeRoutePath.between(
        origin: origin,
        destination: kadikoy.location,
      );

      for (final point in points) {
        expect(point.latitude.isFinite, isTrue);
        expect(point.longitude.isFinite, isTrue);
      }
    });

    test('aynı nokta için sabit ve sonlu bir yol döndürür', () {
      final points = FakeRoutePath.between(
        origin: origin,
        destination: origin,
      );

      expect(points.length, FakeRoutePath.pointCount);
      expect(points.every((point) => point == origin), isTrue);
    });
  });
}
