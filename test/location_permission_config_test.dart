import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Konum izni yapılandırması', () {
    test('iOS açıklaması Türkçe ve dolu', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();

      final match = RegExp(
        r'<key>NSLocationWhenInUseUsageDescription</key>\s*<string>(.*?)</string>',
        dotAll: true,
      ).firstMatch(plist);

      expect(
        match,
        isNotNull,
        reason: 'NSLocationWhenInUseUsageDescription yok',
      );
      final description = match!.group(1)!.trim();
      expect(description, isNotEmpty);
      expect(description.toLowerCase(), contains('konum'));
    });

    test('Android izinleri tanımlı', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();

      expect(manifest, contains('android.permission.ACCESS_FINE_LOCATION'));
      expect(manifest, contains('android.permission.ACCESS_COARSE_LOCATION'));
    });
  });
}
