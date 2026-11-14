import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/payments/payment_method_controller.dart';
import 'package:sari/router/app_router.dart';
import 'package:sari/router/app_routes.dart';
import 'package:sari/screens/arrived_rating_screen.dart';
import 'package:sari/screens/home_screen.dart';
import 'package:sari/screens/payment_methods_screen.dart';
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

String textAt(WidgetTester tester, Key key) {
  final text = tester.widget<Text>(find.byKey(key));
  return text.data ?? '';
}

void main() {
  testWidgets('AC3: ödeme yöntemi seçimi Vardın ekranına yansır', (
    tester,
  ) async {
    final sessionController = SessionController(
      FakeSessionStore(_completedSession),
    );
    await sessionController.load();
    final payments = PaymentMethodController();
    addTearDown(payments.dispose);
    final router = createAppRouter(
      sessionController: sessionController,
      paymentMethodController: payments,
      tileProvider: FakeTileProvider(),
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

    final homeContext = tester.element(find.byType(HomeScreen));
    GoRouter.of(homeContext).go(AppRoutes.paymentMethods);
    await tester.pumpAndSettle();

    expect(find.byType(PaymentMethodsScreen), findsOneWidget);
    expect(_locationOf(tester), AppRoutes.paymentMethods);
    expect(payments.selected, FakeRideData.visa4242);

    await tester.tap(
      find.byKey(
        PaymentMethodsScreen.methodRowKey(FakeRideData.mastercard5310.id),
      ),
    );
    await tester.pumpAndSettle();

    expect(payments.selected, FakeRideData.mastercard5310);
    expect(
      find.byKey(
        PaymentMethodsScreen.methodDefaultBadgeKey(
          FakeRideData.mastercard5310.id,
        ),
      ),
      findsOneWidget,
    );

    final paymentsContext = tester.element(find.byType(PaymentMethodsScreen));
    GoRouter.of(paymentsContext).go(AppRoutes.arrived);
    await tester.pumpAndSettle();

    expect(find.byType(ArrivedRatingScreen), findsOneWidget);
    expect(_locationOf(tester), AppRoutes.arrived);
    expect(textAt(tester, ArrivedRatingScreen.paymentLabelKey), '•••• 5310');
    expect(textAt(tester, ArrivedRatingScreen.paymentBrandKey), 'Mastercard');

    final arrivedContext = tester.element(find.byType(ArrivedRatingScreen));
    GoRouter.of(arrivedContext).go(AppRoutes.paymentMethods);
    await tester.pumpAndSettle();

    expect(find.byType(PaymentMethodsScreen), findsOneWidget);
    expect(
      find.byKey(
        PaymentMethodsScreen.methodDefaultBadgeKey(
          FakeRideData.mastercard5310.id,
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        PaymentMethodsScreen.methodDefaultBadgeKey(FakeRideData.visa4242.id),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
