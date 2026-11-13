import 'package:flutter/foundation.dart';

import '../data/fake_place.dart';
import '../data/ride_class.dart';
import '../data/route_fare_calculator.dart';
import '../data/route_quote.dart';
import '../session/location_point.dart';

class RideFlowController extends ChangeNotifier {
  RideFlowController({
    LocationPoint origin = DefaultLocations.modaKadikoy,
    FakePlace? destination,
    RideClass selectedRideClass = RideClass.sari,
    RouteFareCalculator calculator = const RouteFareCalculator(),
  }) : _origin = origin,
       _destination = destination,
       _selectedRideClass = selectedRideClass,
       _calculator = calculator;

  final RouteFareCalculator _calculator;

  final LocationPoint _origin;
  FakePlace? _destination;
  RideClass _selectedRideClass;

  LocationPoint get origin => _origin;

  FakePlace? get destination => _destination;

  RideClass get selectedRideClass => _selectedRideClass;

  RouteQuote? get quote {
    final destination = _destination;
    if (destination == null) {
      return null;
    }
    return _calculator.quote(origin: _origin, destination: destination);
  }

  void selectDestination(FakePlace destination) {
    _destination = destination;
    _selectedRideClass = RideClass.sari;
    notifyListeners();
  }

  void selectRideClass(RideClass rideClass) {
    if (_selectedRideClass == rideClass) {
      return;
    }
    _selectedRideClass = rideClass;
    notifyListeners();
  }
}
