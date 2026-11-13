import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:sari/map/sari_map.dart';
import 'package:sari/session/location_point.dart';

import '../support/fake_tile_provider.dart';

void main() {
  testWidgets('SariMap OpenStreetMap karolarını enjekte edilen sağlayıcıyla '
      'çizer ve ağa çıkmaz', (tester) async {
    tester.view.physicalSize = const Size(400, 400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final tileProvider = FakeTileProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SariMap(tileProvider: tileProvider)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(FlutterMap), findsOneWidget);

    final tileLayer = tester.widget<TileLayer>(find.byType(TileLayer));
    expect(tileLayer.userAgentPackageName, 'tr.byteflow.sari');
    expect(tileLayer.tileProvider, same(tileProvider));
    expect(
      tileLayer.urlTemplate,
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    );
    expect(tileProvider.requestCount, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('SariMap varsayılan olarak Moda Kadıköy merkezini kullanır', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SariMap(tileProvider: FakeTileProvider())),
      ),
    );
    await tester.pump();

    final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
    expect(
      map.options.initialCenter,
      LatLng(
        DefaultLocations.modaKadikoy.latitude,
        DefaultLocations.modaKadikoy.longitude,
      ),
    );
    expect(map.options.initialZoom, SariMap.defaultZoom);
  });

  testWidgets('SariMap verilen MapController ile hareket eder ve onMapReady '
      'çağırır', (tester) async {
    final controller = MapController();
    var readyCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SariMap(
            tileProvider: FakeTileProvider(),
            mapController: controller,
            onMapReady: () => readyCount++,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(readyCount, 1);

    const target = LocationPoint(latitude: 40.9901, longitude: 29.0302);
    final moved = controller.move(
      LatLng(target.latitude, target.longitude),
      16,
    );
    await tester.pump();

    expect(moved, isTrue);
    expect(controller.camera.center.latitude, closeTo(target.latitude, 1e-9));
    expect(controller.camera.center.longitude, closeTo(target.longitude, 1e-9));
    expect(controller.camera.zoom, 16);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SariMap karoları animasyonsuz gösterir', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SariMap(tileProvider: FakeTileProvider())),
      ),
    );
    await tester.pump();

    final tileLayer = tester.widget<TileLayer>(find.byType(TileLayer));
    expect(tileLayer.tileDisplay, isA<InstantaneousTileDisplay>());
  });
}
