import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/data/ride_class.dart';
import 'package:sari/main.dart';
import 'package:sari/rides/ride_flow_controller.dart';
import 'package:sari/router/app_routes.dart';
import 'package:sari/screens/destination_screen.dart';
import 'package:sari/screens/finding_driver_screen.dart';
import 'package:sari/screens/home_screen.dart';
import 'package:sari/screens/phone_login_screen.dart';
import 'package:sari/screens/route_fare_screen.dart';
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
  RideFlowController? rideFlowController,
}) async {
  final controller = SessionController(FakeSessionStore(session));
  await controller.load();

  await tester.pumpWidget(
    SariApp(
      sessionController: controller,
      tileProvider: FakeTileProvider(),
      rideFlowController: rideFlowController,
    ),
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

  testWidgets('Kadıköy İskele satırı rota ve ücret ekranını açar', (
    tester,
  ) async {
    final flowController = RideFlowController();
    await pumpApp(tester, rideFlowController: flowController);

    await tester.tap(find.byKey(HomeScreen.searchButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(DestinationScreen.historyRowKey('kadikoy-iskele')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RouteFareScreen), findsOneWidget);
    expect(
      stateLocationOf(tester, find.byType(RouteFareScreen)),
      AppRoutes.routeFare,
    );
    expect(flowController.destination, FakeRideData.kadikoyIskele);
    expect(flowController.selectedRideClass, RideClass.sari);
    expect(find.text('Kadıköy İskele'), findsOneWidget);
    expect(find.text('12 dk'), findsWidgets);
    expect(find.text('4,8 km'), findsWidgets);
    expect(find.text('₺185'), findsOneWidget);
    expect(find.text('Taksi Çağır'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Taksi Çağır sürücü arama ekranını açar ve akışı korur', (
    tester,
  ) async {
    final flowController = RideFlowController();
    await pumpApp(tester, rideFlowController: flowController);

    await tester.tap(find.byKey(HomeScreen.searchButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(DestinationScreen.historyRowKey('kadikoy-iskele')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(RouteFareScreen.callButtonKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(FindingDriverScreen), findsOneWidget);
    expect(
      stateLocationOf(tester, find.byType(FindingDriverScreen)),
      AppRoutes.findingDriver,
    );
    expect(flowController.destination, FakeRideData.kadikoyIskele);
    expect(flowController.selectedRideClass, RideClass.sari);
    expect(find.text('₺185,00'), findsOneWidget);
    expect(find.text('Moda → Kadıköy İskele'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Evet, İptal Et rota ve ücret ekranına döner', (tester) async {
    final flowController = RideFlowController();
    await pumpApp(tester, rideFlowController: flowController);

    await tester.tap(find.byKey(HomeScreen.searchButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(DestinationScreen.historyRowKey('kadikoy-iskele')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(RouteFareScreen.callButtonKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(FindingDriverScreen.cancelButtonKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(FindingDriverScreen.cancelDialogKey), findsOneWidget);

    await tester.tap(find.byKey(FindingDriverScreen.confirmCancelKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(RouteFareScreen), findsOneWidget);
    expect(find.byType(FindingDriverScreen), findsNothing);
    expect(
      stateLocationOf(tester, find.byType(RouteFareScreen)),
      AppRoutes.routeFare,
    );
    expect(flowController.destination, FakeRideData.kadikoyIskele);
    expect(find.text('₺185'), findsOneWidget);
    expect(find.text('Taksi Çağır'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('öneri satırı rota ve ücret ekranını açar', (tester) async {
    final flowController = RideFlowController();
    await pumpApp(tester, rideFlowController: flowController);

    await tester.tap(find.byKey(HomeScreen.searchButtonKey));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(DestinationScreen.suggestionRowKey('istanbul-havalimani')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(DestinationScreen.suggestionRowKey('istanbul-havalimani')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RouteFareScreen), findsOneWidget);
    expect(flowController.destination, FakeRideData.istanbulHavalimani);
    expect(find.text('İstanbul Havalimanı (IST)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sonuç satırı rota ve ücret ekranını açar', (tester) async {
    final flowController = RideFlowController();
    await pumpApp(tester, rideFlowController: flowController);

    await tester.tap(find.byKey(HomeScreen.searchButtonKey));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(DestinationScreen.searchFieldKey),
      'Taksim',
    );
    await tester.pump();
    await tester.tap(
      find.byKey(DestinationScreen.resultRowKey('taksim-meydani')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RouteFareScreen), findsOneWidget);
    expect(flowController.destination, FakeRideData.taksim);
    expect(find.text('Taksim Meydanı'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
