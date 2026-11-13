import 'dart:math';

import '../session/location_point.dart';

final class NearbyTaxi {
  const NearbyTaxi({
    required this.id,
    required this.location,
    required this.etaMinutes,
  });

  final String id;
  final LocationPoint location;
  final int etaMinutes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyTaxi &&
          other.id == id &&
          other.location == location &&
          other.etaMinutes == etaMinutes;

  @override
  int get hashCode => Object.hash(id, location, etaMinutes);
}

final class NearbyTaxis {
  NearbyTaxis({required this.areaLabel, required List<NearbyTaxi> taxis})
    : taxis = List.unmodifiable(taxis);

  final String areaLabel;
  final List<NearbyTaxi> taxis;

  int get count => taxis.length;

  int get nearestEtaMinutes =>
      taxis.isEmpty ? 0 : taxis.map((taxi) => taxi.etaMinutes).reduce(min);

  String get countLabel => '$areaLabel • $count Taksi';

  String get nearestEtaLabel => 'En yakın $nearestEtaMinutes dk';
}
