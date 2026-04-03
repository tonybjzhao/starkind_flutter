import 'package:flutter/material.dart';

import '../widgets/daily_message_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _cardIndex = 0;

  final List<_DailyCardData> _sampleCards = const [
    _DailyCardData(
      message:
          'You are allowed to move slowly today. Kind steps still create bright paths.',
      zodiacHint: 'Taurus energy: build steady comfort and trust your rhythm.',
      luckyColor: 'Blush Peach',
      dateText: 'TODAY',
    ),
    _DailyCardData(
      message:
          'A soft heart is a strength. Share one honest word and warmth will return to you.',
      zodiacHint: 'Cancer mood: nurture your inner space before the outside noise.',
      luckyColor: 'Mist Blue',
      dateText: 'TODAY',
    ),
    _DailyCardData(
      message:
          'Keep only what feels true. Simplicity can make your day feel magical.',
      zodiacHint: 'Virgo tone: gentle clarity brings peaceful momentum.',
      luckyColor: 'Moonlit Sage',
      dateText: 'TODAY',
    ),
  ];

  void _refreshCard() {
    setState(() {
      _cardIndex = (_cardIndex + 1) % _sampleCards.length;
    });
  }

  void _saveCard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved to favorites (mock for now).'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = _sampleCards[_cardIndex];

    return SafeArea(
      child: Stack(
        children: [
          const _PastelBackground(),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'StarKind',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF665560),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A gentle daily kindness based on your zodiac story.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF85757F),
                              ),
                        ),
                        const SizedBox(height: 26),
                        DailyMessageCard(
                          message: card.message,
                          zodiacHint: card.zodiacHint,
                          luckyColor: card.luckyColor,
                          dateText: card.dateText,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              FilledButton.icon(
                                onPressed: _saveCard,
                                icon: const Icon(Icons.bookmark_add_rounded),
                                label: const Text('Save'),
                              ),
                              OutlinedButton.icon(
                                onPressed: _refreshCard,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Refresh'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PastelBackground extends StatelessWidget {
  const _PastelBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8EEF3),
            Color(0xFFF8F4EF),
            Color(0xFFEEF6FA),
          ],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            top: -70,
            right: -40,
            child: _BlurBubble(color: Color(0x44F4C6D4), size: 220),
          ),
          Positioned(
            top: 180,
            left: -60,
            child: _BlurBubble(color: Color(0x449FD7E4), size: 180),
          ),
          Positioned(
            bottom: -50,
            right: 20,
            child: _BlurBubble(color: Color(0x44F6D9B8), size: 200),
          ),
        ],
      ),
    );
  }
}

class _BlurBubble extends StatelessWidget {
  const _BlurBubble({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}

class _DailyCardData {
  const _DailyCardData({
    required this.message,
    required this.zodiacHint,
    required this.luckyColor,
    required this.dateText,
  });

  final String message;
  final String zodiacHint;
  final String luckyColor;
  final String dateText;
}
