class UserSettings {
  final bool general;
  final bool sound;
  final bool vibrate;
  final bool updated;

  UserSettings({
    this.general = true,
    this.sound = true,
    this.vibrate = true,
    this.updated = true,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      general: json['general'] ?? true,
      sound: json['sound'] ?? true,
      vibrate: json['vibrate'] ?? true,
      updated: json['updated'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'general': general,
      'sound': sound,
      'vibrate': vibrate,
      'updated': updated,
    };
  }

  UserSettings copyWith({
    bool? general,
    bool? sound,
    bool? vibrate,
    bool? updated,
  }) {
    return UserSettings(
      general: general ?? this.general,
      sound: sound ?? this.sound,
      vibrate: vibrate ?? this.vibrate,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'UserSettings{general: $general, sound: $sound, vibrate: $vibrate, updated: $updated}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettings &&
          runtimeType == other.runtimeType &&
          general == other.general &&
          sound == other.sound &&
          vibrate == other.vibrate &&
          updated == other.updated;

  @override
  int get hashCode =>
      general.hashCode ^ sound.hashCode ^ vibrate.hashCode ^ updated.hashCode;
}
