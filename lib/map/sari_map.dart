import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../session/location_point.dart';

extension TileLayerUserAgent on TileLayer {
  String get userAgentPackageName {
    final header = tileProvider.headers['User-Agent'];
    if (header == null) {
      return '';
    }
    final start = header.indexOf('(');
    final end = header.lastIndexOf(')');
    if (start == -1 || end <= start) {
      return header;
    }
    return header.substring(start + 1, end);
  }
}

class SariMap extends StatelessWidget {
  const SariMap({
    super.key,
    this.center = DefaultLocations.modaKadikoy,
    this.zoom = defaultZoom,
    this.tileProvider,
    this.layers = const <Widget>[],
    this.interactive = true,
  });

  static const defaultZoom = 15.0;
  static const tileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const userAgentPackageName = 'tr.byteflow.sari';

  final LocationPoint center;
  final double zoom;
  final TileProvider? tileProvider;
  final List<Widget> layers;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(center.latitude, center.longitude),
        initialZoom: zoom,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: tileUrlTemplate,
          userAgentPackageName: userAgentPackageName,
          tileProvider: tileProvider ?? NetworkTileProvider(),
        ),
        ...layers,
      ],
    );
  }
}
