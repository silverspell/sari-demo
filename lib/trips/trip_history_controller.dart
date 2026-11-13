import 'package:flutter/foundation.dart';

import 'completed_trip.dart';
import 'trip_history_store.dart';

class TripHistoryController extends ChangeNotifier {
  TripHistoryController(this._store);

  final TripHistoryStore _store;

  List<CompletedTrip> _trips = const [];

  List<CompletedTrip> get trips => List.unmodifiable(_trips);

  Future<void> load() async {
    _trips = await _store.read();
    notifyListeners();
  }

  Future<void> save(CompletedTrip trip) async {
    final updated = <CompletedTrip>[..._trips, trip];
    await _store.write(updated);
    _trips = updated;
    notifyListeners();
  }

  Future<void> clear() async {
    await _store.clear();
    _trips = const [];
    notifyListeners();
  }
}
