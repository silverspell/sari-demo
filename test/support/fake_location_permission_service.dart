import 'package:sari/permissions/location_permission_service.dart';

class FakeLocationPermissionService implements LocationPermissionService {
  FakeLocationPermissionService({
    this.decision = LocationPermissionDecision.granted,
  });

  LocationPermissionDecision decision;
  int requestCount = 0;

  @override
  Future<LocationPermissionDecision> requestPermission() async {
    requestCount++;
    return decision;
  }
}
