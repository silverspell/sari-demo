import 'package:flutter_test/flutter_test.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/data/fake_route_path.dart';
import 'package:sari/data/route_fare_calculator.dart';
import 'package:sari/data/route_quote.dart';
import 'package:sari/rides/ride_simulation.dart';
import 'package:sari/session/location_point.dart';

RouteQuote _quote() => const RouteFareCalculator().quote(
  origin: DefaultLocations.modaKadikoy,
  destination: FakeRideData.kadikoyIskele,
);

List<LocationPoint> _routePoints() => FakeRoutePath.between(
  origin: DefaultLocations.modaKadikoy,
  destination: FakeRideData.kadikoyIskele.location,
);

RideSimulation _simulation({int seed = FakeRideData.rideSeed}) =>
    RideSimulation(routePoints: _routePoints(), quote: _quote(), seed: seed);

void main() {
  group('RideSimulation', () {
    test('hedef adını doğru Türkçe yönelme ekiyle yazar', () {
      expect(
        FakeRideData.dativeName(FakeRideData.kadikoyIskele),
        "Kadıköy İskele'ye",
      );
      expect(FakeRideData.dativeName(FakeRideData.taksim), "Taksim Meydanı'na");
      expect(
        FakeRideData.dativeName(FakeRideData.istanbulHavalimani),
        "İstanbul Havalimanı'na",
      );
      expect(FakeRideData.dativeName(FakeRideData.kanyonAvm), "Kanyon AVM'ye");
      expect(FakeRideData.dativeName(FakeRideData.ev), "Ev'e");
    });

    test('aynı seed aynı hareket dizisini üretir', () {
      final first = _simulation();
      final second = _simulation();

      for (final fraction in const [0.0, 0.15, 0.4, 0.72, 1.0]) {
        final firstSample = first.sampleAt(fraction);
        final secondSample = second.sampleAt(fraction);

        expect(firstSample.progress, secondSample.progress);
        expect(firstSample.position, secondSample.position);
        expect(
          firstSample.remainingDistanceMeters,
          secondSample.remainingDistanceMeters,
        );
        expect(firstSample.remainingMinutes, secondSample.remainingMinutes);
        expect(firstSample.maneuverLabel, secondSample.maneuverLabel);
      }
    });

    test('farklı seed hareketi değiştirir', () {
      final first = _simulation();
      final second = _simulation(seed: FakeRideData.rideSeed + 1);

      expect(
        first.sampleAt(0.5).position,
        isNot(second.sampleAt(0.5).position),
      );
    });

    test('ilerleme monoton artar ve uç noktalarda rotaya oturur', () {
      final simulation = _simulation();
      final route = _routePoints();
      var previous = -1.0;

      for (var step = 0; step <= 20; step++) {
        final sample = simulation.sampleAt(step / 20);
        expect(sample.progress, greaterThanOrEqualTo(previous));
        previous = sample.progress;
      }

      expect(simulation.sampleAt(0).progress, 0);
      expect(simulation.sampleAt(0).position, route.first);
      expect(simulation.sampleAt(1).progress, 1);
      expect(simulation.sampleAt(1).position, route.last);
    });

    test('kalan mesafe, süre ve sokak bilgisi ilerlemeyle güncellenir', () {
      final simulation = _simulation();
      final start = simulation.sampleAt(0);

      expect(start.remainingDistanceMeters, 4800);
      expect(start.remainingDistanceLabel, '4,8 km');
      expect(start.remainingMinutes, 12);
      expect(start.etaLabel, '14:26');
      expect(start.maneuverLabel, FakeRideData.rideManeuvers.first);

      final middle = simulation.sampleAt(1 / 3);

      expect(middle.progress, closeTo(1 / 3, 1e-12));
      expect(middle.remainingDistanceMeters, 3200);
      expect(middle.remainingDistanceLabel, '3,2 km');
      expect(middle.remainingMinutes, 8);
      expect(middle.etaLabel, '14:22');
      expect(middle.maneuverLabel, '200m sonra Rıhtım Caddesi çıkışı');

      final end = simulation.sampleAt(1);

      expect(end.remainingDistanceMeters, 0);
      expect(end.remainingDistanceLabel, '0,0 km');
      expect(end.remainingMinutes, 0);
    });

    test('sokak ve manevra metni ilerleme eşiklerine göre değişir', () {
      final simulation = _simulation();

      expect(
        simulation.sampleAt(0.1).maneuverLabel,
        FakeRideData.rideManeuvers[0],
      );
      expect(
        simulation.sampleAt(0.4).maneuverLabel,
        FakeRideData.rideManeuvers[1],
      );
      expect(
        simulation.sampleAt(0.7).maneuverLabel,
        FakeRideData.rideManeuvers[2],
      );
      expect(
        simulation.sampleAt(0.95).maneuverLabel,
        FakeRideData.rideManeuvers[3],
      );
    });
  });
}
