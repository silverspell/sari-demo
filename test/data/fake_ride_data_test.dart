import 'package:flutter_test/flutter_test.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/session/location_point.dart';

void main() {
  group('FakeRideData', () {
    test('AC5: yer listesi gerekli beş yeri içerir', () {
      final ids = FakeRideData.places.map((place) => place.id).toSet();
      final names = FakeRideData.places.map((place) => place.name).toSet();

      expect(FakeRideData.places, hasLength(5));
      expect(
        ids,
        containsAll(<String>[
          'kadikoy-iskele',
          'taksim-meydani',
          'istanbul-havalimani',
          'sabiha-gokcen',
          'kanyon-avm',
        ]),
      );
      expect(
        names,
        containsAll(<String>[
          'Kadıköy İskele',
          'Taksim Meydanı',
          'İstanbul Havalimanı (IST)',
          'Sabiha Gökçen Havalimanı (SAW)',
          'Kanyon AVM',
        ]),
      );
    });

    test('AC6: tek sürücü kaynağı Mehmet Y. bilgilerini taşır', () {
      expect(FakeRideData.driver.name, 'Mehmet Y.');
      expect(FakeRideData.driver.plate, '34 TK 1923');
      expect(FakeRideData.driver.rating, 4.9);
      expect(FakeRideData.driver.vehicle, 'Fiat Egea');
    });

    test('sürücü yaklaşımı tek sahte kümede 750 metre olarak sabittir', () {
      expect(FakeRideData.driverApproachDistanceMeters, 750);
      expect(
        FakeRideData.driverApproachOrigin,
        isNot(DefaultLocations.modaKadikoy),
      );
    });

    test('kayıtlı yerler Ev ve İş (Levent) olarak sabittir', () {
      final names = FakeRideData.savedPlaces.map((place) => place.name).toSet();
      final isYeri = FakeRideData.savedPlaces.firstWhere(
        (place) => place.name == 'İş',
      );

      expect(names, containsAll(<String>['Ev', 'İş']));
      expect(isYeri.address, contains('Levent'));
    });
  });
}
