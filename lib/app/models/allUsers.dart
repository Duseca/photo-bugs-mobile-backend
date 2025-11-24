class AllUsersResponse {
  final bool success;
  final int count;
  final int total;
  final int totalPages;
  final int currentPage;
  final List<UserBasicInfo> data;

  AllUsersResponse({
    required this.success,
    required this.count,
    required this.total,
    required this.totalPages,
    required this.currentPage,
    required this.data,
  });

  factory AllUsersResponse.fromJson(Map<String, dynamic> json) {
    return AllUsersResponse(
      success: json['success'] ?? false,
      count: json['count'] ?? 0,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      currentPage: json['currentPage'] ?? 1,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => UserBasicInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class UserBasicInfo {
  final String id;
  final String name;
  final String userName;
  final String? profilePicture;
  final String email;
  final String? phone;
  final String role;
  final List<String>? interests;

  UserBasicInfo({
    required this.id,
    required this.name,
    required this.userName,
    this.profilePicture,
    required this.email,
    this.phone,
    required this.role,
    this.interests,
  });

  factory UserBasicInfo.fromJson(Map<String, dynamic> json) {
    return UserBasicInfo(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      userName:
          json['user_name']?.toString() ?? json['userName']?.toString() ?? '',
      profilePicture: json['profile_picture']?.toString(),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'creator',
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user_name': userName,
      'profile_picture': profilePicture,
      'email': email,
      'phone': phone,
      'role': role,
      'interests': interests,
    };
  }

  // Display name for UI
  String get displayName => name.isNotEmpty ? name : userName;

  // Search text for filtering
  String get searchText =>
      '${name.toLowerCase()} ${userName.toLowerCase()} ${email.toLowerCase()}';

  @override
  String toString() {
    return 'UserBasicInfo{id: $id, name: $name, userName: $userName, email: $email}';
  }
}
