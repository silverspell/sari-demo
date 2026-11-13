import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/data/nearby_taxi_generator.dart';
import 'package:sari/permissions/location_permission_service.dart';
import 'package:sari/screens/home_screen.dart';
import 'package:sari/session/location_point.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/session_controller.dart';
import 'package:sari/theme/sari_theme.dart';

import 'support/fake_location_permission_service.dart';
import 'support/fake_location_service.dart';
import 'support/fake_session_store.dart';
import 'support/fake_tile_provider.dart';

const _grantedSession = Session(
  phone: '+905551112233',
  name: 'Ayşe',
  surname: 'Yılmaz',
  locationPermission: LocationPermissionStatus.granted,
  location: DefaultLocations.modaKadikoy,
);

const _deniedSession = Session(
  phone: '+905551112233',
  name: 'Ayşe',
  surname: 'Yılmaz',
  locationPermission: LocationPermissionStatus.denied,
);

const _fixedLocation = LocationPoint(latitude: 40.9901, longitude: 29.0302);

Future<SessionController> pumpHome(
  WidgetTester tester, {
  Session? session = _grantedSession,
  FakeLocationPermissionService? permissionService,
  FakeLocationService? locationService,
  NearbyTaxiGenerator nearbyTaxiGenerator = const NearbyTaxiGenerator(),
  MapController? mapController,
  Size size = const Size(430, 932),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final controller = SessionController(FakeSessionStore(session));
  await controller.load();

  await tester.pumpWidget(
    MaterialApp(
      theme: buildSariTheme(),
      home: HomeScreen(
        sessionController: controller,
        permissionService: permissionService ?? FakeLocationPermissionService(),
        locationService: locationService ?? FakeLocationService(),
        nearbyTaxiGenerator: nearbyTaxiGenerator,
        tileProvider: FakeTileProvider(),
        mapController: mapController,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();

  return controller;
}

List<LatLng> taxiMarkerPoints(WidgetTester tester) {
  final layer = tester.widget<MarkerLayer>(
    find.byKey(HomeScreen.taxiMarkerLayerKey),
  );
  return layer.markers.map((marker) => marker.point).toList();
}

void main() {
  testWidgets('ana ekran haritayı, kullanıcıyı ve taksileri gösterir', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.byKey(HomeScreen.screenKey), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byType(MarkerLayer), findsNWidgets(2));
    expect(find.byKey(HomeScreen.taxiMarkerLayerKey), findsOneWidget);
    expect(find.byKey(HomeScreen.userMarkerLayerKey), findsOneWidget);
    expect(find.text('Buradasınız'), findsOneWidget);
    expect(find.text('Moda • 42 Taksi'), findsOneWidget);
    expect(find.text('En yakın 2 dk'), findsOneWidget);
    expect(find.text('Sarı'), findsOneWidget);
    expect(find.text('Taksi Çağır'), findsOneWidget);
    expect(find.text('Merhaba Ayşe'), findsOneWidget);
    expect(find.textContaining('Yılmaz'), findsNothing);
    expect(find.text('Günün nasıldı? Nereye gidiyoruz?'), findsOneWidget);
    expect(find.text('Nereye?'), findsOneWidget);
    expect(find.text('Karaköy'), findsOneWidget);
    expect(find.text('Ev'), findsOneWidget);
    expect(find.text('18 dk'), findsOneWidget);
    expect(find.text('İş'), findsOneWidget);
    expect(find.text('Levent'), findsOneWidget);
    expect(find.text('Ekle'), findsOneWidget);
    expect(find.text('Taksi çağır'), findsOneWidget);
    expect(find.text('SARI'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selamlama kırpılmış adı kullanır ve oturum yoksa Yolcu der', (
    tester,
  ) async {
    await pumpHome(
      tester,
      session: const Session(
        phone: '+905551112233',
        name: '  Ayşe  ',
        surname: 'Yılmaz',
        locationPermission: LocationPermissionStatus.granted,
        location: DefaultLocations.modaKadikoy,
      ),
    );

    expect(find.text('Merhaba Ayşe'), findsOneWidget);

    await pumpHome(tester, session: null);

    expect(find.text('Merhaba Yolcu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sabit seed her açılışta aynı taksi dizilimini üretir', (
    tester,
  ) async {
    await pumpHome(tester);
    final firstPoints = taxiMarkerPoints(tester);

    expect(firstPoints, hasLength(42));
    final expected = const NearbyTaxiGenerator().generate(
      areaLabel: FakeRideData.homeAreaLabel,
      center: DefaultLocations.modaKadikoy,
    );
    expect(
      firstPoints,
      expected.taxis
          .map(
            (taxi) => LatLng(taxi.location.latitude, taxi.location.longitude),
          )
          .toList(),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    await pumpHome(tester);
    expect(taxiMarkerPoints(tester), firstPoints);
  });

  testWidgets('izin verilmezse harita varsayılan Moda merkezinde açılır', (
    tester,
  ) async {
    final permissionService = FakeLocationPermissionService(
      decision: LocationPermissionDecision.denied,
    );
    final locationService = FakeLocationService(location: _fixedLocation);

    await pumpHome(
      tester,
      session: _deniedSession,
      permissionService: permissionService,
      locationService: locationService,
    );

    final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
    expect(
      map.options.initialCenter,
      LatLng(
        DefaultLocations.modaKadikoy.latitude,
        DefaultLocations.modaKadikoy.longitude,
      ),
    );
    final userLayer = tester.widget<MarkerLayer>(
      find.byKey(HomeScreen.userMarkerLayerKey),
    );
    expect(
      userLayer.markers.single.point,
      LatLng(
        DefaultLocations.modaKadikoy.latitude,
        DefaultLocations.modaKadikoy.longitude,
      ),
    );
    expect(permissionService.requestCount, 0);
    expect(locationService.callCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bildirim, avatar, Ekle ve menü Yakında bildirimi gösterir', (
    tester,
  ) async {
    await pumpHome(tester);

    for (final key in [
      HomeScreen.notificationButtonKey,
      HomeScreen.avatarButtonKey,
      HomeScreen.addChipKey,
      HomeScreen.menuButtonKey,
    ]) {
      await tester.tap(find.byKey(key));
      await tester.pump();

      expect(find.text('Yakında'), findsOneWidget, reason: '$key');

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Yakında'), findsNothing, reason: '$key');
    }

    expect(find.byKey(HomeScreen.screenKey), findsOneWidget);
    expect(find.text('Merhaba Ayşe'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Nereye, Karaköy ve Taksi çağır ertelenir ve Yakında gösterir', (
    tester,
  ) async {
    await pumpHome(tester);

    for (final key in [
      HomeScreen.searchButtonKey,
      HomeScreen.karakoyChipKey,
      HomeScreen.callTaxiButtonKey,
      HomeScreen.etaPillKey,
      HomeScreen.cityBadgeKey,
    ]) {
      await tester.tap(find.byKey(key));
      await tester.pump();

      expect(find.text('Yakında'), findsOneWidget, reason: '$key');

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    }

    expect(find.byKey(HomeScreen.screenKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('izin varsa yeniden merkezleme kullanıcı konumuna taşır', (
    tester,
  ) async {
    final mapController = MapController();
    final permissionService = FakeLocationPermissionService(
      decision: LocationPermissionDecision.denied,
    );
    final locationService = FakeLocationService(location: _fixedLocation);

    final controller = await pumpHome(
      tester,
      permissionService: permissionService,
      locationService: locationService,
      mapController: mapController,
    );

    await tester.tap(find.byKey(HomeScreen.recenterButtonKey));
    await tester.pumpAndSettle();

    expect(permissionService.requestCount, 0);
    expect(locationService.callCount, 1);
    expect(
      controller.session?.locationPermission,
      LocationPermissionStatus.granted,
    );
    expect(controller.session?.location, _fixedLocation);
    expect(
      mapController.camera.center.latitude,
      closeTo(_fixedLocation.latitude, 1e-9),
    );
    expect(
      mapController.camera.center.longitude,
      closeTo(_fixedLocation.longitude, 1e-9),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('izin yoksa yeniden merkezleme izin ister ve reddedilince '
      'harita yerinde kalır', (tester) async {
    final mapController = MapController();
    final permissionService = FakeLocationPermissionService(
      decision: LocationPermissionDecision.denied,
    );
    final locationService = FakeLocationService(location: _fixedLocation);

    final controller = await pumpHome(
      tester,
      session: _deniedSession,
      permissionService: permissionService,
      locationService: locationService,
      mapController: mapController,
    );
    final before = mapController.camera.center;

    await tester.tap(find.byKey(HomeScreen.recenterButtonKey));
    await tester.pumpAndSettle();

    expect(permissionService.requestCount, 1);
    expect(locationService.callCount, 0);
    expect(
      controller.session?.locationPermission,
      LocationPermissionStatus.denied,
    );
    expect(controller.session?.location, isNull);
    expect(mapController.camera.center, before);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'izin istekte verilirse yeniden merkezleme konumu alır ve taşır',
    (tester) async {
      final mapController = MapController();
      final permissionService = FakeLocationPermissionService(
        decision: LocationPermissionDecision.granted,
      );
      final locationService = FakeLocationService(location: _fixedLocation);

      final controller = await pumpHome(
        tester,
        session: _deniedSession,
        permissionService: permissionService,
        locationService: locationService,
        mapController: mapController,
      );

      await tester.tap(find.byKey(HomeScreen.recenterButtonKey));
      await tester.pumpAndSettle();

      expect(permissionService.requestCount, 1);
      expect(locationService.callCount, 1);
      expect(
        controller.session?.locationPermission,
        LocationPermissionStatus.granted,
      );
      expect(controller.session?.location, _fixedLocation);
      expect(
        mapController.camera.center.latitude,
        closeTo(_fixedLocation.latitude, 1e-9),
      );
      expect(
        mapController.camera.center.longitude,
        closeTo(_fixedLocation.longitude, 1e-9),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('konum servisi hata verirse yeniden merkezleme çökmez', (
    tester,
  ) async {
    final mapController = MapController();
    final permissionService = FakeLocationPermissionService(
      decision: LocationPermissionDecision.granted,
    );
    final locationService = FakeLocationService(error: Exception('konum yok'));

    await pumpHome(
      tester,
      session: _deniedSession,
      permissionService: permissionService,
      locationService: locationService,
      mapController: mapController,
    );
    final before = mapController.camera.center;

    await tester.tap(find.byKey(HomeScreen.recenterButtonKey));
    await tester.pumpAndSettle();

    expect(locationService.callCount, 1);
    expect(mapController.camera.center, before);
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(375, 667), Size(430, 932)]) {
    testWidgets('taşma yok ${size.width.toInt()}x${size.height.toInt()}', (
      tester,
    ) async {
      await pumpHome(tester, size: size);

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(HomeScreen.screenKey)), size);
      expect(
        tester.getBottomLeft(find.byKey(HomeScreen.callTaxiButtonKey)).dy,
        lessThanOrEqualTo(size.height),
      );
      expect(find.text('Merhaba Ayşe'), findsOneWidget);
    });
  }
}
