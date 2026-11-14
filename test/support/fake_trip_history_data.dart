import 'package:sari/data/fake_driver.dart';
import 'package:sari/data/fake_place.dart';
import 'package:sari/session/location_point.dart';
import 'package:sari/trips/completed_trip.dart';
import 'package:sari/trips/in_memory_trip_history_store.dart';
import 'package:sari/trips/trip_history_controller.dart';

final DateTime fakeTripHistoryNow = DateTime(2023, 11, 15, 12);

const fakeModa = FakePlace(
  id: 'moda',
  name: 'Moda',
  address: 'Moda, Kadıköy',
  location: LocationPoint(latitude: 40.9812, longitude: 29.0255),
);

const fakeKadikoyIskele = FakePlace(
  id: 'kadikoy-iskele',
  name: 'Kadıköy İskele',
  address: 'Caferağa, Kadıköy',
  location: LocationPoint(latitude: 40.9906, longitude: 29.0233),
);

const fakeTaksim = FakePlace(
  id: 'taksim-meydani',
  name: 'Taksim Meydanı',
  address: 'Gümüşsuyu, Beyoğlu',
  location: LocationPoint(latitude: 41.0369, longitude: 28.9850),
);

const fakeKanyon = FakePlace(
  id: 'kanyon-avm',
  name: 'Kanyon AVM',
  address: 'Levent, Beşiktaş',
  location: LocationPoint(latitude: 41.0789, longitude: 29.0103),
);

const fakeKadikoy = FakePlace(
  id: 'kadikoy',
  name: 'Kadıköy',
  address: 'Kadıköy',
  location: LocationPoint(latitude: 40.9906, longitude: 29.0233),
);

const fakeSabihaGokcen = FakePlace(
  id: 'sabiha-gokcen',
  name: 'Sabiha Gökçen Havalimanı',
  address: 'Sanayi, Pendik',
  location: LocationPoint(latitude: 40.8986, longitude: 29.3092),
);

const fakeMurat = FakeDriver(
  name: 'Murat K.',
  plate: '34 TB 4201',
  rating: 5.0,
  vehicle: 'Fiat Egea',
);

const fakeAhmet = FakeDriver(
  name: 'Ahmet Y.',
  plate: '34 TJ 8912',
  rating: 4.8,
  vehicle: 'Renault Clio',
);

const fakeCemil = FakeDriver(
  name: 'Cemil D.',
  plate: '34 TAA 04',
  rating: 5.0,
  vehicle: 'Toyota Corolla',
);

final fakeTrips = <CompletedTrip>[
  CompletedTrip(
    destination: fakeKadikoyIskele,
    departureLabel: 'Moda',
    distanceMeters: 2800,
    duration: const Duration(minutes: 12),
    completedAt: DateTime(2023, 11, 12, 9, 14),
    amountLira: 92,
    driver: fakeMurat,
    rating: 5.0,
  ),
  CompletedTrip(
    destination: fakeKanyon,
    departureLabel: 'Taksim Meydanı',
    distanceMeters: 8400,
    duration: const Duration(minutes: 21),
    completedAt: DateTime(2023, 11, 10, 18, 40),
    amountLira: 240,
    driver: fakeAhmet,
    rating: 4.8,
  ),
  CompletedTrip(
    destination: fakeSabihaGokcen,
    departureLabel: 'Kadıköy',
    distanceMeters: 31400,
    duration: const Duration(minutes: 35),
    completedAt: DateTime(2023, 11, 7, 6, 5),
    amountLira: 610,
    driver: fakeCemil,
    rating: 5.0,
  ),
];

Future<TripHistoryController> createSeededTripHistoryController({
  Iterable<CompletedTrip>? trips,
}) async {
  final controller = TripHistoryController(InMemoryTripHistoryStore());
  for (final trip in trips ?? fakeTrips) {
    await controller.save(trip);
  }
  return controller;
}
