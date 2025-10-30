class GoogleTokens {
  final String accessToken;
  final int expiryDate;

  GoogleTokens({required this.accessToken, required this.expiryDate});

  factory GoogleTokens.fromJson(Map<String, dynamic> json) {
    return GoogleTokens(
      accessToken: json['access_token'] ?? '',
      expiryDate: json['expiry_date'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'expiry_date': expiryDate};
  }

  GoogleTokens copyWith({String? accessToken, int? expiryDate}) {
    return GoogleTokens(
      accessToken: accessToken ?? this.accessToken,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  bool get isExpired {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= expiryDate;
  }

  @override
  String toString() {
    return 'GoogleTokens{accessToken: ${accessToken.substring(0, 20)}..., expiryDate: $expiryDate, isExpired: $isExpired}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoogleTokens &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          expiryDate == other.expiryDate;

  @override
  int get hashCode => accessToken.hashCode ^ expiryDate.hashCode;
}
