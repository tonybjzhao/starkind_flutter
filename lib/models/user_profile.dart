class UserProfile {
  const UserProfile({
    required this.birthday,
    required this.zodiacSign,
    required this.preferredTone,
    required this.notificationHour,
    required this.notificationMinute,
  });

  final DateTime? birthday;
  final String zodiacSign;
  final String preferredTone;
  final int notificationHour;
  final int notificationMinute;

  factory UserProfile.initial() {
    return const UserProfile(
      birthday: null,
      zodiacSign: 'Unknown',
      preferredTone: 'Gentle',
      notificationHour: 9,
      notificationMinute: 0,
    );
  }

  UserProfile copyWith({
    DateTime? birthday,
    bool clearBirthday = false,
    String? zodiacSign,
    String? preferredTone,
    int? notificationHour,
    int? notificationMinute,
  }) {
    return UserProfile(
      birthday: clearBirthday ? null : (birthday ?? this.birthday),
      zodiacSign: zodiacSign ?? this.zodiacSign,
      preferredTone: preferredTone ?? this.preferredTone,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'birthday': birthday?.toIso8601String(),
      'zodiacSign': zodiacSign,
      'preferredTone': preferredTone,
      'notificationHour': notificationHour,
      'notificationMinute': notificationMinute,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final birthdayValue = json['birthday'];
    return UserProfile(
      birthday: birthdayValue == null
          ? null
          : DateTime.tryParse(birthdayValue as String),
      zodiacSign: (json['zodiacSign'] as String?) ?? 'Unknown',
      preferredTone: (json['preferredTone'] as String?) ?? 'Gentle',
      notificationHour: (json['notificationHour'] as int?) ?? 9,
      notificationMinute: (json['notificationMinute'] as int?) ?? 0,
    );
  }
}
