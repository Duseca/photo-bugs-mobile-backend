import 'package:photo_bug/app/data/models/address_model.dart';
import 'package:photo_bug/app/data/models/location_model.dart';
import 'package:photo_bug/app/data/models/user_setting_model.dart';
import 'package:photo_bug/app/data/models/google_tokens_model.dart';

class User {
  final String? id;
  final String name;
  final String userName;
  final String email;
  final String? phone;
  final String? profilePicture;
  final String? role;
  final String? gender;
  final DateTime? dateOfBirth;
  final Address? address;
  final Location? location;
  final String? bio;
  final List<String>? interests;
  final UserSettings? settings;
  final List<String>? favorites;
  final GoogleTokens? googleTokens;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isEmailVerified;

  User({
    this.id,
    required this.name,
    required this.userName,
    required this.email,
    this.phone,
    this.profilePicture,
    this.role,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.location,
    this.bio,
    this.interests,
    this.settings,
    this.favorites,
    this.googleTokens,
    this.createdAt,
    this.updatedAt,
    this.isEmailVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Debug print to see raw JSON
    print('🔵 User.fromJson - Raw favorites data: ${json['favorites']}');
    print('🔵 User.fromJson - Raw favourites data: ${json['favourites']}');

    // Parse favorites with multiple fallbacks
    List<String>? parsedFavorites;

    // Try 'favorites' first (American spelling)
    if (json['favorites'] != null) {
      parsedFavorites = _parseFavoritesField(json['favorites']);
      if (parsedFavorites != null) {
        print(
          '✅ Parsed ${parsedFavorites.length} favorites from "favorites" field',
        );
      }
    }

    // Try 'favourites' (British spelling) as fallback
    if (parsedFavorites == null && json['favourites'] != null) {
      parsedFavorites = _parseFavoritesField(json['favourites']);
      if (parsedFavorites != null) {
        print(
          '✅ Parsed ${parsedFavorites.length} favorites from "favourites" field',
        );
      }
    }

    // Debug final result
    if (parsedFavorites != null && parsedFavorites.isNotEmpty) {
      print('✅ Final favorites list: $parsedFavorites');
    } else {
      print('⚠️ No favorites found in JSON');
    }

    return User(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      userName: json['user_name'] ?? json['userName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profilePicture: json['profile_picture'] ?? json['profilePicture'],
      role: json['role'],
      gender: json['gender'],
      dateOfBirth: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      bio: json['bio'],
      interests:
          json['interests'] != null
              ? List<String>.from(json['interests'])
              : null,
      settings:
          json['settings'] != null
              ? UserSettings.fromJson(json['settings'])
              : null,
      favorites: parsedFavorites, // Use the parsed favorites
      googleTokens:
          json['googleTokens'] != null
              ? GoogleTokens.fromJson(json['googleTokens'])
              : null,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      isEmailVerified: json['isEmailVerified'] ?? json['is_email_verified'],
    );
  }

  /// Parse favorites field - handles both array of strings and array of objects
  static List<String>? _parseFavoritesField(dynamic favoritesData) {
    if (favoritesData == null) return null;

    if (favoritesData is! List) {
      print('⚠️ Favorites data is not a list: ${favoritesData.runtimeType}');
      return null;
    }

    if (favoritesData.isEmpty) {
      print('⚠️ Favorites list is empty');
      return [];
    }

    try {
      // Check if first element is a String or an Object
      final firstElement = favoritesData.first;

      if (firstElement is String) {
        // ✅ Array of strings: ["id1", "id2", ...]
        print('📝 Parsing favorites as array of strings');
        return List<String>.from(favoritesData);
      } else if (firstElement is Map) {
        // ✅ Array of objects: [{_id: "id1", name: "..."}, ...]
        print('📝 Parsing favorites as array of objects');

        final favoriteIds = <String>[];

        for (final item in favoritesData) {
          if (item is Map<String, dynamic>) {
            // Try to get ID from multiple possible fields
            final id = item['_id'] ?? item['id'] ?? item['user_id'];

            if (id != null && id is String) {
              favoriteIds.add(id);
              print('   ✅ Extracted ID: $id (Name: ${item['name']})');
            } else {
              print('   ⚠️ Could not extract ID from: $item');
            }
          }
        }

        return favoriteIds.isNotEmpty ? favoriteIds : null;
      } else {
        print('⚠️ Unknown favorites format: ${firstElement.runtimeType}');
        return null;
      }
    } catch (e) {
      print('❌ Error parsing favorites: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'user_name': userName,
      'email': email,
      if (phone != null) 'phone': phone,
      if (profilePicture != null) 'profile_picture': profilePicture,
      if (role != null) 'role': role,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'dob': dateOfBirth!.toIso8601String(),
      if (address != null) 'address': address!.toJson(),
      if (location != null) 'location': location!.toJson(),
      if (bio != null) 'bio': bio,
      if (interests != null) 'interests': interests,
      if (settings != null) 'settings': settings!.toJson(),
      if (favorites != null) 'favorites': favorites,
      if (googleTokens != null) 'googleTokens': googleTokens!.toJson(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (isEmailVerified != null) 'isEmailVerified': isEmailVerified,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? userName,
    String? email,
    String? phone,
    String? profilePicture,
    String? role,
    String? gender,
    DateTime? dateOfBirth,
    Address? address,
    Location? location,
    String? bio,
    List<String>? interests,
    UserSettings? settings,
    List<String>? favorites,
    GoogleTokens? googleTokens,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      settings: settings ?? this.settings,
      favorites: favorites ?? this.favorites,
      googleTokens: googleTokens ?? this.googleTokens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, userName: $userName, email: $email, phone: $phone, bio: $bio, favorites: ${favorites?.length ?? 0}, updatedAt: $updatedAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
