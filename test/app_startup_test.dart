import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/main.dart';
import 'package:sari/router/app_routes.dart';
import 'package:sari/screens/location_permission_screen.dart';
import 'package:sari/screens/name_entry_screen.dart';
import 'package:sari/screens/otp_screen.dart';
import 'package:sari/screens/phone_login_screen.dart';
import 'package:sari/screens/session_placeholder_screen.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/session_controller.dart';

import 'support/fake_session_store.dart';

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

    await tester.pumpWidget(SariApp(sessionController: controller));
    await tester.pumpAndSettle();

    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(find.byType(OtpScreen), findsNothing);
    expect(find.byType(NameEntryScreen), findsNothing);
    expect(find.byType(LocationPermissionScreen), findsNothing);
    expect(find.byType(SessionPlaceholderScreen), findsNothing);
    expect(locationOf(tester), AppRoutes.login);
  });

  testWidgets('oturum varken tüm auth rotaları oturuma yönlendirir', (
    tester,
  ) async {
    final store = FakeSessionStore(seededSession);
    final controller = SessionController(store);
    await controller.load();

    await tester.pumpWidget(SariApp(sessionController: controller));
    await tester.pumpAndSettle();

    expect(find.byType(SessionPlaceholderScreen), findsOneWidget);
    expectAuthScreensAbsent();
    expect(locationOf(tester), AppRoutes.session);

    for (final path in AppRoutes.authPaths) {
      final context = tester.element(find.byType(SessionPlaceholderScreen));
      GoRouter.of(context).go(path);
      await tester.pumpAndSettle();

      expect(locationOf(tester), AppRoutes.session, reason: 'rota: $path');
      expect(
        find.byType(SessionPlaceholderScreen),
        findsOneWidget,
        reason: 'rota: $path',
      );
      expectAuthScreensAbsent();
    }
  });

  testWidgets('yalnızca telefon içeren oturum girişte kalır ve OTP rotasına gider', (
    tester,
  ) async {
    const phoneOnlySession = Session(
      phone: '+905551112233',
      name: '',
      surname: '',
    );
    final controller = SessionController(FakeSessionStore(phoneOnlySession));
    await controller.load();

    await tester.pumpWidget(SariApp(sessionController: controller));
    await tester.pumpAndSettle();

    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(find.byType(OtpScreen), findsNothing);
    expect(find.byType(SessionPlaceholderScreen), findsNothing);
    expect(locationOf(tester), AppRoutes.login);

    final context = tester.element(find.byType(PhoneLoginScreen));
    GoRouter.of(context).go(AppRoutes.otp);
    await tester.pumpAndSettle();

    expect(find.byType(OtpScreen), findsOneWidget);
    expect(find.byType(SessionPlaceholderScreen), findsNothing);
    expect(locationOf(tester), AppRoutes.otp);

    final otpContext = tester.element(find.byType(OtpScreen));
    GoRouter.of(otpContext).go(AppRoutes.session);
    await tester.pumpAndSettle();

    expect(find.byType(SessionPlaceholderScreen), findsNothing);
    expect(locationOf(tester), AppRoutes.login);
  });

  testWidgets('oturum temizlenip yeniden başlatılınca girişe döner', (
    tester,
  ) async {
    final store = FakeSessionStore(seededSession);
    final controller = SessionController(store);
    await controller.load();

    await tester.pumpWidget(
      SariApp(key: const ValueKey('ilk'), sessionController: controller),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SessionPlaceholderScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.session);

    await controller.clear();
    await tester.pumpAndSettle();

    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(find.byType(SessionPlaceholderScreen), findsNothing);
    expect(locationOf(tester), AppRoutes.login);

    final restarted = SessionController(store);
    await restarted.load();

    await tester.pumpWidget(
      SariApp(key: const ValueKey('yeniden'), sessionController: restarted),
    );
    await tester.pumpAndSettle();

    expect(locationOf(tester), AppRoutes.login);
    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(find.byType(SessionPlaceholderScreen), findsNothing);
  });
}
