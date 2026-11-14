import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/main.dart';
import 'package:sari/router/app_routes.dart';
import 'package:sari/screens/home_screen.dart';
import 'package:sari/screens/otp_screen.dart';
import 'package:sari/screens/phone_login_screen.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/session_controller.dart';
import 'package:sari/widgets/menu_drawer.dart';

import 'support/fake_session_store.dart';
import 'support/fake_tile_provider.dart';

const _completedSession = Session(
  phone: '+905321234567',
  name: 'Cem',
  surname: 'Güler',
  locationPermission: LocationPermissionStatus.granted,
);

String _locationOf(WidgetTester tester) {
  final context = tester.element(find.byType(Scaffold).first);
  return GoRouter.of(
    context,
  ).routerDelegate.currentConfiguration.uri.toString();
}

Future<({SessionController controller, FakeSessionStore store})> _pumpApp(
  WidgetTester tester,
) async {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final store = FakeSessionStore(_completedSession);
  final controller = SessionController(store);
  await controller.load();

  await tester.pumpWidget(
    SariApp(sessionController: controller, tileProvider: FakeTileProvider()),
  );
  await tester.pumpAndSettle();

  expect(find.byType(HomeScreen), findsOneWidget);
  expect(_locationOf(tester), AppRoutes.home);

  return (controller: controller, store: store);
}

Future<void> _openMenuAndLogout(WidgetTester tester) async {
  await tester.tap(find.byKey(HomeScreen.menuButtonKey));
  await tester.pumpAndSettle();

  expect(find.byKey(MenuDrawer.panelKey), findsOneWidget);
  expect(find.byKey(MenuDrawer.logoutButtonKey), findsOneWidget);

  await tester.tap(find.byKey(MenuDrawer.logoutButtonKey));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('AC4: menüden Çıkış yap oturumu temizler ve girişe döner', (
    tester,
  ) async {
    final app = await _pumpApp(tester);

    await _openMenuAndLogout(tester);

    expect(app.controller.session, isNull);
    expect(app.store.session, isNull);
    expect(find.byKey(MenuDrawer.panelKey), findsNothing);
    expect(find.byType(HomeScreen), findsNothing);
    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(_locationOf(tester), AppRoutes.login);
    expect(tester.takeException(), isNull);

    await tester.enterText(
      find.byKey(PhoneLoginScreen.phoneFieldKey),
      '5551234567',
    );
    await tester.pump();
    await tester.tap(find.byKey(PhoneLoginScreen.continueButtonKey));
    await tester.pumpAndSettle();

    expect(app.store.session?.phone, '+905551234567');
    expect(find.byType(OtpScreen), findsOneWidget);
    expect(_locationOf(tester), AppRoutes.otp);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'AC6: hamburger -> menü -> Çıkış yap -> telefon girişi uçtan uca',
    (tester) async {
      await _pumpApp(tester);

      expect(find.byKey(MenuDrawer.panelKey), findsNothing);

      await tester.tap(find.byKey(HomeScreen.menuButtonKey));
      await tester.pumpAndSettle();
      expect(find.byKey(MenuDrawer.panelKey), findsOneWidget);

      await tester.tap(find.byKey(MenuDrawer.logoutButtonKey));
      await tester.pumpAndSettle();

      expect(find.byType(PhoneLoginScreen), findsOneWidget);
      expect(find.byKey(PhoneLoginScreen.phoneFieldKey), findsOneWidget);
      expect(_locationOf(tester), AppRoutes.login);
      expect(tester.takeException(), isNull);
    },
  );
}
