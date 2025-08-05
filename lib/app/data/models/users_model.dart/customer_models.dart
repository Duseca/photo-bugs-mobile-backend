class CustomerModel {
  final String id; // Unique ID for the customer
  final String name; // Full name of the customer
  final String email; // Email address
  final String phoneNumber; // Contact number
  final String address; // Customer's address
  final String city; // City of residence
  final String postalCode; // Postal/ZIP code
  final String profileImageUrl; // URL for the profile image
  final String dateOfBirth; // Date of birth (optional)
  final DateTime createdAt; // When the customer was created
  final DateTime updatedAt; // Last updated details

  // Constructor
  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.postalCode,
    this.profileImageUrl = '', // Default empty
    this.dateOfBirth = '', // Default empty
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method for creating a Customer object from a JSON map
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      city: json['city'],
      postalCode: json['postalCode'],
      profileImageUrl: json['profileImageUrl'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Method to convert a Customer object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'profileImageUrl': profileImageUrl,
      'dateOfBirth': dateOfBirth,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
