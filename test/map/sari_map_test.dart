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
}
