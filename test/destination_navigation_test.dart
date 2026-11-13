import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/main.dart';
import 'package:sari/router/app_routes.dart';
import 'package:sari/screens/destination_screen.dart';
import 'package:sari/screens/home_screen.dart';
import 'package:sari/screens/phone_login_screen.dart';
import 'package:sari/session/location_point.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/session_controller.dart';

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

String stateLocationOf(WidgetTester tester, Finder finder) {
  final context = tester.element(finder);
  return GoRouterState.of(context).uri.toString();
}

Future<SessionController> pumpApp(
  WidgetTester tester, {
  Session? session = _completedSession,
}) async {
  final controller = SessionController(FakeSessionStore(session));
  await controller.load();

  await tester.pumpWidget(
    SariApp(sessionController: controller, tileProvider: FakeTileProvider()),
  );
  await tester.pumpAndSettle();

  return controller;
}

void main() {
  testWidgets('Nereye? arama alanı Nereye ekranını açar', (tester) async {
    await pumpApp(tester);

    expect(find.byType(HomeScreen), findsOneWidget);

    await tester.tap(find.byKey(HomeScreen.searchButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(DestinationScreen), findsOneWidget);
    expect(find.byKey(DestinationScreen.screenKey), findsOneWidget);
    expect(
      stateLocationOf(tester, find.byType(DestinationScreen)),
      AppRoutes.destination,
    );
    expect(find.text('Mevcut Konum · Moda, Kadıköy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hedefsiz Taksi çağır Nereye ekranını açar', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(HomeScreen.callTaxiButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(DestinationScreen), findsOneWidget);
    expect(
      stateLocationOf(tester, find.byType(DestinationScreen)),
      AppRoutes.destination,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Nereye ekranından geri ana ekrana döner', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(HomeScreen.searchButtonKey));
    await tester.pumpAndSettle();
    expect(find.byType(DestinationScreen), findsOneWidget);

    await tester.tap(find.byKey(DestinationScreen.backButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(DestinationScreen), findsNothing);
    expect(stateLocationOf(tester, find.byType(HomeScreen)), AppRoutes.home);
  });

  testWidgets('oturum tamamlanmamışsa /nereye girişe yönlendirir', (
    tester,
  ) async {
    await pumpApp(tester, session: null);

    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.login);

    final context = tester.element(find.byType(PhoneLoginScreen));
    GoRouter.of(context).go(AppRoutes.destination);
    await tester.pumpAndSettle();

    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(find.byType(DestinationScreen), findsNothing);
    expect(locationOf(tester), AppRoutes.login);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tamamlanmış oturum /nereye rotasına erişebilir', (tester) async {
    await pumpApp(tester);

    final context = tester.element(find.byType(HomeScreen));
    GoRouter.of(context).go(AppRoutes.destination);
    await tester.pumpAndSettle();

    expect(find.byType(DestinationScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.destination);
    expect(tester.takeException(), isNull);
  });
}
