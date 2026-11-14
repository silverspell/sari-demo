import '../data/co2_factors.dart';
import 'completed_trip.dart';

final class TripSummary {
  const TripSummary({
    required this.tripCount,
    required this.totalMeters,
    required this.totalDuration,
  });

  factory TripSummary.forMonth({
    required Iterable<CompletedTrip> trips,
    required DateTime month,
  }) {
    var tripCount = 0;
    var totalMeters = 0;
    var totalDuration = Duration.zero;

    for (final trip in trips) {
      if (trip.completedAt.year == month.year &&
          trip.completedAt.month == month.month) {
        tripCount += 1;
        totalMeters += trip.distanceMeters;
        totalDuration += trip.duration;
      }
    }

    return TripSummary(
      tripCount: tripCount,
      totalMeters: totalMeters,
      totalDuration: totalDuration,
    );
  }

  final int tripCount;
  final int totalMeters;
  final Duration totalDuration;

  double get totalKilometers => totalMeters / 1000;

  double get co2SavedKg => totalKilometers * Co2Factors.kgPerKilometer;
}
