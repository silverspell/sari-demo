import 'package:geolocator/geolocator.dart';

import '../session/location_point.dart';

abstract interface class LocationService {
  Future<LocationPoint?> currentLocation();
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<LocationPoint?> currentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition();
      return LocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return null;
    }
  }
}
