import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/rides/ride_flow_controller.dart';
import 'package:sari/screens/ride_screen.dart';
import 'package:sari/session/location_point.dart';
import 'package:sari/theme/sari_theme.dart';

import 'support/fake_tile_provider.dart';

Future<void> pumpRide(
  WidgetTester tester, {
  required Widget child,
  Size size = const Size(430, 932),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(theme: buildSariTheme(), home: child));
  await tester.pump();
}

RideFlowController _flow() =>
    RideFlowController()..selectDestination(FakeRideData.kadikoyIskele);

Widget _ride({
  RideFlowController? flowController,
  MapController? mapController,
  Duration rideDuration = const Duration(seconds: 1),
  int seed = FakeRideData.rideSeed,
  bool animationsEnabled = false,
  double animationFrame = 1 / 3,
}) {
  return RideScreen(
    flowController: flowController,
    mapController: mapController,
    tileProvider: FakeTileProvider(),
    rideDuration: rideDuration,
    seed: seed,
    animationsEnabled: animationsEnabled,
    animationFrame: animationFrame,
  );
}

LatLng _taxiPoint(WidgetTester tester) {
  final layer = tester.widget<MarkerLayer>(
    find.byKey(RideScreen.taxiMarkerLayerKey),
  );
  return layer.markers.single.point;
}

double? _progressValue(WidgetTester tester) {
  return tester
      .widget<LinearProgressIndicator>(find.byKey(RideScreen.progressBarKey))
      .value;
}

void main() {
  testWidgets('yolculuk ekranı canlı bilgileri ve eylemleri gösterir', (
    tester,
  ) async {
    await pumpRide(tester, child: _ride(flowController: _flow()));
    await tester.pumpAndSettle();

    expect(find.byKey(RideScreen.screenKey), findsOneWidget);
    expect(find.text('Yolculuk Başladı'), findsOneWidget);
    expect(find.byKey(RideScreen.mapKey), findsOneWidget);
    expect(find.byKey(RideScreen.routePolylineLayerKey), findsOneWidget);
    expect(find.byKey(RideScreen.taxiMarkerLayerKey), findsOneWidget);
    expect(find.byKey(RideScreen.destinationMarkerLayerKey), findsOneWidget);
    expect(find.text("Kadıköy İskele'ye gidiyorsun"), findsOneWidget);
    expect(find.text('200m sonra Rıhtım Caddesi çıkışı'), findsOneWidget);
    expect(find.byKey(RideScreen.speedPillKey), findsOneWidget);
    expect(find.text('42 KM/S • Akıcı'), findsOneWidget);
    expect(find.byKey(RideScreen.summaryKey), findsOneWidget);
    expect(find.text('Varışa 8 dk'), findsOneWidget);
    expect(find.text('Canlı'), findsOneWidget);
    expect(find.text('Tahmini varış: 14:22 · Kalan 3,2 km'), findsOneWidget);
    expect(find.byKey(RideScreen.progressBarKey), findsOneWidget);
    expect(_progressValue(tester), closeTo(1 / 3, 1e-9));
    expect(find.byKey(RideScreen.driverCardKey), findsOneWidget);
    expect(find.text('MY'), findsOneWidget);
    expect(find.text('Mehmet Y.'), findsOneWidget);
    expect(find.text('4,9'), findsOneWidget);
    expect(find.text('34 TK 1923'), findsWidgets);
    expect(find.text('Sarı Fiat Egea'), findsOneWidget);
    expect(find.byKey(RideScreen.callButtonKey), findsOneWidget);
    expect(find.byKey(RideScreen.shareButtonKey), findsOneWidget);
    expect(find.byKey(RideScreen.safetyCardKey), findsOneWidget);
    expect(find.text('Sürüş Koruması Aktif'), findsOneWidget);
    expect(
      find.text('Canlı GPS takibi 7/24 merkezde izleniyor'),
      findsOneWidget,
    );
    expect(find.byKey(RideScreen.detailsButtonKey), findsOneWidget);
    expect(find.byKey(RideScreen.shareJourneyButtonKey), findsOneWidget);
    expect(find.text('Yolculuğu sevdiklerinle paylaş'), findsOneWidget);
    expect(find.byKey(RideScreen.sosButtonKey), findsOneWidget);
    expect(find.byKey(RideScreen.focusButtonKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hedef yoksa Kadıköy İskele rotasına geri düşer', (tester) async {
    final flow = RideFlowController();

    await pumpRide(
      tester,
      child: _ride(flowController: flow, animationsEnabled: false),
    );
    await tester.pumpAndSettle();

    expect(flow.destination, FakeRideData.kadikoyIskele);
    expect(find.text("Kadıköy İskele'ye gidiyorsun"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('aynı seed aynı taksi hareketini üretir ve taksi hareket eder', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<List<LatLng>> record({required int seed}) async {
      final flow = _flow();
      await tester.pumpWidget(
        MaterialApp(
          theme: buildSariTheme(),
          home: _ride(
            flowController: flow,
            seed: seed,
            rideDuration: const Duration(seconds: 2),
            animationsEnabled: true,
          ),
        ),
      );
      await tester.pump();

      final points = <LatLng>[_taxiPoint(tester)];
      for (var index = 0; index < 4; index++) {
        await tester.pump(const Duration(milliseconds: 250));
        points.add(_taxiPoint(tester));
      }

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      return points;
    }

    final first = await record(seed: FakeRideData.rideSeed);
    final second = await record(seed: FakeRideData.rideSeed);

    expect(first, hasLength(5));
    for (var index = 0; index < first.length; index++) {
      expect(second[index].latitude, first[index].latitude);
      expect(second[index].longitude, first[index].longitude);
    }
    expect(
      first.first,
      isNot(first.last),
      reason: 'taksi sabit seed ile rotada hareket etmeli',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('kısaltılmış yolculukta kalan mesafe ve varış bilgisi ilerler', (
    tester,
  ) async {
    await pumpRide(
      tester,
      child: _ride(
        flowController: _flow(),
        rideDuration: const Duration(seconds: 1),
        animationsEnabled: true,
      ),
    );

    expect(find.text('Varışa 12 dk'), findsOneWidget);
    expect(find.text('Tahmini varış: 14:26 · Kalan 4,8 km'), findsOneWidget);
    expect(_progressValue(tester), 0.0);

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Varışa 6 dk'), findsOneWidget);
    expect(find.text('Tahmini varış: 14:20 · Kalan 2,4 km'), findsOneWidget);
    expect(_progressValue(tester), closeTo(0.5, 0.01));

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Varışa 0 dk'), findsOneWidget);
    expect(find.text('Tahmini varış: 14:14 · Kalan 0,0 km'), findsOneWidget);
    expect(_progressValue(tester), 1.0);
    expect(find.byKey(RideScreen.screenKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kısaltılmış yolculuk animasyonu hatasız tamamlanır', (
    tester,
  ) async {
    await pumpRide(
      tester,
      child: _ride(
        flowController: _flow(),
        rideDuration: const Duration(milliseconds: 300),
        animationsEnabled: true,
      ),
    );

    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byKey(RideScreen.screenKey), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    expect(_progressValue(tester), 1.0);
    expect(find.byKey(RideScreen.screenKey), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(RideScreen.screenKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('paylaş ve yakında eylemleri kısa bildirim gösterir', (
    tester,
  ) async {
    await pumpRide(tester, child: _ride(flowController: _flow()));
    await tester.pumpAndSettle();

    for (final key in const [
      RideScreen.sosButtonKey,
      RideScreen.callButtonKey,
      RideScreen.shareButtonKey,
      RideScreen.shareJourneyButtonKey,
      RideScreen.detailsButtonKey,
    ]) {
      await tester.tap(find.byKey(key));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Yakında'), findsOneWidget);
      expect(find.byKey(RideScreen.screenKey), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Detay ekrandan ayrılmadan Yakında gösterir', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      initialLocation: '/yolculukta',
      routes: [
        GoRoute(
          path: '/yolculukta',
          builder: (context, state) =>
              _ride(flowController: _flow(), animationsEnabled: false),
        ),
        GoRoute(
          path: '/baska',
          builder: (context, state) =>
              const Scaffold(body: Text('Başka ekran')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: buildSariTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(RideScreen.detailsButtonKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Yakında'), findsOneWidget);
    expect(find.byKey(RideScreen.screenKey), findsOneWidget);
    expect(find.text('Başka ekran'), findsNothing);
    expect(
      GoRouter.of(
        tester.element(find.byKey(RideScreen.screenKey)),
      ).routerDelegate.currentConfiguration.uri.toString(),
      '/yolculukta',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('odak düğmesi seçili rotanın tamamına sığdırır', (tester) async {
    final mapController = MapController();
    addTearDown(mapController.dispose);

    await pumpRide(
      tester,
      child: _ride(flowController: _flow(), mapController: mapController),
    );
    await tester.pumpAndSettle();

    mapController.move(const LatLng(-33.8688, 151.2093), 10);
    await tester.pump();

    await tester.tap(find.byKey(RideScreen.focusButtonKey));
    await tester.pump();

    final bounds = mapController.camera.visibleBounds;
    final origin = LatLng(
      DefaultLocations.modaKadikoy.latitude,
      DefaultLocations.modaKadikoy.longitude,
    );
    final destination = LatLng(
      FakeRideData.kadikoyIskele.location.latitude,
      FakeRideData.kadikoyIskele.location.longitude,
    );

    expect(bounds.contains(origin), isTrue, reason: '$bounds');
    expect(bounds.contains(destination), isTrue, reason: '$bounds');
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(375, 667), Size(430, 932)]) {
    testWidgets('taşma yok ${size.width.toInt()}x${size.height.toInt()}', (
      tester,
    ) async {
      await pumpRide(
        tester,
        size: size,
        child: _ride(flowController: _flow()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(RideScreen.screenKey)), size);
      expect(
        tester.getBottomLeft(find.byKey(RideScreen.shareJourneyButtonKey)).dy,
        lessThanOrEqualTo(size.height),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
