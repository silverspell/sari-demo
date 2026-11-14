import 'package:flutter/foundation.dart';

import 'completed_trip.dart';
import 'trip_history_store.dart';

class TripHistoryController extends ChangeNotifier {
  TripHistoryController(this._store);

  final TripHistoryStore _store;

  List<CompletedTrip> _trips = const [];

  /// En yeni tamamlanan yolculuk önce gelecek şekilde sıralı görünüm.
  ///
  /// Depo kayıtları ekleme sırasını korur; eşit tamamlanma zamanlarında son
  /// kaydedilen yolculuk öne geçer.
  List<CompletedTrip> get trips {
    final indexed = _trips.indexed.toList()
      ..sort((a, b) {
        final byCompletedAt = b.$2.completedAt.compareTo(a.$2.completedAt);
        if (byCompletedAt != 0) {
          return byCompletedAt;
        }
        return b.$1.compareTo(a.$1);
      });
    return List<CompletedTrip>.unmodifiable(indexed.map((entry) => entry.$2));
  }

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
