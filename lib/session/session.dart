enum LocationPermissionStatus { notRequested, granted, denied }

class Session {
  const Session({
    required this.phone,
    required this.name,
    required this.surname,
    this.locationPermission = LocationPermissionStatus.notRequested,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    final permissionName = json['locationPermission'];
    final locationPermission = LocationPermissionStatus.values.firstWhere(
      (status) => status.name == permissionName,
      orElse: () => LocationPermissionStatus.notRequested,
    );

    return Session(
      phone: json['phone'] as String? ?? '',
      name: json['name'] as String? ?? '',
      surname: json['surname'] as String? ?? '',
      locationPermission: locationPermission,
    );
  }

  final String phone;
  final String name;
  final String surname;
  final LocationPermissionStatus locationPermission;

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'name': name,
    'surname': surname,
    'locationPermission': locationPermission.name,
  };

  Session copyWith({
    String? phone,
    String? name,
    String? surname,
    LocationPermissionStatus? locationPermission,
  }) => Session(
    phone: phone ?? this.phone,
    name: name ?? this.name,
    surname: surname ?? this.surname,
    locationPermission: locationPermission ?? this.locationPermission,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Session &&
          other.phone == phone &&
          other.name == name &&
          other.surname == surname &&
          other.locationPermission == locationPermission;

  @override
  int get hashCode => Object.hash(phone, name, surname, locationPermission);
}
