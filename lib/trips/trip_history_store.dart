import 'completed_trip.dart';

abstract interface class TripHistoryStore {
  Future<List<CompletedTrip>> read();

  Future<void> write(List<CompletedTrip> trips);

  Future<void> clear();
}
