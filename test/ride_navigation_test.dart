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
import 'package:sari/screens/ride_screen.dart';
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

String _locationOf(WidgetTester tester) {
  final context = tester.element(find.byType(Scaffold).first);
  return GoRouter.of(
    context,
  ).routerDelegate.currentConfiguration.uri.toString();
}

void main() {
  testWidgets('sürücü varış süresi dolunca yolculuk ekranı açılır', (
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
      findingDriverWaitDuration: const Duration(milliseconds: 50),
      driverArrivalDuration: const Duration(milliseconds: 200),
      rideDuration: const Duration(seconds: 1),
    );

    await tester.pumpWidget(
      MaterialApp.router(theme: buildSariTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    final context = tester.element(find.byType(HomeScreen));
    GoRouter.of(context).go(AppRoutes.findingDriver);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    expect(find.byType(FindingDriverScreen), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(DriverFoundScreen), findsNothing);
    expect(find.byType(RideScreen), findsOneWidget);
    expect(_locationOf(tester), AppRoutes.ride);
    expect(flowController.destination, FakeRideData.kadikoyIskele);
    expect(find.text("Kadıköy İskele'ye gidiyorsun"), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(RideScreen), findsOneWidget);
    expect(find.text('Varışa 0 dk'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
