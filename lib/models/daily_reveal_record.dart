class DailyRevealRecord {
  const DailyRevealRecord({
    required this.dateKey,
    required this.hasRevealedToday,
    required this.messageId,
    required this.message,
    required this.zodiacHint,
    required this.luckyColor,
  });

  final String dateKey;
  final bool hasRevealedToday;
  final String messageId;
  final String message;
  final String zodiacHint;
  final String luckyColor;

  factory DailyRevealRecord.emptyFor(String dateKey) {
    return DailyRevealRecord(
      dateKey: dateKey,
      hasRevealedToday: false,
      messageId: '',
      message: '',
      zodiacHint: '',
      luckyColor: '',
    );
  }

  DailyRevealRecord copyWith({
    String? dateKey,
    bool? hasRevealedToday,
    String? messageId,
    String? message,
    String? zodiacHint,
    String? luckyColor,
  }) {
    return DailyRevealRecord(
      dateKey: dateKey ?? this.dateKey,
      hasRevealedToday: hasRevealedToday ?? this.hasRevealedToday,
      messageId: messageId ?? this.messageId,
      message: message ?? this.message,
      zodiacHint: zodiacHint ?? this.zodiacHint,
      luckyColor: luckyColor ?? this.luckyColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateKey': dateKey,
      'hasRevealedToday': hasRevealedToday,
      'messageId': messageId,
      'message': message,
      'zodiacHint': zodiacHint,
      'luckyColor': luckyColor,
    };
  }

  factory DailyRevealRecord.fromJson(Map<String, dynamic> json) {
    return DailyRevealRecord(
      dateKey: (json['dateKey'] as String?) ?? '',
      hasRevealedToday: (json['hasRevealedToday'] as bool?) ?? false,
      messageId: (json['messageId'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
      zodiacHint: (json['zodiacHint'] as String?) ?? '',
      luckyColor: (json['luckyColor'] as String?) ?? '',
    );
  }
}
