import 'package:flutter_test/flutter_test.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/data/ride_class.dart';
import 'package:sari/data/route_fare_calculator.dart';
import 'package:sari/rides/ride_flow_controller.dart';
import 'package:sari/session/location_point.dart';

void main() {
  group('RideFlowController', () {
    test('varsayılan olarak Moda çıkışı, hedefsiz ve Sarı sınıfı tutar', () {
      final flow = RideFlowController();

      expect(flow.origin, DefaultLocations.modaKadikoy);
      expect(flow.destination, isNull);
      expect(flow.selectedRideClass, RideClass.sari);
      expect(flow.quote, isNull);
    });

    test('selectDestination hedefi yazar ve sınıfı Sarıya döndürür', () {
      final flow = RideFlowController();

      flow.selectRideClass(RideClass.turkuaz);
      flow.selectDestination(FakeRideData.kadikoyIskele);

      expect(flow.destination, FakeRideData.kadikoyIskele);
      expect(flow.selectedRideClass, RideClass.sari);
      expect(flow.quote?.duration, const Duration(minutes: 12));
      expect(flow.quote?.distanceMeters, 4800);
      expect(flow.quote?.fareFor(flow.selectedRideClass), 185);
    });

    test('selectRideClass Turkuaz ücretini 215 yapar ve yalnız değişimde '
        'dinleyicileri bildirir', () {
      final flow = RideFlowController()
        ..selectDestination(FakeRideData.kadikoyIskele);
      var notifications = 0;
      flow.addListener(() => notifications++);

      flow.selectRideClass(RideClass.turkuaz);

      expect(flow.selectedRideClass, RideClass.turkuaz);
      expect(flow.quote?.fareFor(flow.selectedRideClass), 215);
      expect(notifications, 1);

      flow.selectRideClass(RideClass.turkuaz);

      expect(notifications, 1);
    });

    test('yeni hedef seçimi sınıfı yeniden Sarıya sıfırlar', () {
      final flow = RideFlowController()
        ..selectDestination(FakeRideData.kadikoyIskele)
        ..selectRideClass(RideClass.turkuaz);

      flow.selectDestination(FakeRideData.taksim);

      expect(flow.destination, FakeRideData.taksim);
      expect(flow.selectedRideClass, RideClass.sari);
    });

    test('teklif her çağrıda deterministik ve hedefe göre farklıdır', () {
      final first = RideFlowController()
        ..selectDestination(FakeRideData.kadikoyIskele);
      final second = RideFlowController()
        ..selectDestination(FakeRideData.kadikoyIskele);
      final other = RideFlowController()
        ..selectDestination(FakeRideData.taksim);

      expect(first.quote, second.quote);
      expect(first.quote?.hashCode, second.quote?.hashCode);
      expect(
        first.quote?.distanceMeters,
        isNot(other.quote?.distanceMeters),
      );
      expect(
        first.quote?.sariFareLira,
        isNot(other.quote?.sariFareLira),
      );
    });

    test('RouteFareCalculator enjekte edilebilir', () {
      const calculator = RouteFareCalculator();
      final flow = RideFlowController(calculator: calculator)
        ..selectDestination(FakeRideData.kadikoyIskele);

      expect(
        flow.quote,
        calculator.quote(
          origin: DefaultLocations.modaKadikoy,
          destination: FakeRideData.kadikoyIskele,
        ),
      );
    });
  });
}
