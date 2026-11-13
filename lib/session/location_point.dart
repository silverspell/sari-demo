class LocationPoint {
  const LocationPoint({required this.latitude, required this.longitude});

  factory LocationPoint.fromJson(Map<String, dynamic> json) => LocationPoint(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  );

  static LocationPoint? tryParse(Object? value) {
    if (value is! Map) {
      return null;
    }
    final latitude = value['latitude'];
    final longitude = value['longitude'];
    if (latitude is! num || longitude is! num) {
      return null;
    }
    return LocationPoint(
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
    );
  }

  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationPoint &&
          other.latitude == latitude &&
          other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

abstract final class DefaultLocations {
  static const taksimMeydani = LocationPoint(
    latitude: 41.0369,
    longitude: 28.9850,
  );
}
