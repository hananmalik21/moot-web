class LocationsResponse {
  final String? message;
  final int? total;
  final List<Location> locations; // non-nullable, defaults to empty list

  LocationsResponse({
    this.message,
    this.total,
    List<Location>? data,
  }) : locations = data ?? [];

  factory LocationsResponse.fromJson(Map<String, dynamic> json) {
    return LocationsResponse(
      message: json['message'],
      total: json['total'],
      data: json['data'] != null
          ? (json['data'] as List)
          .map((locationJson) => Location.fromJson(locationJson))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'total': total,
      'data': locations.map((location) => location.toJson()).toList(),
    };
  }
}

class Location {
  final String id;
  final String? streetAddress;
  final String? city;
  final String? stateProvince;
  final String? country;
  final String? postalCode;
  final DateTime? createdDate;

  Location({
    required this.id,
    this.streetAddress,
    this.city,
    this.stateProvince,
    this.country,
    this.postalCode,
    this.createdDate,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdDate'];

    return Location(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      streetAddress: json['streetAddress'] as String?,
      city: json['city'] as String?,
      stateProvince: json['stateProvince'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      createdDate: _parseDate(rawDate),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'streetAddress': streetAddress,
      'city': city,
      'stateProvince': stateProvince,
      'country': country,
      'postalCode': postalCode,
      'createdDate': createdDate?.toIso8601String(),
    };
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
