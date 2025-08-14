// Login Request Model
import 'package:photo_bug/app/data/models/user_model.dart';

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

// Register Request Model
class RegisterRequest {
  final String name;
  final String userName;
  final String email;
  final String password;
  final String? phone;
  final String? profilePicture;

  RegisterRequest({
    required this.name,
    required this.userName,
    required this.email,
    required this.password,
    this.phone,
    this.profilePicture,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'user_name': userName,
      'email': email,
      'password': password,
      if (phone != null) 'phone': phone,
      if (profilePicture != null) 'profile_picture': profilePicture,
    };
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
}

// Storage Info Model
class StorageInfo {
  final double totalStorage; // in GB
  final double usedStorage; // in GB
  final double availableStorage; // in GB
  final double storagePercentage;

  StorageInfo({
    required this.totalStorage,
    required this.usedStorage,
    required this.availableStorage,
    required this.storagePercentage,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStorage': totalStorage,
      'usedStorage': usedStorage,
      'availableStorage': availableStorage,
      'storagePercentage': storagePercentage,
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
