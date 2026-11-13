import 'dart:math' as math;

import '../data/fake_ride_data.dart';
import '../data/route_quote.dart';
import '../session/location_point.dart';

final class RideSample {
  const RideSample({
    required this.progress,
    required this.position,
    required this.remainingDistanceMeters,
    required this.remainingMinutes,
    required this.etaLabel,
    required this.remainingDistanceLabel,
    required this.maneuverLabel,
  });

  final double progress;
  final LocationPoint position;
  final int remainingDistanceMeters;
  final int remainingMinutes;
  final String etaLabel;
  final String remainingDistanceLabel;
  final String maneuverLabel;
}

final class RideSimulation {
  RideSimulation({
    required List<LocationPoint> routePoints,
    required this.quote,
    this.seed = FakeRideData.rideSeed,
    this.startClockMinutes = FakeRideData.fakeStartClockMinutes,
  }) : assert(routePoints.length >= 2),
       _routePoints = List<LocationPoint>.unmodifiable(routePoints) {
    final random = _SeededRandom(seed);
    _wobblePhase = random.nextDouble() * 2 * math.pi;
    _wobbleMeters = 12 + random.nextDouble() * 18;
  }

  static const _earthMetersPerDegree = 111320.0;

  final RouteQuote quote;
  final int seed;
  final int startClockMinutes;

  final List<LocationPoint> _routePoints;
  late final double _wobblePhase;
  late final double _wobbleMeters;

  List<LocationPoint> get routePoints => _routePoints;

  RideSample sampleAt(double timeFraction) {
    final progress = timeFraction.clamp(0.0, 1.0).toDouble();
    final position = _positionAt(progress);
    final remainingDistanceMeters = (quote.distanceMeters * (1 - progress))
        .round();
    final totalMinutes = quote.duration.inMinutes;
    var remainingMinutes = (totalMinutes * (1 - progress) - 1e-9).ceil();
    if (remainingMinutes < 0) {
      remainingMinutes = 0;
    }
    if (remainingMinutes > totalMinutes) {
      remainingMinutes = totalMinutes;
    }

    return RideSample(
      progress: progress,
      position: position,
      remainingDistanceMeters: remainingDistanceMeters,
      remainingMinutes: remainingMinutes,
      etaLabel: formatClock(startClockMinutes + remainingMinutes),
      remainingDistanceLabel: formatDistance(remainingDistanceMeters),
      maneuverLabel: _maneuverAt(progress),
    );
  }

  static String formatClock(int minutesSinceMidnight) {
    final normalized = minutesSinceMidnight % (24 * 60);
    final hours = (normalized ~/ 60).toString().padLeft(2, '0');
    final minutes = (normalized % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  static String formatDistance(int meters) {
    final kilometers = meters / 1000;
    return '${kilometers.toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  LocationPoint _positionAt(double progress) {
    if (progress <= 0) {
      return _routePoints.first;
    }
    if (progress >= 1) {
      return _routePoints.last;
    }

    final scaled = progress * (_routePoints.length - 1);
    var index = scaled.floor();
    if (index < 0) {
      index = 0;
    }
    if (index > _routePoints.length - 2) {
      index = _routePoints.length - 2;
    }
    final segmentProgress = scaled - index;
    final from = _routePoints[index];
    final to = _routePoints[index + 1];

    final latitude = _lerp(from.latitude, to.latitude, segmentProgress);
    final longitude = _lerp(from.longitude, to.longitude, segmentProgress);
    final envelope = math.sin(progress * math.pi);
    final wobble =
        math.sin(progress * math.pi * 3 + _wobblePhase) *
        _wobbleMeters *
        envelope;

    final latitudeRadians = latitude * math.pi / 180;
    final metersPerDegreeLongitude =
        _earthMetersPerDegree * math.cos(latitudeRadians);
    final deltaLat = to.latitude - from.latitude;
    final deltaLng = to.longitude - from.longitude;
    final east = deltaLng * metersPerDegreeLongitude;
    final north = deltaLat * _earthMetersPerDegree;
    final length = math.sqrt(east * east + north * north);

    if (length == 0) {
      return LocationPoint(latitude: latitude, longitude: longitude);
    }

    final perpendicularEast = -north / length;
    final perpendicularNorth = east / length;

    return LocationPoint(
      latitude: latitude + perpendicularNorth * wobble / _earthMetersPerDegree,
      longitude:
          longitude + perpendicularEast * wobble / metersPerDegreeLongitude,
    );
  }

  static String _maneuverAt(double progress) {
    final maneuvers = FakeRideData.rideManeuvers;
    if (progress < 0.2) {
      return maneuvers[0];
    }
    if (progress < 0.6) {
      return maneuvers[1];
    }
    if (progress < 0.9) {
      return maneuvers[2];
    }
    return maneuvers[3];
  }

  static double _lerp(double from, double to, double t) =>
      from + (to - from) * t;
}

final class _SeededRandom {
  _SeededRandom(int seed)
    : _state = (seed == 0 ? 0x9e3779b9 : seed) & 0x7fffffff;

  int _state;

  double nextDouble() {
    var value = _state;
    value ^= (value << 13) & 0x7fffffff;
    value ^= value >> 17;
    value ^= (value << 5) & 0x7fffffff;
    _state = value & 0x7fffffff;
    return _state / 0x7fffffff;
  }
}
