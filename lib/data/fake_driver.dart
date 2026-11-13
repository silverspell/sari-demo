final class FakeDriver {
  const FakeDriver({
    required this.name,
    required this.plate,
    required this.rating,
    required this.vehicle,
  });

  final String name;
  final String plate;
  final double rating;
  final String vehicle;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FakeDriver &&
          other.name == name &&
          other.plate == plate &&
          other.rating == rating &&
          other.vehicle == vehicle;

  @override
  int get hashCode => Object.hash(name, plate, rating, vehicle);
}
