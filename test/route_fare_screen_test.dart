import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/data/ride_class.dart';
import 'package:sari/rides/ride_flow_controller.dart';
import 'package:sari/screens/route_fare_screen.dart';
import 'package:sari/session/location_point.dart';
import 'package:sari/theme/sari_theme.dart';

import 'support/fake_tile_provider.dart';

Future<void> pumpRouteFare(
  WidgetTester tester, {
  RideFlowController? flowController,
  MapController? mapController,
  Size size = const Size(430, 932),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: buildSariTheme(),
      home: RouteFareScreen(
        flowController: flowController,
        mapController: mapController,
        tileProvider: FakeTileProvider(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

String selectedFareText(WidgetTester tester) {
  final text = tester.widget<Text>(find.byKey(RouteFareScreen.selectedFareKey));
  return text.data ?? '';
}

void main() {
  testWidgets('haritada çıkıştan varışa rota çizer ve yol özetini gösterir', (
    tester,
  ) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);

    await pumpRouteFare(tester, flowController: flow);

    expect(find.byKey(RouteFareScreen.screenKey), findsOneWidget);
    expect(find.byKey(RouteFareScreen.polylineLayerKey), findsOneWidget);
    expect(find.byKey(RouteFareScreen.originMarkerLayerKey), findsOneWidget);
    expect(
      find.byKey(RouteFareScreen.destinationMarkerLayerKey),
      findsOneWidget,
    );

    final polylineLayer = tester.widget<PolylineLayer>(
      find.byKey(RouteFareScreen.polylineLayerKey),
    );
    final points = polylineLayer.polylines.single.points;
    expect(
      points.first,
      LatLng(
        DefaultLocations.modaKadikoy.latitude,
        DefaultLocations.modaKadikoy.longitude,
      ),
    );
    expect(
      points.last,
      LatLng(
        FakeRideData.kadikoyIskele.location.latitude,
        FakeRideData.kadikoyIskele.location.longitude,
      ),
    );

    expect(find.text('Kadıköy İskele'), findsOneWidget);
    expect(find.text('12 dk'), findsWidgets);
    expect(find.text('4,8 km'), findsWidgets);
    expect(find.text('₺185'), findsOneWidget);
    expect(find.text('Moda Sahil'), findsOneWidget);
    expect(find.text('İSKELE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('varsayılan seçim Sarıdır ve seçili ücret ₺185 gösterir', (
    tester,
  ) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);

    await pumpRouteFare(tester, flowController: flow);

    expect(flow.selectedRideClass, RideClass.sari);
    expect(find.byKey(RouteFareScreen.sariCardKey), findsOneWidget);
    expect(find.byKey(RouteFareScreen.turkuazCardKey), findsOneWidget);
    expect(selectedFareText(tester), '₺185');
    expect(find.text('Sarı Taksi'), findsOneWidget);
    expect(find.text('Turkuaz Taksi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Turkuaz karta dokunmak akışı ve seçili ücreti günceller', (
    tester,
  ) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);

    await pumpRouteFare(tester, flowController: flow);

    await tester.tap(find.byKey(RouteFareScreen.turkuazCardKey));
    await tester.pump();

    expect(flow.selectedRideClass, RideClass.turkuaz);
    expect(selectedFareText(tester), '₺215');

    await tester.tap(find.byKey(RouteFareScreen.sariCardKey));
    await tester.pump();

    expect(flow.selectedRideClass, RideClass.sari);
    expect(selectedFareText(tester), '₺185');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Değiştir Yakında gösterir ve ödeme satırı değişmez', (
    tester,
  ) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);

    await pumpRouteFare(tester, flowController: flow);

    await tester.tap(find.byKey(RouteFareScreen.changePaymentButtonKey));
    await tester.pump();

    expect(find.text('Yakında'), findsOneWidget);
    expect(find.text('Mastercard •••• 4242'), findsOneWidget);
    expect(find.byKey(RouteFareScreen.paymentRowKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Taksi Çağır Yakında gösterir ve rota ekranında kalır', (
    tester,
  ) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);

    await pumpRouteFare(tester, flowController: flow);

    await tester.tap(find.byKey(RouteFareScreen.callButtonKey));
    await tester.pump();

    expect(find.text('Yakında'), findsOneWidget);
    expect(find.byKey(RouteFareScreen.screenKey), findsOneWidget);
    expect(find.byKey(RouteFareScreen.polylineLayerKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('odak düğmesi kamerayı seçili rotanın tamamına sığdırır', (
    tester,
  ) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);
    final mapController = MapController();
    addTearDown(mapController.dispose);

    await pumpRouteFare(
      tester,
      flowController: flow,
      mapController: mapController,
    );

    mapController.move(const LatLng(-33.8688, 151.2093), 10);
    await tester.pump();

    await tester.tap(find.byKey(RouteFareScreen.focusButtonKey));
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

  testWidgets('hedef yoksa Kadıköy İskele rotasını geri düşer', (tester) async {
    final flow = RideFlowController();

    await pumpRouteFare(tester, flowController: flow);

    expect(flow.destination, FakeRideData.kadikoyIskele);
    expect(find.text('Kadıköy İskele'), findsOneWidget);
    expect(find.text('12 dk'), findsWidgets);
    expect(find.text('4,8 km'), findsWidgets);
    expect(find.text('₺185'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(375, 667), Size(430, 932)]) {
    testWidgets('taşma yok ${size.width.toInt()}x${size.height.toInt()}', (
      tester,
    ) async {
      final flow = RideFlowController()
        ..selectDestination(FakeRideData.kadikoyIskele);

      await pumpRouteFare(tester, flowController: flow, size: size);

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(RouteFareScreen.screenKey)), size);
      expect(
        tester
            .getBottomLeft(find.byKey(RouteFareScreen.meterNoticeKey))
            .dy,
        lessThanOrEqualTo(size.height),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
