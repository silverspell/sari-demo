import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

const _transparentPixel =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk'
    '+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

class FakeTileProvider extends TileProvider {
  int requestCount = 0;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    requestCount++;
    return MemoryImage(base64Decode(_transparentPixel));
  }
}
