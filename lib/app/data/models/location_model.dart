class Location {
  final List<double> coordinates; // [longitude, latitude]
  final String type;

  Location({required this.coordinates, this.type = 'Point'});

  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0.0;
  double get latitude => coordinates.length > 1 ? coordinates[1] : 0.0;

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      coordinates:
          json['coordinates'] != null
              ? List<double>.from(json['coordinates'].map((x) => x.toDouble()))
              : [0.0, 0.0],
      type: json['type'] ?? 'Point',
    );
  }

  factory Location.fromCoordinates(double longitude, double latitude) {
    return Location(coordinates: [longitude, latitude], type: 'Point');
  }

  Map<String, dynamic> toJson() {
    return {'coordinates': coordinates, 'type': type};
  }

  Location copyWith({List<double>? coordinates, String? type}) {
    return Location(
      coordinates: coordinates ?? this.coordinates,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'Location{coordinates: $coordinates, type: $type}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          coordinates.toString() == other.coordinates.toString() &&
          type == other.type;

  @override
  int get hashCode => coordinates.hashCode ^ type.hashCode;
}
