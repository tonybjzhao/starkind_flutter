import '../models/daily_message.dart';
import '../models/daily_state.dart';

class MessageService {
  DailyMessage generateDailyMessage({
    required DateTime date,
    required String zodiacSign,
    required String preferredTone,
    DailyState selectedState = DailyState.calm,
    int variationSeed = 0,
    bool isPremium = false,
  }) {
    final normalizedSign = zodiacSign == 'Unknown' ? 'Starlight' : zodiacSign;
    final daySeed = date.year * 1000 + date.month * 100 + date.day;
    final toneSeed = preferredTone.codeUnits.fold(0, (sum, c) => sum + c);
    final signSeed = normalizedSign.codeUnits.fold(0, (sum, c) => sum + c);
    final stateSeed = selectedState.key.codeUnits.fold(0, (sum, c) => sum + c);

    final pool = isPremium
        ? _allSamplesByState[selectedState] ??
            _allSamplesByState[DailyState.calm]!
        : _freeSamplesByState[selectedState] ??
            _freeSamplesByState[DailyState.calm]!;

    final index =
        (daySeed + toneSeed + signSeed + stateSeed + variationSeed) % pool.length;
    final sample = pool[index];

    return DailyMessage(
      id: '${date.toIso8601String().split('T').first}-${normalizedSign.toLowerCase()}-$index',
      date: date,
      message: sample.message,
      zodiacHint:
          '$normalizedSign • ${selectedState.label.toLowerCase()} tone: ${sample.zodiacHint}',
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

const Map<DailyState, List<_SampleMessage>> _freeSamplesByState = {
  DailyState.calm: [
    _SampleMessage(message: 'Let this day unfold slowly. Quiet choices can still be strong.', zodiacHint: 'Choose steadiness over urgency.', luckyColor: 'Powder Blue'),
    _SampleMessage(message: 'A calm breath can soften everything that follows.', zodiacHint: 'Pause before the next step.', luckyColor: 'Cloud White'),
    _SampleMessage(message: 'Your peace is productive too.', zodiacHint: 'Gentle focus is enough for today.', luckyColor: 'Sage Mist'),
  ],
  DailyState.tired: [
    _SampleMessage(message: 'You are allowed to move lightly today.', zodiacHint: 'Protect your energy and keep one promise.', luckyColor: 'Warm Sand'),
    _SampleMessage(message: 'Rest and progress can exist together.', zodiacHint: 'Small effort still counts deeply.', luckyColor: 'Lavender Haze'),
    _SampleMessage(message: 'Soft pace, kind heart, still forward.', zodiacHint: 'Do less, but do it with presence.', luckyColor: 'Honey Beige'),
  ],
  DailyState.anxious: [
    _SampleMessage(message: 'You are safe to take this moment one breath at a time.', zodiacHint: 'Name one simple next action.', luckyColor: 'Sea Glass'),
    _SampleMessage(message: 'The wave will pass. You can stay grounded through it.', zodiacHint: 'Come back to what is true right now.', luckyColor: 'Misty Lilac'),
    _SampleMessage(message: 'Your nervous system deserves tenderness today.', zodiacHint: 'Choose comfort before intensity.', luckyColor: 'Soft Mint'),
  ],
  DailyState.hopeful: [
    _SampleMessage(message: 'Hope is already a form of momentum.', zodiacHint: 'Take the small brave step.', luckyColor: 'Sunset Peach'),
    _SampleMessage(message: 'Something kind can begin today.', zodiacHint: 'Keep your heart open and practical.', luckyColor: 'Apricot Glow'),
    _SampleMessage(message: 'Your future is shaped by today\'s gentle courage.', zodiacHint: 'Trust what is growing quietly.', luckyColor: 'Dawn Gold'),
  ],
};

const Map<DailyState, List<_SampleMessage>> _allSamplesByState = {
  ..._freeSamplesByState,
  DailyState.overwhelmed: [
    _SampleMessage(message: 'One small task is enough for now.', zodiacHint: 'Shrink the day to one clear anchor.', luckyColor: 'Moon Silver'),
    _SampleMessage(message: 'You do not have to carry everything at once.', zodiacHint: 'Release one nonessential weight.', luckyColor: 'Pale Teal'),
  ],
  DailyState.lonely: [
    _SampleMessage(message: 'You are still connected, even in quiet hours.', zodiacHint: 'Reach for one warm voice today.', luckyColor: 'Rosewater'),
    _SampleMessage(message: 'Your presence matters more than you can see.', zodiacHint: 'Let yourself be received.', luckyColor: 'Morning Peach'),
  ],
  DailyState.drained: [
    _SampleMessage(message: 'Refill before you pour more out.', zodiacHint: 'Protect your inner battery first.', luckyColor: 'Vanilla Mist'),
    _SampleMessage(message: 'Low energy is not low worth.', zodiacHint: 'Honor this slower rhythm.', luckyColor: 'Blue Smoke'),
  ],
  DailyState.grateful: [
    _SampleMessage(message: 'Let gratitude make today luminous.', zodiacHint: 'Notice one good thing twice.', luckyColor: 'Pale Amber'),
    _SampleMessage(message: 'Thankfulness can be a quiet strength.', zodiacHint: 'Share one sincere appreciation.', luckyColor: 'Fern Glow'),
  ],
  DailyState.brave: [
    _SampleMessage(message: 'You are ready for the honest next step.', zodiacHint: 'Courage can be soft and clear.', luckyColor: 'River Blue'),
    _SampleMessage(message: 'Bravery today can look like calm truth.', zodiacHint: 'Stand gently in what you know.', luckyColor: 'Soft Indigo'),
  ],
};
