import 'package:permission_handler/permission_handler.dart';

enum LocationPermissionDecision { granted, denied }

abstract interface class LocationPermissionService {
  Future<LocationPermissionDecision> requestPermission();
}

class PermissionHandlerLocationPermissionService
    implements LocationPermissionService {
  const PermissionHandlerLocationPermissionService();

  @override
  Future<LocationPermissionDecision> requestPermission() async {
    try {
      final status = await Permission.locationWhenInUse.request();
      return status.isGranted
          ? LocationPermissionDecision.granted
          : LocationPermissionDecision.denied;
    } catch (_) {
      return LocationPermissionDecision.denied;
    }
  }
}
