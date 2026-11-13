@Tags(['golden'])
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/main.dart';
import 'package:sari/router/app_routes.dart';
import 'package:sari/screens/phone_login_screen.dart';
import 'package:sari/screens/session_placeholder_screen.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/session_controller.dart';
import 'package:sari/theme/sari_theme.dart';

import 'support/fake_session_store.dart';

const _fullSession = Session(
  phone: '+905551112233',
  name: 'Cem',
  surname: 'Güler',
  locationPermission: LocationPermissionStatus.granted,
);

const _nameOnlySession = Session(
  phone: '+905551112233',
  name: 'Cem',
  surname: '',
  locationPermission: LocationPermissionStatus.granted,
);

String locationOf(WidgetTester tester) {
  final context = tester.element(find.byType(Scaffold).first);
  return GoRouter.of(
    context,
  ).routerDelegate.currentConfiguration.uri.toString();
}

Future<SessionController> pumpApp(
  WidgetTester tester, {
  FakeSessionStore? store,
  Size size = const Size(430, 932),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final controller = SessionController(store ?? FakeSessionStore(_fullSession));
  await controller.load();

  await tester.pumpWidget(SariApp(sessionController: controller));
  await tester.pumpAndSettle();

  return controller;
}

void main() {
  testWidgets('ad ve soyadlı oturumda selamlama ve çıkış görünür', (
    tester,
  ) async {
    await pumpApp(tester, store: FakeSessionStore(_fullSession));

    expect(find.byType(SessionPlaceholderScreen), findsOneWidget);
    expect(
      find.text('Merhaba, Cem Güler'),
      findsOneWidget,
    );
    expect(find.text('Çıkış yap'), findsOneWidget);
    expect(
      find.byKey(SessionPlaceholderScreen.logoutButtonKey),
      findsOneWidget,
    );
    expect(find.byKey(SessionPlaceholderScreen.greetingTextKey), findsOneWidget);
    expect(locationOf(tester), AppRoutes.session);
  });

  testWidgets('yalnızca adlı oturumda selamlama soyad içermez', (tester) async {
    await pumpApp(tester, store: FakeSessionStore(_nameOnlySession));

    expect(find.text('Merhaba, Cem'), findsOneWidget);
    expect(find.textContaining('Güler'), findsNothing);
    expect(locationOf(tester), AppRoutes.session);
  });

  testWidgets('Çıkış yap oturumu temizler ve telefon girişine döner', (
    tester,
  ) async {
    final store = FakeSessionStore(_fullSession);
    final controller = await pumpApp(tester, store: store);

    await tester.tap(find.byKey(SessionPlaceholderScreen.logoutButtonKey));
    await tester.pumpAndSettle();

    expect(controller.session, isNull);
    expect(store.session, isNull);
    expect(locationOf(tester), AppRoutes.login);
    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(find.byType(SessionPlaceholderScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('boşluklu ad ve soyad kırpılarak gösterilir', (tester) async {
    const spaced = Session(
      phone: '+905551112233',
      name: '  Cem  ',
      surname: '   ',
      locationPermission: LocationPermissionStatus.granted,
    );
    await pumpApp(tester, store: FakeSessionStore(spaced));

    expect(find.text('Merhaba, Cem'), findsOneWidget);
  });

  testWidgets('oturum yokken Yolcu selamlaması çökmeden görünür', (
    tester,
  ) async {
    final controller = SessionController(FakeSessionStore());

    await tester.pumpWidget(
      MaterialApp(
        theme: buildSariTheme(),
        home: SessionPlaceholderScreen(sessionController: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Merhaba, Yolcu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(375, 667), Size(430, 932)]) {
    testWidgets('taşma yok ${size.width.toInt()}x${size.height.toInt()}', (
      tester,
    ) async {
      await pumpApp(tester, size: size);

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(SessionPlaceholderScreen.screenKey)), size);
      expect(
        tester
            .getBottomLeft(find.byKey(SessionPlaceholderScreen.logoutButtonKey))
            .dy,
        lessThanOrEqualTo(size.height),
      );
    });
  }

  goldenTest(
    'Oturum yer tutucusu',
    fileName: '04b-session-placeholder',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'iPhone SE (375x667)',
          child: sessionPlaceholderGolden(const Size(375, 667)),
        ),
        GoldenTestScenario(
          name: 'iPhone 15 Pro Max (430x932)',
          child: sessionPlaceholderGolden(const Size(430, 932)),
        ),
      ],
    ),
  );
}

Widget sessionPlaceholderGolden(Size size) {
  const session = _fullSession;

  return SizedBox(
    width: size.width,
    height: size.height,
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: buildSariTheme(),
          child: SessionPlaceholderScreen(
            sessionController: SessionController(FakeSessionStore(session)),
            sessionOverride: session,
          ),
        ),
      ),
    ),
  );
}
