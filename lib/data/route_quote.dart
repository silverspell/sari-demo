import '../session/location_point.dart';
import 'fake_place.dart';
import 'ride_class.dart';

final class RouteQuote {
  const RouteQuote({
    required this.origin,
    required this.destination,
    required this.distanceMeters,
    required this.duration,
    required this.sariFareLira,
  });

  final LocationPoint origin;
  final FakePlace destination;
  final int distanceMeters;
  final Duration duration;
  final int sariFareLira;

  int fareFor(RideClass rideClass) =>
      (sariFareLira * rideClass.fareMultiplier).round();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteQuote &&
          other.origin == origin &&
          other.destination == destination &&
          other.distanceMeters == distanceMeters &&
          other.duration == duration &&
          other.sariFareLira == sariFareLira;

  @override
  int get hashCode =>
      Object.hash(origin, destination, distanceMeters, duration, sariFareLira);
}
