import 'dart:math';

import '../session/location_point.dart';
import 'nearby_taxi.dart';

final class NearbyTaxiGenerator {
  const NearbyTaxiGenerator();

  static const defaultSeed = 1923;
  static const taxiCount = 42;

  static const _metresPerDegreeLatitude = 111320.0;
  static const _firstTaxiDistanceMeters = 300.0;
  static const _minimumTaxiDistanceMeters = 300.0;
  static const _maximumExtraDistanceMeters = 1700.0;

  NearbyTaxis generate({
    required String areaLabel,
    required LocationPoint center,
    int seed = defaultSeed,
    int count = taxiCount,
  }) {
    final random = Random(seed);
    final taxis = <NearbyTaxi>[];
    final metresPerDegreeLongitude =
        _metresPerDegreeLatitude * cos(center.latitude * pi / 180);

    for (var index = 0; index < count; index++) {
      final bearing = random.nextDouble() * 2 * pi;
      final distanceMeters = index == 0
          ? _firstTaxiDistanceMeters
          : _minimumTaxiDistanceMeters +
                random.nextDouble() * _maximumExtraDistanceMeters;

      final latitudeOffset =
          distanceMeters * cos(bearing) / _metresPerDegreeLatitude;
      final longitudeOffset =
          distanceMeters * sin(bearing) / metresPerDegreeLongitude;

      final location = LocationPoint(
        latitude: center.latitude + latitudeOffset,
        longitude: center.longitude + longitudeOffset,
      );

      taxis.add(
        NearbyTaxi(
          id: 'taksi-${index + 1}',
          location: location,
          etaMinutes: max(2, (distanceMeters / 1000 / 18 * 60).ceil()),
        ),
      );
    }

    return NearbyTaxis(areaLabel: areaLabel, taxis: taxis);
  }
}
