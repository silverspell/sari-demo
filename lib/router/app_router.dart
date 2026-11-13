import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';

import '../location/location_service.dart';
import '../permissions/location_permission_service.dart';
import '../rides/ride_flow_controller.dart';
import '../screens/destination_screen.dart';
import '../screens/driver_found_screen.dart';
import '../screens/finding_driver_screen.dart';
import '../screens/home_screen.dart';
import '../screens/location_permission_screen.dart';
import '../screens/name_entry_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/phone_login_screen.dart';
import '../screens/route_fare_screen.dart';
import '../session/session_controller.dart';
import 'app_routes.dart';

GoRouter createAppRouter({
  required SessionController sessionController,
  LocationPermissionService locationPermissionService =
      const PermissionHandlerLocationPermissionService(),
  LocationService locationService = const GeolocatorLocationService(),
  RideFlowController? rideFlowController,
  TileProvider? tileProvider,
  Duration findingDriverWaitDuration = FindingDriverScreen.defaultWaitDuration,
}) {
  final flowController = rideFlowController ?? RideFlowController();

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: sessionController,
    redirect: (context, state) {
      final isAuthRoute = AppRoutes.authPaths.contains(state.matchedLocation);
      if (sessionController.hasCompletedSession && isAuthRoute) {
        return AppRoutes.home;
      }
      if (!sessionController.hasCompletedSession && !isAuthRoute) {
        return AppRoutes.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) =>
            PhoneLoginScreen(sessionController: sessionController),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) =>
            OtpScreen(phone: sessionController.session?.phone),
      ),
      GoRoute(
        path: AppRoutes.name,
        builder: (context, state) => NameEntryScreen(
          sessionController: sessionController,
          phone: sessionController.session?.phone,
        ),
      ),
      GoRoute(
        path: AppRoutes.locationPermission,
        builder: (context, state) => LocationPermissionScreen(
          sessionController: sessionController,
          permissionService: locationPermissionService,
          locationService: locationService,
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => HomeScreen(
          sessionController: sessionController,
          permissionService: locationPermissionService,
          locationService: locationService,
          tileProvider: tileProvider,
        ),
      ),
      GoRoute(
        path: AppRoutes.destination,
        builder: (context, state) =>
            DestinationScreen(flowController: flowController),
      ),
      GoRoute(
        path: AppRoutes.routeFare,
        builder: (context, state) => RouteFareScreen(
          flowController: flowController,
          tileProvider: tileProvider,
        ),
      ),
      GoRoute(
        path: AppRoutes.findingDriver,
        builder: (context, state) => FindingDriverScreen(
          flowController: flowController,
          tileProvider: tileProvider,
          waitDuration: findingDriverWaitDuration,
          onSearchComplete: () {
            if (!context.mounted) {
              return;
            }
            context.pushReplacement(AppRoutes.driverFound);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.driverFound,
        builder: (context, state) => DriverFoundScreen(
          flowController: flowController,
          tileProvider: tileProvider,
        ),
      ),
    ],
  );
}
