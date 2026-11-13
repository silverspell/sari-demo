import 'package:flutter_test/flutter_test.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/data/ride_class.dart';
import 'package:sari/data/route_fare_calculator.dart';
import 'package:sari/session/location_point.dart';

void main() {
  const calculator = RouteFareCalculator();

  group('RouteFareCalculator', () {
    test('AC1: Moda → Kadıköy İskele her çağrıda 12 dk, 4800 m, 185 TL ve eşittir', () {
      final first = calculator.quote(
        origin: DefaultLocations.modaKadikoy,
        destination: FakeRideData.kadikoyIskele,
      );
      final second = calculator.quote(
        origin: DefaultLocations.modaKadikoy,
        destination: FakeRideData.kadikoyIskele,
      );

      expect(first.duration, const Duration(minutes: 12));
      expect(first.distanceMeters, 4800);
      expect(first.sariFareLira, 185);
      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('AC2: Turkuaz ücret Sarı ücretin 1.16 katı, 185 TL → 215 TL', () {
      final quote = calculator.quote(
        origin: DefaultLocations.modaKadikoy,
        destination: FakeRideData.kadikoyIskele,
      );

      expect(quote.fareFor(RideClass.sari), 185);
      expect(quote.fareFor(RideClass.turkuaz), 215);
      expect((185 * 1.16).round(), 215);
    });

    test('AC3: iki farklı hedef deterministik ve birbirinden farklıdır', () {
      final kadikoyFirst = calculator.quote(
        origin: DefaultLocations.modaKadikoy,
        destination: FakeRideData.kadikoyIskele,
      );
      final kadikoySecond = calculator.quote(
        origin: DefaultLocations.modaKadikoy,
        destination: FakeRideData.kadikoyIskele,
      );
      final taksimFirst = calculator.quote(
        origin: DefaultLocations.modaKadikoy,
        destination: FakeRideData.taksim,
      );
      final taksimSecond = calculator.quote(
        origin: DefaultLocations.modaKadikoy,
        destination: FakeRideData.taksim,
      );

      expect(kadikoyFirst, kadikoySecond);
      expect(taksimFirst, taksimSecond);
      expect(kadikoyFirst.distanceMeters, isNot(taksimFirst.distanceMeters));
      expect(kadikoyFirst.sariFareLira, isNot(taksimFirst.sariFareLira));
    });
  });
}
