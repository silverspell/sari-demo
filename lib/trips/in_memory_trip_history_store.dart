import 'completed_trip.dart';
import 'trip_history_store.dart';

final class InMemoryTripHistoryStore implements TripHistoryStore {
  List<CompletedTrip> _trips = const [];

  @override
  Future<List<CompletedTrip>> read() async => List.unmodifiable(_trips);

  @override
  Future<void> write(List<CompletedTrip> trips) async {
    _trips = List.of(trips);
  }

  @override
  Future<void> clear() async {
    _trips = const [];
  }
}
