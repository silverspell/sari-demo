enum RideClass {
  sari(
    label: 'Sarı',
    capacity: 4,
    description: 'Klasik sarı taksi',
    fareMultiplier: 1.0,
  ),
  turkuaz(
    label: 'Turkuaz',
    capacity: 4,
    description: 'Turkuaz taksi',
    fareMultiplier: 1.16,
  );

  const RideClass({
    required this.label,
    required this.capacity,
    required this.description,
    required this.fareMultiplier,
  });

  final String label;
  final int capacity;
  final String description;
  final double fareMultiplier;
}
