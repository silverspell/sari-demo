import 'location_point.dart';

enum LocationPermissionStatus { notRequested, granted, denied }

class Session {
  const Session({
    required this.phone,
    required this.name,
    required this.surname,
    this.locationPermission = LocationPermissionStatus.notRequested,
    this.location,
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
      location: LocationPoint.tryParse(json['location']),
    );
  }

  final String phone;
  final String name;
  final String surname;
  final LocationPermissionStatus locationPermission;
  final LocationPoint? location;

  Map<String, dynamic> toJson() => {
    'phone': phone,
    'name': name,
    'surname': surname,
    'locationPermission': locationPermission.name,
    if (location != null) 'location': location!.toJson(),
  };

  Session copyWith({
    String? phone,
    String? name,
    String? surname,
    LocationPermissionStatus? locationPermission,
    LocationPoint? location,
  }) => Session(
    phone: phone ?? this.phone,
    name: name ?? this.name,
    surname: surname ?? this.surname,
    locationPermission: locationPermission ?? this.locationPermission,
    location: location ?? this.location,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Session &&
          other.phone == phone &&
          other.name == name &&
          other.surname == surname &&
          other.locationPermission == locationPermission &&
          other.location == location;

  @override
  int get hashCode =>
      Object.hash(phone, name, surname, locationPermission, location);
}
