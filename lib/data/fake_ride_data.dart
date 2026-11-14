import '../session/location_point.dart';
import 'fake_driver.dart';
import 'fake_place.dart';
import 'payment_method.dart';

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

  static const visa4242 = PaymentMethod(
    id: 'visa-4242',
    label: '•••• 4242',
    brand: 'Visa',
    expiryLabel: '08/28',
    isDefault: true,
  );

  static const mastercard5310 = PaymentMethod(
    id: 'mastercard-5310',
    label: '•••• 5310',
    brand: 'Mastercard',
    expiryLabel: '11/26',
  );

  static const nakit = PaymentMethod(
    id: 'nakit',
    label: 'Nakit',
    brand: 'Nakit',
  );

  static const paymentMethods = <PaymentMethod>[
    visa4242,
    mastercard5310,
    nakit,
  ];

  static PaymentMethod get defaultPaymentMethod =>
      paymentMethods.firstWhere((method) => method.isDefault);

  static const driver = FakeDriver(
    name: 'Mehmet Y.',
    plate: '34 TK 1923',
    rating: 4.9,
    vehicle: 'Fiat Egea',
  );

  static const driverApproachOrigin = LocationPoint(
    latitude: 40.9869,
    longitude: 29.0207,
  );

  static const driverApproachDistanceMeters = 750;

  static const homeAreaLabel = 'Moda';

  static const sampleOrigin = DefaultLocations.modaKadikoy;

  static const sampleDistanceMeters = 4800;

  static const rideSeed = 1923;

  static const rideSpeedLabel = '42 KM/S • Akıcı';

  static const fakeStartClockMinutes = 14 * 60 + 14;

  static const rideManeuvers = <String>[
    "350m sonra Moda Caddesi'ne dön",
    '200m sonra Rıhtım Caddesi çıkışı',
    "120m sonra İskele Meydanı'na devam",
    'Hedefe yaklaşıyorsun',
  ];

  static const _dativeNames = <String, String>{
    'kadikoy-iskele': "Kadıköy İskele'ye",
    'taksim-meydani': "Taksim Meydanı'na",
    'istanbul-havalimani': "İstanbul Havalimanı'na",
    'sabiha-gokcen': "Sabiha Gökçen Havalimanı'na",
    'kanyon-avm': "Kanyon AVM'ye",
    'ev': "Ev'e",
    'is': "İş'e",
  };

  static String dativeName(FakePlace place) =>
      _dativeNames[place.id] ?? _dativeSuffix(place.name);

  static String _dativeSuffix(String name) {
    if (name.isEmpty) {
      return name;
    }
    const vowels = 'aeıioöuü';
    const backVowels = 'aıou';
    final lower = name.toLowerCase();
    final lastVowel = lower
        .split('')
        .lastWhere((letter) => vowels.contains(letter), orElse: () => 'e');
    final endsWithVowel = vowels.contains(lower[lower.length - 1]);
    final suffix = backVowels.contains(lastVowel) ? 'a' : 'e';
    return "$name'${endsWithVowel ? 'y' : ''}$suffix";
  }
}
