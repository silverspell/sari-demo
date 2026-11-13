import 'package:flutter_test/flutter_test.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/data/ride_class.dart';
import 'package:sari/data/route_fare_calculator.dart';
import 'package:sari/rides/ride_feedback_tag.dart';
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

    test('selectRating 1..5 aralığına sabitler ve değişimde bildirir', () {
      final flow = RideFlowController();
      final notifications = <int>[];
      flow.addListener(() => notifications.add(flow.rating ?? 0));

      flow.selectRating(4);

      expect(flow.rating, 4);
      expect(notifications, [4]);

      flow.selectRating(9);
      expect(flow.rating, 5);
      expect(notifications, [4, 5]);

      flow.selectRating(0);
      expect(flow.rating, 1);
      expect(notifications, [4, 5, 1]);

      flow.selectRating(1);
      expect(notifications, [4, 5, 1]);
    });

    test('toggleTag seçimi ekler ve çıkarır', () {
      final flow = RideFlowController();
      var notifications = 0;
      flow.addListener(() => notifications++);

      flow.toggleTag(RideFeedbackTag.temizArac);

      expect(flow.tags, {RideFeedbackTag.temizArac});
      expect(notifications, 1);

      flow.toggleTag(RideFeedbackTag.hizliRota);

      expect(flow.tags, {
        RideFeedbackTag.temizArac,
        RideFeedbackTag.hizliRota,
      });
      expect(notifications, 2);

      flow.toggleTag(RideFeedbackTag.temizArac);

      expect(flow.tags, {RideFeedbackTag.hizliRota});
      expect(notifications, 3);
    });

    test('tags dışarıdan değiştirilemez', () {
      final flow = RideFlowController()
        ..toggleTag(RideFeedbackTag.harikaSurus);

      expect(
        () => flow.tags.add(RideFeedbackTag.gulerYuzlu),
        throwsUnsupportedError,
      );
    });

    test('clearFeedback puan ve etiketleri sıfırlar', () {
      final flow = RideFlowController()
        ..selectDestination(FakeRideData.kadikoyIskele)
        ..selectRating(5)
        ..toggleTag(RideFeedbackTag.harikaSurus);
      var notifications = 0;
      flow.addListener(() => notifications++);

      flow.clearFeedback();

      expect(flow.rating, isNull);
      expect(flow.tags, isEmpty);
      expect(notifications, 1);
    });

    test('selectDestination puan ve etiketleri temizler', () {
      final flow = RideFlowController()
        ..selectDestination(FakeRideData.taksim)
        ..selectRating(4)
        ..toggleTag(RideFeedbackTag.temizArac);

      flow.selectDestination(FakeRideData.kadikoyIskele);

      expect(flow.rating, isNull);
      expect(flow.tags, isEmpty);
      expect(flow.selectedRideClass, RideClass.sari);
    });
  });
}
