import 'package:sari/location/location_service.dart';
import 'package:sari/session/location_point.dart';

class FakeLocationService implements LocationService {
  FakeLocationService({
    this.location = DefaultLocations.modaKadikoy,
    this.error,
  });

  LocationPoint? location;
  Object? error;
  int callCount = 0;

  @override
  Future<LocationPoint?> currentLocation() async {
    callCount++;
    if (error != null) {
      throw error!;
    }
    return location;
  }
}
