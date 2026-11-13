import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'location/location_service.dart';
import 'permissions/location_permission_service.dart';
import 'rides/ride_flow_controller.dart';
import 'router/app_router.dart';
import 'session/session_controller.dart';
import 'session/shared_preferences_session_store.dart';
import 'theme/sari_theme.dart';
import 'trips/in_memory_trip_history_store.dart';
import 'trips/trip_history_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final sessionController = SessionController(
    SharedPreferencesSessionStore(preferences),
  );
  await sessionController.load();
  runApp(SariApp(sessionController: sessionController));
}

class SariApp extends StatefulWidget {
  const SariApp({
    super.key,
    required this.sessionController,
    this.locationPermissionService =
        const PermissionHandlerLocationPermissionService(),
    this.locationService = const GeolocatorLocationService(),
    this.rideFlowController,
    this.tripHistoryController,
    this.tileProvider,
  });

  final SessionController sessionController;
  final LocationPermissionService locationPermissionService;
  final LocationService locationService;
  final RideFlowController? rideFlowController;
  final TripHistoryController? tripHistoryController;
  final TileProvider? tileProvider;

  @override
  State<SariApp> createState() => _SariAppState();
}

class _SariAppState extends State<SariApp> {
  late GoRouter _router;
  RideFlowController? _ownedRideFlowController;
  TripHistoryController? _ownedTripHistoryController;

  RideFlowController get _rideFlowController =>
      widget.rideFlowController ??
      (_ownedRideFlowController ??= RideFlowController());

  TripHistoryController get _tripHistoryController =>
      widget.tripHistoryController ??
      (_ownedTripHistoryController ??= TripHistoryController(
        InMemoryTripHistoryStore(),
      ));

  @override
  void initState() {
    super.initState();
    _ensureRideFlowController();
    _ensureTripHistoryController();
    _router = _createRouter();
  }

  @override
  void didUpdateWidget(covariant SariApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    final flowChanged =
        oldWidget.rideFlowController != widget.rideFlowController;
    final historyChanged =
        oldWidget.tripHistoryController != widget.tripHistoryController;
    if (flowChanged ||
        historyChanged ||
        oldWidget.sessionController != widget.sessionController ||
        oldWidget.locationPermissionService !=
            widget.locationPermissionService ||
        oldWidget.locationService != widget.locationService ||
        oldWidget.tileProvider != widget.tileProvider) {
      if (flowChanged) {
        _ownedRideFlowController?.dispose();
        _ownedRideFlowController = null;
        _ensureRideFlowController();
      }
      if (historyChanged) {
        _ownedTripHistoryController?.dispose();
        _ownedTripHistoryController = null;
        _ensureTripHistoryController();
      }
      _router.dispose();
      _router = _createRouter();
    }
  }

  void _ensureRideFlowController() {
    if (widget.rideFlowController == null) {
      _ownedRideFlowController ??= RideFlowController();
    }
  }

  void _ensureTripHistoryController() {
    if (widget.tripHistoryController == null) {
      _ownedTripHistoryController ??= TripHistoryController(
        InMemoryTripHistoryStore(),
      );
    }
  }

  GoRouter _createRouter() => createAppRouter(
    sessionController: widget.sessionController,
    locationPermissionService: widget.locationPermissionService,
    locationService: widget.locationService,
    rideFlowController: _rideFlowController,
    tripHistoryController: _tripHistoryController,
    tileProvider: widget.tileProvider,
  );

  @override
  void dispose() {
    _router.dispose();
    _ownedRideFlowController?.dispose();
    _ownedTripHistoryController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sarı',
      debugShowCheckedModeBanner: false,
      theme: buildSariTheme(),
      routerConfig: _router,
    );
  }
}
