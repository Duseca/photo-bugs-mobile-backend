class GoogleTokens {
  final String? accessToken;
  final String? refreshToken;
  final String? idToken;
  final int? expiryDate;
  final String? scope;
  final String? tokenType;

  GoogleTokens({
    this.accessToken,
    this.refreshToken,
    this.idToken,
    this.expiryDate,
    this.scope,
    this.tokenType,
  });

  factory GoogleTokens.fromJson(Map<String, dynamic> json) {
    return GoogleTokens(
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      idToken: json['id_token'] as String?,
      expiryDate: json['expiry_date'] as int? ?? json['expires_in'] as int?,
      scope: json['scope'] as String?,
      tokenType: json['token_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (accessToken != null) 'access_token': accessToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
      if (idToken != null) 'id_token': idToken,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (scope != null) 'scope': scope,
      if (tokenType != null) 'token_type': tokenType,
    };
  }

  GoogleTokens copyWith({
    String? accessToken,
    String? refreshToken,
    String? idToken,
    int? expiryDate,
    String? scope,
    String? tokenType,
  }) {
    return GoogleTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      idToken: idToken ?? this.idToken,
      expiryDate: expiryDate ?? this.expiryDate,
      scope: scope ?? this.scope,
      tokenType: tokenType ?? this.tokenType,
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
    return 'GoogleTokens{accessToken: $accessTokenPreview, refreshToken: ${refreshToken != null ? "present" : "null"}, idToken: ${idToken != null ? "present" : "null"}, expiryDate: $expiryDate, isExpired: $isExpired, scope: $scope, tokenType: $tokenType}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoogleTokens &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          idToken == other.idToken &&
          expiryDate == other.expiryDate &&
          scope == other.scope &&
          tokenType == other.tokenType;

  @override
  int get hashCode =>
      accessToken.hashCode ^
      refreshToken.hashCode ^
      idToken.hashCode ^
      expiryDate.hashCode ^
      scope.hashCode ^
      tokenType.hashCode;
}
