import '../data/fake_driver.dart';
import '../data/fake_place.dart';

final class CompletedTrip {
  const CompletedTrip({
    required this.destination,
    required this.departureLabel,
    required this.distanceMeters,
    required this.duration,
    required this.completedAt,
    required this.amountLira,
    required this.driver,
    required this.rating,
  });

  final FakePlace destination;
  final String departureLabel;
  final int distanceMeters;
  final Duration duration;
  final DateTime completedAt;
  final int amountLira;
  final FakeDriver driver;
  final double rating;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletedTrip &&
          other.destination == destination &&
          other.departureLabel == departureLabel &&
          other.distanceMeters == distanceMeters &&
          other.duration == duration &&
          other.completedAt == completedAt &&
          other.amountLira == amountLira &&
          other.driver == driver &&
          other.rating == rating;

  @override
  int get hashCode => Object.hash(
    destination,
    departureLabel,
    distanceMeters,
    duration,
    completedAt,
    amountLira,
    driver,
    rating,
  );
}
