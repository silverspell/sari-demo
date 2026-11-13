import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/data/ride_class.dart';
import 'package:sari/rides/ride_flow_controller.dart';
import 'package:sari/screens/driver_found_screen.dart';
import 'package:sari/session/location_point.dart';
import 'package:sari/theme/sari_theme.dart';

import 'support/fake_tile_provider.dart';

Future<void> pumpDriverFound(
  WidgetTester tester, {
  RideFlowController? flowController,
  MapController? mapController,
  Size size = const Size(430, 932),
  Duration arrivalDuration = const Duration(hours: 1),
  bool animationsEnabled = false,
  double animationFrame = 0.68,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: buildSariTheme(),
      home: DriverFoundScreen(
        flowController: flowController,
        mapController: mapController,
        tileProvider: FakeTileProvider(),
        arrivalDuration: arrivalDuration,
        animationsEnabled: animationsEnabled,
        animationFrame: animationFrame,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  if (!animationsEnabled) {
    await tester.pumpAndSettle();
  }
}

String fareText(WidgetTester tester) {
  final text = tester.widget<Text>(find.byKey(DriverFoundScreen.fareTextKey));
  return text.data ?? '';
}

void main() {
  testWidgets('tek sürücü kaynağını ve Sarı ücretini gösterir', (tester) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);

    await pumpDriverFound(tester, flowController: flow);

    expect(find.byKey(DriverFoundScreen.screenKey), findsOneWidget);
    expect(find.text('Sürücü Yolda'), findsOneWidget);
    expect(find.byKey(DriverFoundScreen.mapKey), findsOneWidget);
    expect(find.byKey(DriverFoundScreen.statusPillKey), findsOneWidget);
    expect(find.text('Sürücü yolda · 750 m'), findsOneWidget);
    expect(find.byKey(DriverFoundScreen.headingKey), findsOneWidget);
    expect(find.text('Taksin 3 dk içinde geliyor'), findsOneWidget);
    expect(
      find.text('Sürücün seni Kadıköy İskele noktasından alacak'),
      findsOneWidget,
    );
    expect(find.byKey(DriverFoundScreen.progressKey), findsOneWidget);
    expect(find.byKey(DriverFoundScreen.driverCardKey), findsOneWidget);
    expect(find.text('MY'), findsOneWidget);
    expect(find.text('Mehmet Y.'), findsOneWidget);
    expect(find.text('4,9'), findsOneWidget);
    expect(find.text('Fiat Egea · Sarı Taksi'), findsOneWidget);
    expect(find.text('TR 34 TK 1923'), findsOneWidget);
    expect(find.text('Taksi Güvenlik Koruması'), findsOneWidget);
    expect(find.text('Taksimetre kilitli güvencesi aktif'), findsOneWidget);
    expect(find.text('Sürücüyü Ara'), findsOneWidget);
    expect(find.text('Yolculuğu iptal et'), findsOneWidget);
    expect(find.byKey(DriverFoundScreen.polylineLayerKey), findsOneWidget);
    expect(find.byKey(DriverFoundScreen.driverMarkerLayerKey), findsOneWidget);
    expect(find.byKey(DriverFoundScreen.pickupMarkerLayerKey), findsOneWidget);
    expect(fareText(tester), '₺185,00');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Turkuaz sınıfı seçili ücreti gösterir', (tester) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele)
      ..selectRideClass(RideClass.turkuaz);

    await pumpDriverFound(tester, flowController: flow);

    expect(fareText(tester), '₺215,00');
    expect(tester.takeException(), isNull);
  });

  testWidgets('hedef yoksa Kadıköy İskele ücretini geri düşer', (tester) async {
    final flow = RideFlowController();

    await pumpDriverFound(tester, flowController: flow);

    expect(flow.destination, FakeRideData.kadikoyIskele);
    expect(find.text('Taksin 3 dk içinde geliyor'), findsOneWidget);
    expect(
      find.text('Sürücün seni Kadıköy İskele noktasından alacak'),
      findsOneWidget,
    );
    expect(fareText(tester), '₺185,00');
    expect(tester.takeException(), isNull);
  });

  testWidgets('ara, mesaj ve paylaş Yakında gösterir', (tester) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);

    await pumpDriverFound(tester, flowController: flow);

    await tester.tap(find.byKey(DriverFoundScreen.callButtonKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Yakında'), findsOneWidget);
    expect(find.byKey(DriverFoundScreen.screenKey), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byKey(DriverFoundScreen.messageButtonKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Yakında'), findsOneWidget);
    expect(find.byKey(DriverFoundScreen.screenKey), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byKey(DriverFoundScreen.shareButtonKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Yakında'), findsOneWidget);
    expect(find.byKey(DriverFoundScreen.screenKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Yolculuğu iptal et Yakında gösterir ve ekrandan ayrılmaz', (
    tester,
  ) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);

    await pumpDriverFound(tester, flowController: flow);

    await tester.tap(find.byKey(DriverFoundScreen.cancelButtonKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Yakında'), findsOneWidget);
    expect(find.byKey(DriverFoundScreen.screenKey), findsOneWidget);
    expect(find.text('Sürücü Yolda'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kısaltılmış varış sayacı hata vermeden tamamlanır', (
    tester,
  ) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);

    await pumpDriverFound(
      tester,
      flowController: flow,
      arrivalDuration: const Duration(milliseconds: 600),
      animationsEnabled: true,
      animationFrame: 0,
    );

    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byKey(DriverFoundScreen.screenKey), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    final progress = tester.widget<LinearProgressIndicator>(
      find.byKey(DriverFoundScreen.progressKey),
    );
    expect(progress.value, 1.0);
    expect(find.byKey(DriverFoundScreen.screenKey), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(DriverFoundScreen.screenKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('odak düğmesi sürücü yaklaşım rotasına sığdırır', (tester) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);
    final mapController = MapController();
    addTearDown(mapController.dispose);

    await pumpDriverFound(
      tester,
      flowController: flow,
      mapController: mapController,
    );

    mapController.move(const LatLng(-33.8688, 151.2093), 10);
    await tester.pump();

    await tester.tap(find.byKey(DriverFoundScreen.focusButtonKey));
    await tester.pump();

    final bounds = mapController.camera.visibleBounds;
    final approach = LatLng(
      FakeRideData.driverApproachOrigin.latitude,
      FakeRideData.driverApproachOrigin.longitude,
    );
    final pickup = LatLng(
      DefaultLocations.modaKadikoy.latitude,
      DefaultLocations.modaKadikoy.longitude,
    );

    expect(bounds.contains(approach), isTrue, reason: '$bounds');
    expect(bounds.contains(pickup), isTrue, reason: '$bounds');
    expect(tester.takeException(), isNull);
  });

  testWidgets('yaklaşım rotası sürücüden alış noktasına çizilir', (
    tester,
  ) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);

    await pumpDriverFound(tester, flowController: flow);

    final polylineLayer = tester.widget<PolylineLayer>(
      find.byKey(DriverFoundScreen.polylineLayerKey),
    );
    final points = polylineLayer.polylines.single.points;
    expect(
      points.first,
      LatLng(
        FakeRideData.driverApproachOrigin.latitude,
        FakeRideData.driverApproachOrigin.longitude,
      ),
    );
    expect(
      points.last,
      LatLng(
        DefaultLocations.modaKadikoy.latitude,
        DefaultLocations.modaKadikoy.longitude,
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('animasyon sırasında kapanış ticker hatası vermez', (
    tester,
  ) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);

    await pumpDriverFound(
      tester,
      flowController: flow,
      animationsEnabled: true,
      animationFrame: 0,
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(375, 667), Size(430, 932)]) {
    testWidgets('taşma yok ${size.width.toInt()}x${size.height.toInt()}', (
      tester,
    ) async {
      final flow = RideFlowController()
        ..selectDestination(FakeRideData.kadikoyIskele);

      await pumpDriverFound(tester, flowController: flow, size: size);

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(DriverFoundScreen.screenKey)), size);
      expect(
        tester.getBottomLeft(find.byKey(DriverFoundScreen.cancelButtonKey)).dy,
        lessThanOrEqualTo(size.height),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
