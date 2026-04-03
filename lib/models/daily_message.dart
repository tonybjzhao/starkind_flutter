class DailyMessage {
  const DailyMessage({
    required this.id,
    required this.date,
    required this.message,
    required this.zodiacHint,
    required this.luckyColor,
    required this.zodiacSign,
  });

  final String id;
  final DateTime date;
  final String message;
  final String zodiacHint;
  final String luckyColor;
  final String zodiacSign;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'message': message,
      'zodiacHint': zodiacHint,
      'luckyColor': luckyColor,
      'zodiacSign': zodiacSign,
    };
  }

  factory DailyMessage.fromJson(Map<String, dynamic> json) {
    return DailyMessage(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      message: json['message'] as String,
      zodiacHint: json['zodiacHint'] as String,
      luckyColor: json['luckyColor'] as String,
      zodiacSign: json['zodiacSign'] as String,
    );
  }
}
