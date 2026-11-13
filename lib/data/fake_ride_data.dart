import '../session/location_point.dart';
import 'fake_driver.dart';
import 'fake_place.dart';

abstract final class FakeRideData {
  static const kadikoyIskele = FakePlace(
    id: 'kadikoy-iskele',
    name: 'Kadıköy İskele',
    address: 'Caferağa, Kadıköy',
    location: LocationPoint(latitude: 40.9906, longitude: 29.0233),
  );

  static const taksim = FakePlace(
    id: 'taksim-meydani',
    name: 'Taksim Meydanı',
    address: 'Gümüşsuyu, Beyoğlu',
    location: LocationPoint(latitude: 41.0369, longitude: 28.9850),
  );

  static const istanbulHavalimani = FakePlace(
    id: 'istanbul-havalimani',
    name: 'İstanbul Havalimanı (IST)',
    address: 'Tayakadın, Arnavutköy',
    location: LocationPoint(latitude: 41.2753, longitude: 28.7519),
  );

  static const sabihaGokcen = FakePlace(
    id: 'sabiha-gokcen',
    name: 'Sabiha Gökçen Havalimanı (SAW)',
    address: 'Sanayi, Pendik',
    location: LocationPoint(latitude: 40.8986, longitude: 29.3092),
  );

  static const kanyonAvm = FakePlace(
    id: 'kanyon-avm',
    name: 'Kanyon AVM',
    address: 'Levent, Beşiktaş',
    location: LocationPoint(latitude: 41.0789, longitude: 29.0103),
  );

  static const places = <FakePlace>[
    kadikoyIskele,
    taksim,
    istanbulHavalimani,
    sabihaGokcen,
    kanyonAvm,
  ];

  static const ev = FakePlace(
    id: 'ev',
    name: 'Ev',
    address: 'Moda, Kadıköy',
    location: LocationPoint(latitude: 40.9812, longitude: 29.0255),
  );

  static const isYeri = FakePlace(
    id: 'is',
    name: 'İş',
    address: 'Levent, Beşiktaş',
    location: LocationPoint(latitude: 41.0810, longitude: 29.0090),
  );

  static const savedPlaces = <FakePlace>[ev, isYeri];

  static const driver = FakeDriver(
    name: 'Mehmet Y.',
    plate: '34 TK 1923',
    rating: 4.9,
    vehicle: 'Fiat Egea',
  );

  static const homeAreaLabel = 'Moda';

  static const sampleOrigin = DefaultLocations.modaKadikoy;

  static const sampleDistanceMeters = 4800;
}
