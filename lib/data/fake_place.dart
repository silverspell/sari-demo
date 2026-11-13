import '../session/location_point.dart';

final class FakePlace {
  const FakePlace({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
  });

  final String id;
  final String name;
  final String address;
  final LocationPoint location;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FakePlace &&
          other.id == id &&
          other.name == name &&
          other.address == address &&
          other.location == location;

  @override
  int get hashCode => Object.hash(id, name, address, location);
}
