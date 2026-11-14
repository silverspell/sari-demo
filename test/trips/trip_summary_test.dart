import 'package:flutter_test/flutter_test.dart';
import 'package:sari/trips/trip_summary.dart';

import '../support/fake_trip_history_data.dart';

void main() {
  group('TripSummary.forMonth', () {
    test('ay ve yıl eşleşen yolculukları sayar ve toplar', () {
      final summary = TripSummary.forMonth(
        trips: fakeTrips,
        month: DateTime(2023, 11),
      );

      expect(summary.tripCount, 3);
      expect(summary.totalMeters, 42600);
      expect(summary.totalDuration, const Duration(minutes: 68));
    });

    test('toplam km metre/1000 ve CO₂ sabit katsayıyla hesaplanır', () {
      final summary = TripSummary.forMonth(
        trips: fakeTrips,
        month: DateTime(2023, 11),
      );

      expect(summary.totalKilometers, closeTo(42.6, 1e-9));
      expect(summary.co2SavedKg, closeTo(5.4102, 1e-9));
    });

    test('farklı ay sıfır özet döndürür', () {
      final summary = TripSummary.forMonth(
        trips: fakeTrips,
        month: DateTime(2023, 10),
      );

      expect(summary.tripCount, 0);
      expect(summary.totalMeters, 0);
      expect(summary.totalDuration, Duration.zero);
      expect(summary.totalKilometers, 0);
      expect(summary.co2SavedKg, 0);
    });

    test('aynı ay farklı yıl eşleşmez', () {
      final summary = TripSummary.forMonth(
        trips: fakeTrips,
        month: DateTime(2024, 11),
      );

      expect(summary.tripCount, 0);
      expect(summary.totalMeters, 0);
    });
  });
}
