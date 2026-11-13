import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/main.dart';
import 'package:sari/router/app_routes.dart';
import 'package:sari/screens/location_permission_screen.dart';
import 'package:sari/screens/name_entry_screen.dart';
import 'package:sari/screens/otp_screen.dart';
import 'package:sari/screens/phone_login_screen.dart';
import 'package:sari/screens/home_screen.dart';
import 'package:sari/session/location_point.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/session_controller.dart';

import 'support/fake_location_permission_service.dart';
import 'support/fake_session_store.dart';
import 'support/fake_tile_provider.dart';

const _phone = '+905551234567';

String locationOf(WidgetTester tester) {
  final context = tester.element(find.byType(Scaffold).first);
  return GoRouter.of(
    context,
  ).routerDelegate.currentConfiguration.uri.toString();
}

Future<void> enterCode(WidgetTester tester, String code) async {
  for (var i = 0; i < code.length; i++) {
    await tester.enterText(find.byKey(OtpScreen.digitKey(i)), code[i]);
    await tester.pump();
  }
}

Future<void> settleAfterOtp(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('telefondan ana ekrana uçtan uca akış', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = FakeSessionStore();
    final permissionService = FakeLocationPermissionService();
    final controller = SessionController(store);
    await controller.load();

    await tester.pumpWidget(
      SariApp(
        sessionController: controller,
        locationPermissionService: permissionService,
        tileProvider: FakeTileProvider(),
      ),
    );
    await tester.pumpAndSettle();

    expect(store.session, isNull);
    expect(controller.session, isNull);
    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.login);

    await tester.enterText(
      find.byKey(PhoneLoginScreen.phoneFieldKey),
      '5551234567',
    );
    await tester.pump();

    final phoneField = tester.widget<TextField>(
      find.byKey(PhoneLoginScreen.phoneFieldKey),
    );
    expect(phoneField.controller?.text, '555 123 45 67');

    await tester.tap(find.byKey(PhoneLoginScreen.continueButtonKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(store.session?.phone, _phone);
    expect(find.byType(OtpScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.otp);

    await enterCode(tester, '1234');
    await tester.tap(find.byKey(OtpScreen.verifyButtonKey));
    await settleAfterOtp(tester);

    expect(find.byType(NameEntryScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.name);

    await tester.enterText(
      find.byKey(NameEntryScreen.firstNameFieldKey),
      'Ayşe',
    );
    await tester.enterText(
      find.byKey(NameEntryScreen.lastNameFieldKey),
      'Yılmaz',
    );
    await tester.pump();

    await tester.ensureVisible(find.byKey(NameEntryScreen.continueButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(NameEntryScreen.continueButtonKey));
    await tester.pumpAndSettle();

    expect(store.session?.name, 'Ayşe');
    expect(store.session?.surname, 'Yılmaz');
    expect(find.byType(LocationPermissionScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.locationPermission);

    await tester.ensureVisible(
      find.byKey(LocationPermissionScreen.notNowButtonKey),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(LocationPermissionScreen.notNowButtonKey));
    await tester.pumpAndSettle();

    expect(permissionService.requestCount, 0);
    expect(
      controller.session?.locationPermission,
      LocationPermissionStatus.denied,
    );
    expect(controller.session?.location, DefaultLocations.modaKadikoy);
    expect(controller.hasCompletedSession, isTrue);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.home);

    expect(find.text('Merhaba Ayşe'), findsOneWidget);
    final greeting = tester.widget<Text>(
      find.byKey(HomeScreen.greetingTextKey),
    );
    expect(greeting.data, 'Merhaba Ayşe');
    expect(find.text('Nereye?'), findsOneWidget);
    expect(find.text('Taksi çağır'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
