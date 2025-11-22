class GoogleTokens {
  final String? accessToken;
  final int? expiryDate;
  final String? serverAuthCode;

  GoogleTokens({this.accessToken, this.expiryDate, this.serverAuthCode});

  factory GoogleTokens.fromJson(Map<String, dynamic> json) {
    return GoogleTokens(
      accessToken: json['access_token'] as String?,
      expiryDate: json['expiry_date'] as int? ?? json['expires_in'] as int?,
      serverAuthCode: json['server_auth_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (accessToken != null) 'access_token': accessToken,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (serverAuthCode != null) 'server_auth_code': serverAuthCode,
    };
  }

  GoogleTokens copyWith({
    String? accessToken,
    int? expiryDate,
    String? serverAuthCode,
  }) {
    return GoogleTokens(
      accessToken: accessToken ?? this.accessToken,
      expiryDate: expiryDate ?? this.expiryDate,
      serverAuthCode: serverAuthCode ?? this.serverAuthCode,
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

    return 'GoogleTokens{'
        'accessToken: $accessTokenPreview, '
        'expiryDate: $expiryDate, '
        'serverAuthCode: $serverAuthCode, '
        'isExpired: $isExpired, '
        'isValid: $isValid'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoogleTokens &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          expiryDate == other.expiryDate &&
          serverAuthCode == other.serverAuthCode;

  @override
  int get hashCode =>
      accessToken.hashCode ^ expiryDate.hashCode ^ serverAuthCode.hashCode;
}
