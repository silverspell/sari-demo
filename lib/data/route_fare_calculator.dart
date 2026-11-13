import 'dart:math';

import '../session/location_point.dart';
import 'fake_place.dart';
import 'fake_ride_data.dart';
import 'route_quote.dart';

final class RouteFareCalculator {
  const RouteFareCalculator();

  static const _earthRadiusMeters = 6371000.0;
  static const _fnvOffsetBasis = 0x811c9dc5;
  static const _fnvPrime = 0x01000193;
  static const _fnvMask = 0xffffffff;
  static const _unitScale = 0x100000000;

  RouteQuote quote({
    required LocationPoint origin,
    required FakePlace destination,
  }) {
    final distanceMeters =
        origin == FakeRideData.sampleOrigin &&
            destination.id == FakeRideData.kadikoyIskele.id
        ? FakeRideData.sampleDistanceMeters
        : _roadDistanceMeters(origin, destination);

    final minutes = max(1, (distanceMeters / 1000 / 24 * 60).round());
    final sariFare = (41 + 30 * distanceMeters / 1000).round();

    return RouteQuote(
      origin: origin,
      destination: destination,
      distanceMeters: distanceMeters,
      duration: Duration(minutes: minutes),
      sariFareLira: sariFare,
    );
  }

  int _roadDistanceMeters(LocationPoint origin, FakePlace destination) {
    final directMeters = _haversineMeters(origin, destination.location);
    final roadFactor = 1.30 + 0.55 * _stableUnit(destination.id);
    return max(100, (directMeters * roadFactor / 100).round() * 100);
  }

  double _haversineMeters(LocationPoint from, LocationPoint to) {
    final lat1 = _radians(from.latitude);
    final lat2 = _radians(to.latitude);
    final deltaLat = lat2 - lat1;
    final deltaLng = _radians(to.longitude - from.longitude);
    final a =
        sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);
    return 2 * _earthRadiusMeters * atan2(sqrt(a), sqrt(1 - a));
  }

  double _stableUnit(String value) {
    var hash = _fnvOffsetBasis;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * _fnvPrime) & _fnvMask;
    }
    return hash / _unitScale;
  }

  double _radians(double degrees) => degrees * pi / 180;
}
