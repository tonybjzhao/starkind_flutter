import '../models/daily_message.dart';

class MessageService {
  DailyMessage generateDailyMessage({
    required DateTime date,
    required String zodiacSign,
    required String preferredTone,
  }) {
    final normalizedSign = zodiacSign == 'Unknown' ? 'Starlight' : zodiacSign;
    final daySeed = date.year * 1000 + date.month * 100 + date.day;
    final toneSeed = preferredTone.codeUnits.fold(0, (sum, c) => sum + c);
    final signSeed = normalizedSign.codeUnits.fold(0, (sum, c) => sum + c);
    final index = (daySeed + toneSeed + signSeed) % _samples.length;
    final sample = _samples[index];

    return DailyMessage(
      id: '${date.toIso8601String().split('T').first}-${normalizedSign.toLowerCase()}-$index',
      date: date,
      message: sample.message,
      zodiacHint: '$normalizedSign hint: ${sample.zodiacHint}',
      luckyColor: sample.luckyColor,
      zodiacSign: normalizedSign,
    );
  }
}

class _SampleMessage {
  const _SampleMessage({
    required this.message,
    required this.zodiacHint,
    required this.luckyColor,
  });

  final String message;
  final String zodiacHint;
  final String luckyColor;
}

const List<_SampleMessage> _samples = [
  _SampleMessage(message: 'You can take this day gently and still do something brave.', zodiacHint: 'Trust the step directly in front of you.', luckyColor: 'Rose Cloud'),
  _SampleMessage(message: 'A calm answer can turn your whole afternoon softer.', zodiacHint: 'Pause before reacting and listen to your body.', luckyColor: 'Powder Blue'),
  _SampleMessage(message: 'You are growing even when progress feels invisible.', zodiacHint: 'Small routines become deep roots this week.', luckyColor: 'Sage Mist'),
  _SampleMessage(message: 'Your warmth is not too much; it is your light.', zodiacHint: 'Lead with kindness and your clarity follows.', luckyColor: 'Apricot Glow'),
  _SampleMessage(message: 'One honest conversation can clear the noise in your mind.', zodiacHint: 'Speak from the heart, not from pressure.', luckyColor: 'Moon Silver'),
  _SampleMessage(message: 'Let today be simple and beautiful on purpose.', zodiacHint: 'Choose one meaningful task and finish it gently.', luckyColor: 'Cream Pearl'),
  _SampleMessage(message: 'Your pace is valid. Slow does not mean behind.', zodiacHint: 'Protect your rhythm from outside urgency.', luckyColor: 'Misty Lilac'),
  _SampleMessage(message: 'A little order today will create peace for tomorrow.', zodiacHint: 'Tidy one corner and feel your focus return.', luckyColor: 'Soft Mint'),
  _SampleMessage(message: 'You are allowed to rest before you earn it.', zodiacHint: 'Energy renews when you stop proving.', luckyColor: 'Petal Pink'),
  _SampleMessage(message: 'Your attention is precious. Spend it with care.', zodiacHint: 'Notice what gives you calm, and stay there.', luckyColor: 'Sea Glass'),
  _SampleMessage(message: 'Give yourself the same kindness you give others.', zodiacHint: 'Replace one harsh thought with a softer one.', luckyColor: 'Warm Sand'),
  _SampleMessage(message: 'A clear boundary can be an act of love.', zodiacHint: 'Choose honesty over overextending today.', luckyColor: 'Dusty Coral'),
  _SampleMessage(message: 'You are not late. Your path is unfolding on time.', zodiacHint: 'Trust timing over comparison.', luckyColor: 'Blue Smoke'),
  _SampleMessage(message: 'Quiet confidence grows when you keep promises to yourself.', zodiacHint: 'Complete one promise before noon.', luckyColor: 'Honey Beige'),
  _SampleMessage(message: 'There is beauty in how steadily you keep going.', zodiacHint: 'Consistency beats intensity today.', luckyColor: 'Pale Teal'),
  _SampleMessage(message: 'Your inner world deserves gentle care this evening.', zodiacHint: 'Protect your evening from extra noise.', luckyColor: 'Lavender Haze'),
  _SampleMessage(message: 'The right words arrive when you slow your breath.', zodiacHint: 'Exhale before you decide.', luckyColor: 'Sky Milk'),
  _SampleMessage(message: 'You can begin again from exactly where you are.', zodiacHint: 'Reset without self-judgment.', luckyColor: 'Vanilla Mist'),
  _SampleMessage(message: 'A softer plan can still lead to strong results.', zodiacHint: 'Make room for flexibility.', luckyColor: 'Mauve Dust'),
  _SampleMessage(message: 'Your kindness is a strategy, not a weakness.', zodiacHint: 'Lead with heart and clear intention.', luckyColor: 'Sunset Peach'),
  _SampleMessage(message: 'Do less, but do it with your whole presence.', zodiacHint: 'Single-task for one focused hour.', luckyColor: 'Ocean Pearl'),
  _SampleMessage(message: 'You are allowed to choose peace over perfection.', zodiacHint: 'Done is enough for today.', luckyColor: 'Cloud White'),
  _SampleMessage(message: 'The way you care for yourself teaches others how to care for you.', zodiacHint: 'Set one caring boundary today.', luckyColor: 'Fern Glow'),
  _SampleMessage(message: 'Your heart already knows the gentlest next move.', zodiacHint: 'Follow what feels steady, not loud.', luckyColor: 'Rosewater'),
  _SampleMessage(message: 'Grace and discipline can live in the same day.', zodiacHint: 'Balance softness with one clear commitment.', luckyColor: 'Dawn Gold'),
  _SampleMessage(message: 'Today is a good day to trust your quiet intuition.', zodiacHint: 'Notice the first calm answer inside.', luckyColor: 'Soft Indigo'),
  _SampleMessage(message: 'Your effort matters, even when no one applauds.', zodiacHint: 'Keep going for your own growth.', luckyColor: 'River Blue'),
  _SampleMessage(message: 'A kind morning creates a kinder timeline.', zodiacHint: 'Start with stillness before screens.', luckyColor: 'Pale Amber'),
  _SampleMessage(message: 'You can protect your joy without apology.', zodiacHint: 'Say yes only to what nourishes you.', luckyColor: 'Orchid Mist'),
  _SampleMessage(message: 'Let this be the day you speak to yourself as a friend.', zodiacHint: 'Compassion sharpens your strength.', luckyColor: 'Morning Peach'),
];
