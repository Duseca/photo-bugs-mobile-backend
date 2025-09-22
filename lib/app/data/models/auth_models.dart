import 'package:photo_bug/app/data/models/user_model.dart';

// Login Request Model
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

// Register Request Model - Updated to match your API structure
class RegisterRequest {
  final String name;
  final String userName;
  final String profilePicture;
  final String email;
  final String password;
  final String phone;
  final String deviceToken;
  final String stripeAccountId;
  final String role;
  final String gender;
  final DateTime dob;
  final Map<String, String> address;
  final Map<String, List<double>> location;
  final String bio;
  final List<String> interests;
  final Map<String, bool> settings;
  final List<String> favourites;
  final List<StoragePurchase> storagePurchases;

  RegisterRequest({
    required this.name,
    required this.userName,
    required this.profilePicture,
    required this.email,
    required this.password,
    required this.phone,
    required this.deviceToken,
    required this.stripeAccountId,
    required this.role,
    required this.gender,
    required this.dob,
    required this.address,
    required this.location,
    required this.bio,
    required this.interests,
    required this.settings,
    required this.favourites,
    required this.storagePurchases,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'user_name': userName,
      'profile_picture': profilePicture,
      'email': email,
      'password': password,
      'phone': phone,
      'device_token': deviceToken,
      'stripe_account_id': stripeAccountId,
      'role': role,
      'gender': gender,
      'dob': dob.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
      'address': address,
      'location': location,
      'bio': bio,
      'interests': interests,
      'settings': settings,
      'favourites': favourites,
      'storagePurchases': storagePurchases.map((e) => e.toJson()).toList(),
    };
  }
}

// Storage Purchase Model - For registration data
class StoragePurchase {
  final int bytes;
  final double amountPaid;
  final DateTime date;

  StoragePurchase({
    required this.bytes,
    required this.amountPaid,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'bytes': bytes,
      'amountPaid': amountPaid,
      'date': date.toIso8601String(),
    };
  }

  factory StoragePurchase.fromJson(Map<String, dynamic> json) {
    return StoragePurchase(
      bytes: json['bytes'] ?? 0,
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      date: DateTime.parse(json['date']),
    );
  }
}

// Email Verification Request Model
class EmailVerificationRequest {
  final String email;
  final String code;

  EmailVerificationRequest({required this.email, required this.code});

  Map<String, dynamic> toJson() {
    return {'email': email, 'code': code};
  }
}

// Send Email Request Model
class SendEmailRequest {
  final String email;

  SendEmailRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

// Update Password Request Model
class UpdatePasswordRequest {
  final String currentPassword;
  final String newPassword;

  UpdatePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {'currentPassword': currentPassword, 'newPassword': newPassword};
  }
}

// Update User Request Model
class UpdateUserRequest {
  final String? name;
  final String? userName;
  final String? phone;
  final String? role;
  final String? gender;
  final DateTime? dob;
  final Map<String, String>? address;
  final Map<String, List<double>>? location;
  final String? bio;
  final List<String>? interests;
  final Map<String, bool>? settings;

  UpdateUserRequest({
    this.name,
    this.userName,
    this.phone,
    this.role,
    this.gender,
    this.dob,
    this.address,
    this.location,
    this.bio,
    this.interests,
    this.settings,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (userName != null) data['user_name'] = userName;
    if (phone != null) data['phone'] = phone;
    if (role != null) data['role'] = role;
    if (gender != null) data['gender'] = gender;
    if (dob != null) data['dob'] = dob!.toIso8601String().split('T')[0];
    if (address != null) data['address'] = address;
    if (location != null) data['location'] = location;
    if (bio != null) data['bio'] = bio;
    if (interests != null) data['interests'] = interests;
    if (settings != null) data['settings'] = settings;

    return data;
  }
}

// Auth Response Model
class AuthResponse {
  final bool success;
  final String? message;
  final String? token;
  final User? user;

  AuthResponse({required this.success, this.message, this.token, this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'user': user?.toJson(),
    };
  }
}

// Storage Info Model
class StorageInfo {
  final double totalStorage; // in GB
  final double usedStorage; // in GB
  final double availableStorage; // in GB
  final double storagePercentage;
  final List<StoragePurchase>? purchases;

  StorageInfo({
    required this.totalStorage,
    required this.usedStorage,
    required this.availableStorage,
    required this.storagePercentage,
    this.purchases,
  });

  factory StorageInfo.fromJson(Map<String, dynamic> json) {
    final total = (json['totalStorage'] ?? 0).toDouble();
    final used = (json['usedStorage'] ?? 0).toDouble();
    final available = total - used;
    final percentage = total > 0 ? (used / total) * 100 : 0.0;

    return StorageInfo(
      totalStorage: total,
      usedStorage: used,
      availableStorage: available,
      storagePercentage: percentage,
      purchases:
          json['purchases'] != null
              ? (json['purchases'] as List)
                  .map((e) => StoragePurchase.fromJson(e))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStorage': totalStorage,
      'usedStorage': usedStorage,
      'availableStorage': availableStorage,
      'storagePercentage': storagePercentage,
      'purchases': purchases?.map((e) => e.toJson()).toList(),
    };
  }
}

// Purchase Storage Request Model
class PurchaseStorageRequest {
  final int gigabytes;

  PurchaseStorageRequest({required this.gigabytes});

  Map<String, dynamic> toJson() {
    return {'gigabytes': gigabytes};
  }
}

// Generic API Response Model
class ApiResponse<T> {
  final bool success;
  final String? message;
  final String? error;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? metadata;

  ApiResponse({
    required this.success,
    this.message,
    this.error,
    this.data,
    this.statusCode,
    this.metadata,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      error: json['error'],
      data:
          json['data'] != null && fromJsonT != null
              ? fromJsonT(json['data'])
              : json['data'],
      statusCode: json['statusCode'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'error': error,
      'data': data,
      'statusCode': statusCode,
      'metadata': metadata,
    };
  }
}

// Helper class for creating default values
class AuthModelDefaults {
  static RegisterRequest createDefaultRegisterRequest({
    required String name,
    required String userName,
    required String email,
    required String password,
    required String phone,
    String? profilePicture,
    String? deviceToken,
    String role = 'creator',
    String gender = 'male',
    DateTime? dob,
    Map<String, String>? address,
    List<double>? coordinates,
    String? bio,
    List<String>? interests,
  }) {
    return RegisterRequest(
      name: name,
      userName: userName,
      profilePicture: profilePicture ?? '',
      email: email,
      password: password,
      phone: phone,
      deviceToken: deviceToken ?? '',
      stripeAccountId: '',
      role: role,
      gender: gender,
      dob: dob ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      address: address ?? {'country': '', 'town': '', 'address': ''},
      location: {
        'coordinates': coordinates ?? [0.0, 0.0],
      },
      bio: bio ?? '',
      interests: interests ?? [],
      settings: {
        'general': true,
        'sound': true,
        'vibrate': true,
        'updated': true,
      },
      favourites: [],
      storagePurchases: [],
    );
  }

  static StoragePurchase createDefaultStoragePurchase({
    int bytes = 104857600, // 100MB default
    double amountPaid = 0.0,
    DateTime? date,
  }) {
    return StoragePurchase(
      bytes: bytes,
      amountPaid: amountPaid,
      date: date ?? DateTime.now(),
    );
  }
}
