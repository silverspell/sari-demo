import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/data/ride_class.dart';
import 'package:sari/rides/ride_flow_controller.dart';
import 'package:sari/router/app_router.dart';
import 'package:sari/router/app_routes.dart';
import 'package:sari/screens/arrived_rating_screen.dart';
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
  testWidgets('yolculuk animasyonu bitince Vardın ekranı açılır', (
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
      rideDuration: const Duration(milliseconds: 300),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: buildSariTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    final context = tester.element(find.byType(HomeScreen));
    GoRouter.of(context).go(AppRoutes.ride);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.byType(RideScreen), findsOneWidget);
    expect(_locationOf(tester), AppRoutes.ride);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.byType(ArrivedRatingScreen), findsOneWidget);
    expect(find.byType(RideScreen), findsNothing);
    expect(_locationOf(tester), AppRoutes.arrived);
    expect(find.text('Vardın!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Vardın ekranı seçili Turkuaz sınıfının ücretini gösterir', (
    tester,
  ) async {
    final sessionController = SessionController(
      FakeSessionStore(_completedSession),
    );
    await sessionController.load();
    final flowController = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele)
      ..selectRideClass(RideClass.turkuaz);
    final router = createAppRouter(
      sessionController: sessionController,
      rideFlowController: flowController,
      tileProvider: FakeTileProvider(),
      rideDuration: const Duration(milliseconds: 300),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: buildSariTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(HomeScreen));
    GoRouter.of(context).go(AppRoutes.arrived);
    await tester.pumpAndSettle();

    final fare = tester.widget<Text>(
      find.byKey(ArrivedRatingScreen.fareTextKey),
    );
    expect(fare.data, '₺215,00');
    expect(tester.takeException(), isNull);
  });
}
