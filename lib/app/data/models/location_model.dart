class Location {
  final List<double> coordinates; // [longitude, latitude]
  final String type;

  Location({required this.coordinates, this.type = 'Point'});

  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0.0;
  double get latitude => coordinates.length > 1 ? coordinates[1] : 0.0;

  factory Location.fromJson(Map<String, dynamic> json) {
    List<double> coords = [0.0, 0.0]; // Default empty coordinates

    // Handle coordinates field
    if (json['coordinates'] != null) {
      if (json['coordinates'] is List) {
        final coordList = json['coordinates'] as List;
        if (coordList.isNotEmpty) {
          coords =
              coordList.map((e) {
                if (e is num) return e.toDouble();
                if (e is String) return double.tryParse(e) ?? 0.0;
                return 0.0;
              }).toList();
        }
      }
    }

    return Location(coordinates: coords, type: json['type'] ?? 'Point');
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
