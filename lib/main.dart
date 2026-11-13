import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'location/location_service.dart';
import 'permissions/location_permission_service.dart';
import 'router/app_router.dart';
import 'session/session_controller.dart';
import 'session/shared_preferences_session_store.dart';
import 'theme/sari_theme.dart';

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
  });

  final SessionController sessionController;
  final LocationPermissionService locationPermissionService;
  final LocationService locationService;

  @override
  State<SariApp> createState() => _SariAppState();
}

class _SariAppState extends State<SariApp> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _createRouter();
  }

  @override
  void didUpdateWidget(covariant SariApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionController != widget.sessionController ||
        oldWidget.locationPermissionService !=
            widget.locationPermissionService ||
        oldWidget.locationService != widget.locationService) {
      _router.dispose();
      _router = _createRouter();
    }
  }

  GoRouter _createRouter() => createAppRouter(
    sessionController: widget.sessionController,
    locationPermissionService: widget.locationPermissionService,
    locationService: widget.locationService,
  );

  @override
  void dispose() {
    _router.dispose();
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
