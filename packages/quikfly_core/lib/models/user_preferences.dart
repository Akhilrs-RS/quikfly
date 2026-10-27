class UserPreferences {
  final int userId;
  final bool pushNotifications;
  final bool promotionalAlerts;
  final bool biometricLock;
  final String language;

  const UserPreferences({
    this.userId = 1,
    this.pushNotifications = true,
    this.promotionalAlerts = false,
    this.biometricLock = true,
    this.language = 'English (US)',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['user_id'] is int ? json['user_id'] as int : int.tryParse(json['user_id']?.toString() ?? '1') ?? 1,
      pushNotifications: json['push_notifications'] == true || json['push_notifications'] == 1 || json['push_notifications'] == '1',
      promotionalAlerts: json['promotional_alerts'] == true || json['promotional_alerts'] == 1 || json['promotional_alerts'] == '1',
      biometricLock: json['biometric_lock'] == true || json['biometric_lock'] == 1 || json['biometric_lock'] == '1',
      language: json['language'] as String? ?? 'English (US)',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'push_notifications': pushNotifications,
      'promotional_alerts': promotionalAlerts,
      'biometric_lock': biometricLock,
      'language': language,
    };
  }

  UserPreferences copyWith({
    int? userId,
    bool? pushNotifications,
    bool? promotionalAlerts,
    bool? biometricLock,
    String? language,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      promotionalAlerts: promotionalAlerts ?? this.promotionalAlerts,
      biometricLock: biometricLock ?? this.biometricLock,
      language: language ?? this.language,
    );
  }
}
