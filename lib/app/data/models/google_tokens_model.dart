class GoogleTokens {
  final String? accessToken;
  final int? expiryDate;

  GoogleTokens({this.accessToken, this.expiryDate});

  factory GoogleTokens.fromJson(Map<String, dynamic> json) {
    return GoogleTokens(
      accessToken: json['access_token'] as String?,
      expiryDate: json['expiry_date'] as int? ?? json['expires_in'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (accessToken != null) 'access_token': accessToken,
      if (expiryDate != null) 'expiry_date': expiryDate,
    };
  }

  GoogleTokens copyWith({String? accessToken, int? expiryDate}) {
    return GoogleTokens(
      accessToken: accessToken ?? this.accessToken,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  bool get isExpired {
    if (expiryDate == null) return true;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= expiryDate!;
  }

  bool get isValid {
    return accessToken != null && !isExpired;
  }

  @override
  String toString() {
    final accessTokenPreview =
        accessToken != null
            ? '${accessToken!.substring(0, accessToken!.length > 20 ? 20 : accessToken!.length)}...'
            : 'null';
    return 'GoogleTokens{accessToken: $accessTokenPreview, expiryDate: $expiryDate, isExpired: $isExpired, isValid: $isValid}';
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
