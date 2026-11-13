import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/main.dart';
import 'package:sari/router/app_routes.dart';
import 'package:sari/screens/destination_screen.dart';
import 'package:sari/screens/location_permission_screen.dart';
import 'package:sari/screens/name_entry_screen.dart';
import 'package:sari/screens/otp_screen.dart';
import 'package:sari/screens/phone_login_screen.dart';
import 'package:sari/screens/home_screen.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/session_controller.dart';

import 'support/fake_session_store.dart';
import 'support/fake_tile_provider.dart';

const seededSession = Session(
  phone: '+905551112233',
  name: 'Şükrü',
  surname: 'Ağrı',
  locationPermission: LocationPermissionStatus.granted,
);

String locationOf(WidgetTester tester) {
  final context = tester.element(find.byType(Scaffold).first);
  return GoRouter.of(
    context,
  ).routerDelegate.currentConfiguration.uri.toString();
}

void expectAuthScreensAbsent() {
  expect(find.byType(PhoneLoginScreen), findsNothing);
  expect(find.byType(OtpScreen), findsNothing);
  expect(find.byType(NameEntryScreen), findsNothing);
  expect(find.byType(LocationPermissionScreen), findsNothing);
}

void main() {
  testWidgets('boş depo giriş ekranına yönlendirir', (tester) async {
    final store = FakeSessionStore();
    final controller = SessionController(store);
    await controller.load();

    await tester.pumpWidget(
      SariApp(sessionController: controller, tileProvider: FakeTileProvider()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(find.byType(OtpScreen), findsNothing);
    expect(find.byType(NameEntryScreen), findsNothing);
    expect(find.byType(LocationPermissionScreen), findsNothing);
    expect(find.byType(HomeScreen), findsNothing);
    expect(locationOf(tester), AppRoutes.login);
  });

  testWidgets('oturum varken tüm auth rotaları oturuma yönlendirir', (
    tester,
  ) async {
    final store = FakeSessionStore(seededSession);
    final controller = SessionController(store);
    await controller.load();

    await tester.pumpWidget(
      SariApp(sessionController: controller, tileProvider: FakeTileProvider()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expectAuthScreensAbsent();
    expect(locationOf(tester), AppRoutes.home);

    for (final path in AppRoutes.authPaths) {
      final context = tester.element(find.byType(HomeScreen));
      GoRouter.of(context).go(path);
      await tester.pumpAndSettle();

      expect(locationOf(tester), AppRoutes.home, reason: 'rota: $path');
      expect(find.byType(HomeScreen), findsOneWidget, reason: 'rota: $path');
      expectAuthScreensAbsent();
    }
  });

  testWidgets(
    'yalnızca telefon içeren oturum girişte kalır ve OTP rotasına gider',
    (tester) async {
      const phoneOnlySession = Session(
        phone: '+905551112233',
        name: '',
        surname: '',
      );
      final controller = SessionController(FakeSessionStore(phoneOnlySession));
      await controller.load();

      await tester.pumpWidget(
        SariApp(
          sessionController: controller,
          tileProvider: FakeTileProvider(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PhoneLoginScreen), findsOneWidget);
      expect(find.byType(OtpScreen), findsNothing);
      expect(find.byType(HomeScreen), findsNothing);
      expect(locationOf(tester), AppRoutes.login);

      final context = tester.element(find.byType(PhoneLoginScreen));
      GoRouter.of(context).go(AppRoutes.otp);
      await tester.pumpAndSettle();

      expect(find.byType(OtpScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      expect(locationOf(tester), AppRoutes.otp);

      final otpContext = tester.element(find.byType(OtpScreen));
      GoRouter.of(otpContext).go(AppRoutes.home);
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsNothing);
      expect(locationOf(tester), AppRoutes.login);
    },
  );

  testWidgets('oturum temizlenip yeniden başlatılınca girişe döner', (
    tester,
  ) async {
    final store = FakeSessionStore(seededSession);
    final controller = SessionController(store);
    await controller.load();

    await tester.pumpWidget(
      SariApp(
        key: const ValueKey('ilk'),
        sessionController: controller,
        tileProvider: FakeTileProvider(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.home);

    await controller.clear();
    await tester.pumpAndSettle();

    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    expect(locationOf(tester), AppRoutes.login);

    final restarted = SessionController(store);
    await restarted.load();

    await tester.pumpWidget(
      SariApp(
        key: const ValueKey('yeniden'),
        sessionController: restarted,
        tileProvider: FakeTileProvider(),
      ),
    );
    await tester.pumpAndSettle();

    expect(locationOf(tester), AppRoutes.login);
    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('oturum tamamlanmadan /nereye girişe yönlendirir', (
    tester,
  ) async {
    final controller = SessionController(FakeSessionStore());
    await controller.load();

    await tester.pumpWidget(
      SariApp(sessionController: controller, tileProvider: FakeTileProvider()),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(PhoneLoginScreen));
    GoRouter.of(context).go(AppRoutes.destination);
    await tester.pumpAndSettle();

    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(find.byType(DestinationScreen), findsNothing);
    expect(locationOf(tester), AppRoutes.login);
  });

  testWidgets('tamamlanmış oturum /nereye rotasına erişebilir', (tester) async {
    final controller = SessionController(FakeSessionStore(seededSession));
    await controller.load();

    await tester.pumpWidget(
      SariApp(sessionController: controller, tileProvider: FakeTileProvider()),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(HomeScreen));
    GoRouter.of(context).go(AppRoutes.destination);
    await tester.pumpAndSettle();

    expect(find.byType(DestinationScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.destination);
  });
}
