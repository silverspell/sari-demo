import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/data/ride_class.dart';
import 'package:sari/rides/ride_flow_controller.dart';
import 'package:sari/screens/finding_driver_screen.dart';
import 'package:sari/session/location_point.dart';
import 'package:sari/theme/sari_theme.dart';

import 'support/fake_tile_provider.dart';

Future<void> pumpFindingDriver(
  WidgetTester tester, {
  RideFlowController? flowController,
  MapController? mapController,
  Size size = const Size(430, 932),
  Duration waitDuration = const Duration(hours: 1),
  bool animationsEnabled = false,
  VoidCallback? onSearchComplete,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: buildSariTheme(),
      home: FindingDriverScreen(
        flowController: flowController,
        mapController: mapController,
        tileProvider: FakeTileProvider(),
        waitDuration: waitDuration,
        animationsEnabled: animationsEnabled,
        onSearchComplete: onSearchComplete,
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
  final text = tester.widget<Text>(find.byKey(FindingDriverScreen.fareTextKey));
  return text.data ?? '';
}

void main() {
  testWidgets('Sarı sınıfı rota özetini ve ücretini gösterir', (tester) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);

    await pumpFindingDriver(tester, flowController: flow);

    expect(find.byKey(FindingDriverScreen.screenKey), findsOneWidget);
    expect(find.text('Taksi Aranıyor'), findsOneWidget);
    expect(find.byKey(FindingDriverScreen.mapKey), findsOneWidget);
    expect(find.byKey(FindingDriverScreen.statusChipKey), findsOneWidget);
    expect(find.byKey(FindingDriverScreen.radarKey), findsOneWidget);
    expect(find.byKey(FindingDriverScreen.focusButtonKey), findsOneWidget);
    expect(find.byKey(FindingDriverScreen.summaryCardKey), findsOneWidget);
    expect(find.byKey(FindingDriverScreen.cancelButtonKey), findsOneWidget);
    expect(find.text('Yakındaki sürücülere bildiriliyor'), findsOneWidget);
    expect(find.text('Sana en yakın taksiyi arıyoruz…'), findsOneWidget);
    expect(find.textContaining('1-2 dakika'), findsOneWidget);
    expect(find.text('Sarı Taksi'), findsOneWidget);
    expect(find.text('Standart'), findsOneWidget);
    expect(find.text('Moda → Kadıköy İskele'), findsOneWidget);
    expect(find.text('Nakit/Kart'), findsOneWidget);
    expect(find.text('Aramayı İptal Et'), findsOneWidget);
    expect(fareText(tester), '₺185,00');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Turkuaz sınıfı seçili ücreti gösterir', (tester) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele)
      ..selectRideClass(RideClass.turkuaz);

    await pumpFindingDriver(tester, flowController: flow);

    expect(find.text('Turkuaz Taksi'), findsOneWidget);
    expect(fareText(tester), '₺215,00');
    expect(tester.takeException(), isNull);
  });

  testWidgets('hedef yoksa Kadıköy İskele rotasını geri düşer', (tester) async {
    final flow = RideFlowController();

    await pumpFindingDriver(tester, flowController: flow);

    expect(flow.destination, FakeRideData.kadikoyIskele);
    expect(find.text('Moda → Kadıköy İskele'), findsOneWidget);
    expect(fareText(tester), '₺185,00');
    expect(tester.takeException(), isNull);
  });

  testWidgets('iptal modalı açılır, devam edince arama sürer', (tester) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);
    var completedCount = 0;

    await pumpFindingDriver(
      tester,
      flowController: flow,
      waitDuration: const Duration(seconds: 2),
      onSearchComplete: () => completedCount++,
    );

    await tester.tap(find.byKey(FindingDriverScreen.cancelButtonKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(FindingDriverScreen.cancelDialogKey), findsOneWidget);
    expect(
      find.text('Taksi aramasını iptal etmek istiyor musun?'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Çevrendeki 4 taksi sürücüsüne çağrın iletildi. Ayrılırsan sıra kaybedebilirsin.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(FindingDriverScreen.confirmCancelKey), findsOneWidget);
    expect(find.byKey(FindingDriverScreen.resumeSearchKey), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(completedCount, 0);
    expect(find.byKey(FindingDriverScreen.screenKey), findsOneWidget);

    await tester.tap(find.byKey(FindingDriverScreen.resumeSearchKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(FindingDriverScreen.cancelDialogKey), findsNothing);
    expect(find.byKey(FindingDriverScreen.screenKey), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(completedCount, 1);
    expect(find.byKey(FindingDriverScreen.screenKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kısaltılmış bekleme tamamlanınca bir kez haber verir', (
    tester,
  ) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);
    var completedCount = 0;

    await pumpFindingDriver(
      tester,
      flowController: flow,
      waitDuration: const Duration(milliseconds: 500),
      onSearchComplete: () => completedCount++,
    );

    await tester.pump(const Duration(milliseconds: 250));
    expect(completedCount, 0);

    await tester.pump(const Duration(milliseconds: 300));
    expect(completedCount, 1);
    expect(find.byKey(FindingDriverScreen.screenKey), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(completedCount, 1);
    expect(find.byKey(FindingDriverScreen.screenKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('odak düğmesi kamerayı rotanın tamamına sığdırır', (
    tester,
  ) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);
    final mapController = MapController();
    addTearDown(mapController.dispose);

    await pumpFindingDriver(
      tester,
      flowController: flow,
      mapController: mapController,
    );

    mapController.move(const LatLng(-33.8688, 151.2093), 10);
    await tester.pump();

    await tester.tap(find.byKey(FindingDriverScreen.focusButtonKey));
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

  testWidgets('animasyon açıkken kapanış ticker ve zamanlayıcı hatası vermez', (
    tester,
  ) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);

    await pumpFindingDriver(
      tester,
      flowController: flow,
      animationsEnabled: true,
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

      await pumpFindingDriver(tester, flowController: flow, size: size);

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(FindingDriverScreen.screenKey)), size);
      expect(
        tester
            .getBottomLeft(find.byKey(FindingDriverScreen.cancelButtonKey))
            .dy,
        lessThanOrEqualTo(size.height),
      );

      await tester.tap(find.byKey(FindingDriverScreen.cancelButtonKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(FindingDriverScreen.cancelDialogKey), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(FindingDriverScreen.resumeSearchKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(FindingDriverScreen.screenKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
