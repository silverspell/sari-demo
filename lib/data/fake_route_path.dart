import 'dart:math' as math;

import '../session/location_point.dart';

abstract final class FakeRoutePath {
  static const segmentCount = 28;
  static const pointCount = segmentCount + 1;

  static const _curveFactor = 0.32;

  static List<LocationPoint> between({
    required LocationPoint origin,
    required LocationPoint destination,
  }) {
    final deltaLat = destination.latitude - origin.latitude;
    final deltaLng = destination.longitude - origin.longitude;
    final length = math.sqrt(deltaLat * deltaLat + deltaLng * deltaLng);

    if (length == 0) {
      return List<LocationPoint>.filled(pointCount, origin);
    }

    final normalLat = deltaLat / length;
    final normalLng = -deltaLng / length;
    final controlLat =
        (origin.latitude + destination.latitude) / 2 +
        normalLat * length * _curveFactor;
    final controlLng =
        (origin.longitude + destination.longitude) / 2 +
        normalLng * length * _curveFactor;

    return <LocationPoint>[
      for (var index = 0; index < pointCount; index++)
        _pointAt(
          index: index,
          origin: origin,
          destination: destination,
          controlLat: controlLat,
          controlLng: controlLng,
        ),
    ];
  }

  static LocationPoint _pointAt({
    required int index,
    required LocationPoint origin,
    required LocationPoint destination,
    required double controlLat,
    required double controlLng,
  }) {
    if (index == 0) {
      return origin;
    }
    if (index == pointCount - 1) {
      return destination;
    }

    final t = index / segmentCount;
    final inverse = 1 - t;
    return LocationPoint(
      latitude:
          inverse * inverse * origin.latitude +
          2 * inverse * t * controlLat +
          t * t * destination.latitude,
      longitude:
          inverse * inverse * origin.longitude +
          2 * inverse * t * controlLng +
          t * t * destination.longitude,
    );
  }
}
