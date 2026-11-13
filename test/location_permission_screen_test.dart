import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/main.dart';
import 'package:sari/permissions/location_permission_service.dart';
import 'package:sari/router/app_routes.dart';
import 'package:sari/screens/location_permission_screen.dart';
import 'package:sari/screens/session_placeholder_screen.dart';
import 'package:sari/session/location_point.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/session_controller.dart';
import 'package:sari/theme/sari_theme.dart';

import 'support/fake_location_permission_service.dart';
import 'support/fake_session_store.dart';

const _title = 'Konumunu kullanalım';
const _body =
    'Taksini kapına getirebilmemiz ve en hızlı rotayı çizebilmemiz için '
    'konumuna ihtiyacımız var.';
const _benefitOneTitle = 'En yakın taksiyi anında bul';
const _benefitOneSubtitle = 'Semtindeki aktif sarı taksileri canlı gör';
const _benefitTwoTitle = 'Adres yazmadan tek tıkla çağır';
const _benefitTwoSubtitle = 'Olduğun noktaya saniyeler içinde araç yönlendir';
const _trustNote = 'Konumun yalnızca yolculuk süresince paylaşılır';

const _seededSession = Session(
  phone: '+905551112233',
  name: 'Şükrü',
  surname: '',
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
  FakeLocationPermissionService? permissionService,
  Size size = const Size(430, 932),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final controller = SessionController(
    store ?? FakeSessionStore(_seededSession),
  );
  await controller.load();

  await tester.pumpWidget(
    SariApp(
      sessionController: controller,
      locationPermissionService:
          permissionService ?? FakeLocationPermissionService(),
    ),
  );
  await tester.pumpAndSettle();

  return controller;
}

Future<void> goToLocationPermission(WidgetTester tester) async {
  final context = tester.element(find.byType(Scaffold).first);
  GoRouter.of(context).go(AppRoutes.locationPermission);
  await tester.pumpAndSettle();

  expect(find.byType(LocationPermissionScreen), findsOneWidget);
}

void main() {
  testWidgets('tasarım içeriği görünür ve izin istemez', (tester) async {
    final permissionService = FakeLocationPermissionService();
    await pumpApp(tester, permissionService: permissionService);
    await goToLocationPermission(tester);

    expect(permissionService.requestCount, 0);

    expect(find.text(_title), findsOneWidget);
    expect(find.text(_body), findsOneWidget);
    expect(find.text('TAKSİ'), findsOneWidget);
    expect(find.text('GPS Hazır'), findsOneWidget);
    expect(find.text(_benefitOneTitle), findsOneWidget);
    expect(find.text(_benefitOneSubtitle), findsOneWidget);
    expect(find.text(_benefitTwoTitle), findsOneWidget);
    expect(find.text(_benefitTwoSubtitle), findsOneWidget);
    expect(find.text(_trustNote), findsOneWidget);
    expect(find.text('Konumu aç'), findsOneWidget);
    expect(find.text('Şimdi değil'), findsOneWidget);

    expect(find.byIcon(Icons.local_taxi), findsOneWidget);
    expect(find.byIcon(Icons.near_me), findsOneWidget);
    expect(find.byIcon(Icons.touch_app), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
    expect(find.byIcon(Icons.verified_user_outlined), findsOneWidget);
    expect(find.byIcon(Icons.my_location), findsOneWidget);

    expect(find.byKey(LocationPermissionScreen.allowButtonKey), findsOneWidget);
    expect(
      find.byKey(LocationPermissionScreen.notNowButtonKey),
      findsOneWidget,
    );
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(BackButton), findsNothing);
    expect(find.byTooltip('Geri dön'), findsNothing);
  });

  testWidgets(
    'Konumu aç izin verir, Taksim koordinatını yazar ve oturuma gider',
    (tester) async {
      final permissionService = FakeLocationPermissionService(
        decision: LocationPermissionDecision.granted,
      );
      final store = FakeSessionStore(_seededSession);
      final controller = await pumpApp(
        tester,
        store: store,
        permissionService: permissionService,
      );
      await goToLocationPermission(tester);

      await tester.tap(find.byKey(LocationPermissionScreen.allowButtonKey));
      await tester.pumpAndSettle();

      expect(permissionService.requestCount, 1);
      expect(
        controller.session?.locationPermission,
        LocationPermissionStatus.granted,
      );
      expect(controller.session?.location, DefaultLocations.taksimMeydani);
      expect(controller.session?.phone, '+905551112233');
      expect(controller.session?.name, 'Şükrü');
      expect(controller.hasCompletedSession, isTrue);
      expect(locationOf(tester), AppRoutes.session);
      expect(find.byType(SessionPlaceholderScreen), findsOneWidget);
    },
  );

  testWidgets('Konumu aç reddedilince Taksim ile oturuma gider', (
    tester,
  ) async {
    final permissionService = FakeLocationPermissionService(
      decision: LocationPermissionDecision.denied,
    );
    final store = FakeSessionStore(_seededSession);
    final controller = await pumpApp(
      tester,
      store: store,
      permissionService: permissionService,
    );
    await goToLocationPermission(tester);

    await tester.tap(find.byKey(LocationPermissionScreen.allowButtonKey));
    await tester.pumpAndSettle();

    expect(permissionService.requestCount, 1);
    expect(
      controller.session?.locationPermission,
      LocationPermissionStatus.denied,
    );
    expect(controller.session?.location, DefaultLocations.taksimMeydani);
    expect(locationOf(tester), AppRoutes.session);
    expect(find.byType(SessionPlaceholderScreen), findsOneWidget);
  });

  testWidgets('Şimdi değil izin istemez, reddedildi ve Taksim yazar', (
    tester,
  ) async {
    final permissionService = FakeLocationPermissionService();
    final store = FakeSessionStore(_seededSession);
    final controller = await pumpApp(
      tester,
      store: store,
      permissionService: permissionService,
    );
    await goToLocationPermission(tester);

    await tester.tap(find.byKey(LocationPermissionScreen.notNowButtonKey));
    await tester.pumpAndSettle();

    expect(permissionService.requestCount, 0);
    expect(
      controller.session?.locationPermission,
      LocationPermissionStatus.denied,
    );
    expect(controller.session?.location, DefaultLocations.taksimMeydani);
    expect(controller.hasCompletedSession, isTrue);
    expect(locationOf(tester), AppRoutes.session);
    expect(find.byType(SessionPlaceholderScreen), findsOneWidget);
  });

  testWidgets('oturum yokken çökmeden varsayılanları yazar', (tester) async {
    final permissionService = FakeLocationPermissionService(
      decision: LocationPermissionDecision.denied,
    );
    final store = FakeSessionStore();
    await pumpApp(tester, store: store, permissionService: permissionService);
    await goToLocationPermission(tester);

    await tester.tap(find.byKey(LocationPermissionScreen.allowButtonKey));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(store.session?.locationPermission, LocationPermissionStatus.denied);
    expect(store.session?.location, DefaultLocations.taksimMeydani);
  });

  for (final size in const [Size(375, 667), Size(430, 932)]) {
    testWidgets('taşma yok ${size.width.toInt()}x${size.height.toInt()}', (
      tester,
    ) async {
      await pumpApp(tester, size: size);
      await goToLocationPermission(tester);

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(LocationPermissionScreen.screenKey)),
        size,
      );
      expect(
        tester
            .getBottomLeft(find.byKey(LocationPermissionScreen.allowButtonKey))
            .dy,
        lessThanOrEqualTo(size.height),
      );
      expect(
        tester
            .getBottomLeft(find.byKey(LocationPermissionScreen.notNowButtonKey))
            .dy,
        lessThanOrEqualTo(size.height),
      );
    });
  }

  goldenTest(
    'Konum izni ekranı',
    fileName: '04-location-permission',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'iPhone SE (375x667)',
          child: locationPermissionGolden(const Size(375, 667)),
        ),
        GoldenTestScenario(
          name: 'iPhone 15 Pro Max (430x932)',
          child: locationPermissionGolden(const Size(430, 932)),
        ),
      ],
    ),
  );
}

Widget locationPermissionGolden(Size size) {
  final controller = SessionController(FakeSessionStore(_seededSession));

  return SizedBox(
    width: size.width,
    height: size.height,
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: buildSariTheme(),
          child: LocationPermissionScreen(
            sessionController: controller,
            permissionService: FakeLocationPermissionService(),
          ),
        ),
      ),
    ),
  );
}
