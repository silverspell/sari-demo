import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/main.dart';
import 'package:sari/router/app_routes.dart';
import 'package:sari/screens/account_screen.dart';
import 'package:sari/screens/home_screen.dart';
import 'package:sari/screens/phone_login_screen.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/session_controller.dart';

import 'support/fake_session_store.dart';
import 'support/fake_tile_provider.dart';

const _completedSession = Session(
  phone: '+905321234567',
  name: 'Cem',
  surname: 'Güler',
  locationPermission: LocationPermissionStatus.granted,
);

String locationOf(WidgetTester tester) {
  final context = tester.element(find.byType(Scaffold).first);
  return GoRouter.of(
    context,
  ).routerDelegate.currentConfiguration.uri.toString();
}

void main() {
  testWidgets('AC3: Çıkış Yap oturumu temizler ve girişe döner', (
    tester,
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

    final homeContext = tester.element(find.byType(HomeScreen));
    GoRouter.of(homeContext).go(AppRoutes.account);
    await tester.pumpAndSettle();

    expect(find.byType(AccountScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.account);

    await tester.ensureVisible(find.byKey(AccountScreen.logoutButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(AccountScreen.logoutButtonKey));
    await tester.pumpAndSettle();

    expect(controller.session, isNull);
    expect(store.session, isNull);
    expect(find.byType(AccountScreen), findsNothing);
    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.login);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tamamlanmamış oturumla /hesabim girişe yönlendirir', (
    tester,
  ) async {
    final store = FakeSessionStore();
    final controller = SessionController(store);
    await controller.load();

    await tester.pumpWidget(
      SariApp(sessionController: controller, tileProvider: FakeTileProvider()),
    );
    await tester.pumpAndSettle();

    final loginContext = tester.element(find.byType(PhoneLoginScreen));
    GoRouter.of(loginContext).go(AppRoutes.account);
    await tester.pumpAndSettle();

    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(find.byType(AccountScreen), findsNothing);
    expect(locationOf(tester), AppRoutes.login);
    expect(tester.takeException(), isNull);
  });
}
