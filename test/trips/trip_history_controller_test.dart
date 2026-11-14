import 'package:flutter_test/flutter_test.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/trips/completed_trip.dart';
import 'package:sari/trips/in_memory_trip_history_store.dart';
import 'package:sari/trips/trip_history_controller.dart';

void main() {
  group('TripHistoryController', () {
    test('AC7: kaydedilen CompletedTrip alanlarıyla controller.trips.single okunur', () async {
      final controller = TripHistoryController(InMemoryTripHistoryStore());
      final completedAt = DateTime(2026, 11, 13, 9, 30);
      final trip = CompletedTrip(
        destination: FakeRideData.kadikoyIskele,
        departureLabel: 'Moda',
        distanceMeters: 4800,
        duration: const Duration(minutes: 12),
        completedAt: completedAt,
        amountLira: 185,
        driver: FakeRideData.driver,
        rating: 4.9,
      );

      await controller.save(trip);

      expect(controller.trips, hasLength(1));
      final saved = controller.trips.single;
      expect(saved.destination, FakeRideData.kadikoyIskele);
      expect(saved.departureLabel, 'Moda');
      expect(saved.distanceMeters, 4800);
      expect(saved.duration, const Duration(minutes: 12));
      expect(saved.completedAt, completedAt);
      expect(saved.amountLira, 185);
      expect(saved.driver, FakeRideData.driver);
      expect(saved.rating, 4.9);
    });
  });
}
