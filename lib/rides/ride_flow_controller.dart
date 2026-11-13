import 'package:flutter/foundation.dart';

import '../data/fake_place.dart';
import '../data/ride_class.dart';
import '../data/route_fare_calculator.dart';
import '../data/route_quote.dart';
import '../session/location_point.dart';
import 'ride_feedback_tag.dart';

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
  final Set<RideFeedbackTag> _tags = <RideFeedbackTag>{};
  FakePlace? _destination;
  RideClass _selectedRideClass;
  int? _rating;

  LocationPoint get origin => _origin;

  FakePlace? get destination => _destination;

  RideClass get selectedRideClass => _selectedRideClass;

  int? get rating => _rating;

  Set<RideFeedbackTag> get tags => Set.unmodifiable(_tags);

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
    _rating = null;
    _tags.clear();
    notifyListeners();
  }

  void selectRideClass(RideClass rideClass) {
    if (_selectedRideClass == rideClass) {
      return;
    }
    _selectedRideClass = rideClass;
    notifyListeners();
  }

  void selectRating(int rating) {
    final clamped = rating.clamp(1, 5);
    if (_rating == clamped) {
      return;
    }
    _rating = clamped;
    notifyListeners();
  }

  void toggleTag(RideFeedbackTag tag) {
    if (!_tags.remove(tag)) {
      _tags.add(tag);
    }
    notifyListeners();
  }

  void clearFeedback() {
    if (_rating == null && _tags.isEmpty) {
      return;
    }
    _rating = null;
    _tags.clear();
    notifyListeners();
  }
}
