import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/rides/ride_flow_controller.dart';
import 'package:sari/router/app_router.dart';
import 'package:sari/router/app_routes.dart';
import 'package:sari/screens/driver_found_screen.dart';
import 'package:sari/screens/finding_driver_screen.dart';
import 'package:sari/screens/home_screen.dart';
import 'package:sari/session/location_point.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/session_controller.dart';
import 'package:sari/theme/sari_theme.dart';

import 'support/fake_session_store.dart';
import 'support/fake_tile_provider.dart';

const _completedSession = Session(
  phone: '+905551112233',
  name: 'Cem',
  surname: 'Güler',
  locationPermission: LocationPermissionStatus.granted,
  location: DefaultLocations.modaKadikoy,
);

String locationOf(WidgetTester tester) {
  final context = tester.element(find.byType(Scaffold).first);
  return GoRouter.of(
    context,
  ).routerDelegate.currentConfiguration.uri.toString();
}

void main() {
  testWidgets('sürücü arama beklemesi bitince sürücü bulundu açılır', (
    tester,
  ) async {
    final sessionController = SessionController(
      FakeSessionStore(_completedSession),
    );
    await sessionController.load();
    final flowController = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);
    final router = createAppRouter(
      sessionController: sessionController,
      rideFlowController: flowController,
      tileProvider: FakeTileProvider(),
      findingDriverWaitDuration: const Duration(milliseconds: 100),
      driverArrivalDuration: const Duration(hours: 1),
    );

    await tester.pumpWidget(
      MaterialApp.router(theme: buildSariTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    final context = tester.element(find.byType(HomeScreen));
    GoRouter.of(context).go(AppRoutes.findingDriver);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    expect(find.byType(FindingDriverScreen), findsOneWidget);
    expect(
      GoRouter.of(
        tester.element(find.byType(FindingDriverScreen)),
      ).routerDelegate.currentConfiguration.uri.toString(),
      AppRoutes.findingDriver,
    );

    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(DriverFoundScreen), findsOneWidget);
    expect(find.byType(FindingDriverScreen), findsNothing);
    expect(
      GoRouter.of(
        tester.element(find.byType(DriverFoundScreen)),
      ).routerDelegate.currentConfiguration.uri.toString(),
      AppRoutes.driverFound,
    );
    expect(locationOf(tester), AppRoutes.driverFound);
    expect(flowController.destination, FakeRideData.kadikoyIskele);
    expect(find.text('Taksin 3 dk içinde geliyor'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(DriverFoundScreen), findsOneWidget);
    expect(find.byType(FindingDriverScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
