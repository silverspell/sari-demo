import 'package:go_router/go_router.dart';

import '../screens/location_permission_screen.dart';
import '../screens/name_entry_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/phone_login_screen.dart';
import '../screens/session_placeholder_screen.dart';
import '../session/session_controller.dart';
import 'app_routes.dart';

GoRouter createAppRouter({required SessionController sessionController}) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: sessionController,
    redirect: (context, state) {
      final isAuthRoute = AppRoutes.authPaths.contains(state.matchedLocation);
      if (sessionController.hasSession && isAuthRoute) {
        return AppRoutes.session;
      }
      if (!sessionController.hasSession && !isAuthRoute) {
        return AppRoutes.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: AppRoutes.name,
        builder: (context, state) => const NameEntryScreen(),
      ),
      GoRoute(
        path: AppRoutes.locationPermission,
        builder: (context, state) => const LocationPermissionScreen(),
      ),
      GoRoute(
        path: AppRoutes.session,
        builder: (context, state) => const SessionPlaceholderScreen(),
      ),
    ],
  );
}
