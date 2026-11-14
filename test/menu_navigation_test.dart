import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/payments/payment_method_controller.dart';
import 'package:sari/router/app_router.dart';
import 'package:sari/router/app_routes.dart';
import 'package:sari/screens/account_screen.dart';
import 'package:sari/screens/home_screen.dart';
import 'package:sari/screens/payment_methods_screen.dart';
import 'package:sari/screens/trip_history_screen.dart';
import 'package:sari/session/location_point.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/session_controller.dart';
import 'package:sari/theme/sari_theme.dart';
import 'package:sari/trips/trip_history_controller.dart';

import 'support/fake_session_store.dart';
import 'support/fake_tile_provider.dart';
import 'support/fake_trip_history_data.dart';

const _completedSession = Session(
  phone: '+905551112233',
  name: 'Cem',
  surname: 'Güler',
  locationPermission: LocationPermissionStatus.granted,
  location: DefaultLocations.modaKadikoy,
);

String _locationOf(WidgetTester tester, Finder finder) {
  final context = tester.element(finder);
  return GoRouterState.of(context).uri.toString();
}

String _textAt(WidgetTester tester, Key key) {
  final text = tester.widget<Text>(find.byKey(key));
  return text.data ?? '';
}

Future<({TripHistoryController history, PaymentMethodController payments})>
_pumpApp(WidgetTester tester) async {
  final sessionController = SessionController(
    FakeSessionStore(_completedSession),
  );
  await sessionController.load();
  final history = await createSeededTripHistoryController();
  final payments = PaymentMethodController();
  addTearDown(history.dispose);
  addTearDown(payments.dispose);
  final router = createAppRouter(
    sessionController: sessionController,
    tripHistoryController: history,
    paymentMethodController: payments,
    tileProvider: FakeTileProvider(),
    now: () => fakeTripHistoryNow,
  );
  addTearDown(router.dispose);

  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp.router(theme: buildSariTheme(), routerConfig: router),
  );
  await tester.pumpAndSettle();
  expect(find.byType(HomeScreen), findsOneWidget);

  return (history: history, payments: payments);
}

Future<void> _pushNamed(WidgetTester tester, String name) async {
  final context = tester.element(find.byType(HomeScreen));
  GoRouter.of(context).pushNamed(name);
  await tester.pumpAndSettle();
}

Future<void> _popBackToHome(WidgetTester tester, Finder screen) async {
  final context = tester.element(screen);
  GoRouter.of(context).pop();
  await tester.pumpAndSettle();
  expect(find.byType(HomeScreen), findsOneWidget);
  expect(_locationOf(tester, find.byType(HomeScreen)), AppRoutes.home);
}

void main() {
  testWidgets('AC1: yolculuklarım rotası açılır ve geri dönülür', (
    tester,
  ) async {
    await _pumpApp(tester);

    await _pushNamed(tester, AppRoutes.tripHistory);

    expect(find.byType(TripHistoryScreen), findsOneWidget);
    expect(
      _locationOf(tester, find.byType(TripHistoryScreen)),
      AppRoutes.tripHistory,
    );
    expect(find.byKey(TripHistoryScreen.screenKey), findsOneWidget);
    expect(find.byKey(TripHistoryScreen.tripCardKey(0)), findsOneWidget);
    expect(_textAt(tester, TripHistoryScreen.cardAmountKey(0)), '₺92,00');
    expect(
      _textAt(tester, TripHistoryScreen.cardRouteKey(0)),
      'Moda → Kadıköy İskele',
    );

    await _popBackToHome(tester, find.byType(TripHistoryScreen));
    expect(tester.takeException(), isNull);
  });

  testWidgets('AC1: hesabım rotası açılır ve geri dönülür', (tester) async {
    await _pumpApp(tester);

    await _pushNamed(tester, AppRoutes.account);

    expect(find.byType(AccountScreen), findsOneWidget);
    expect(_locationOf(tester, find.byType(AccountScreen)), AppRoutes.account);
    expect(find.byKey(AccountScreen.screenKey), findsOneWidget);
    expect(_textAt(tester, AccountScreen.nameTextKey), 'Cem Güler');

    await _popBackToHome(tester, find.byType(AccountScreen));
    expect(tester.takeException(), isNull);
  });

  testWidgets('AC1: ödeme yöntemleri rotası açılır ve geri dönülür', (
    tester,
  ) async {
    final app = await _pumpApp(tester);

    await _pushNamed(tester, AppRoutes.paymentMethods);

    expect(find.byType(PaymentMethodsScreen), findsOneWidget);
    expect(
      _locationOf(tester, find.byType(PaymentMethodsScreen)),
      AppRoutes.paymentMethods,
    );
    expect(find.byKey(PaymentMethodsScreen.screenKey), findsOneWidget);
    expect(app.payments.selected, FakeRideData.visa4242);

    await _popBackToHome(tester, find.byType(PaymentMethodsScreen));
    expect(tester.takeException(), isNull);
  });
}
