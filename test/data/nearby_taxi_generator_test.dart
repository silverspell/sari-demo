import 'package:flutter_test/flutter_test.dart';
import 'package:sari/data/nearby_taxi_generator.dart';
import 'package:sari/session/location_point.dart';

void main() {
  const generator = NearbyTaxiGenerator();

  group('NearbyTaxiGenerator', () {
    test('AC4: aynı seed aynı sayı ve aynı konum/ETA dizilimini üretir', () {
      final first = generator.generate(
        areaLabel: 'Moda',
        center: DefaultLocations.modaKadikoy,
      );
      final second = generator.generate(
        areaLabel: 'Moda',
        center: DefaultLocations.modaKadikoy,
      );

      expect(first.taxis, hasLength(42));
      expect(second.taxis, hasLength(first.taxis.length));
      for (var index = 0; index < first.taxis.length; index++) {
        expect(first.taxis[index].id, second.taxis[index].id);
        expect(first.taxis[index].location, second.taxis[index].location);
        expect(first.taxis[index].etaMinutes, second.taxis[index].etaMinutes);
      }
    });

    test('rozet metinleri sahte taksi kümesinden okunur', () {
      final taxis = generator.generate(
        areaLabel: 'Moda',
        center: DefaultLocations.modaKadikoy,
      );

      expect(taxis.countLabel, 'Moda • 42 Taksi');
      expect(taxis.nearestEtaLabel, 'En yakın 2 dk');
    });
  });
}
