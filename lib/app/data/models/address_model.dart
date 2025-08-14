class Address {
  final String? country;
  final String? town;
  final String? address;

  Address({this.country, this.town, this.address});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      country: json['country'],
      town: json['town'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (country != null) 'country': country,
      if (town != null) 'town': town,
      if (address != null) 'address': address,
    };
  }

  Address copyWith({String? country, String? town, String? address}) {
    return Address(
      country: country ?? this.country,
      town: town ?? this.town,
      address: address ?? this.address,
    );
  }

  @override
  String toString() {
    return 'Address{country: $country, town: $town, address: $address}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address &&
          runtimeType == other.runtimeType &&
          country == other.country &&
          town == other.town &&
          address == other.address;

  @override
  int get hashCode => country.hashCode ^ town.hashCode ^ address.hashCode;
}
