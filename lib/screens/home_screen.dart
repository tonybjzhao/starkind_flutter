import 'package:flutter/material.dart';

import '../services/starkind_state.dart';
import '../widgets/daily_message_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = StarKindScope.of(context);
    final card = state.currentMessage;

    final messageText = card?.message ??
        'Set your birthday in Profile to receive your daily kindness card.';
    final hintText = card?.zodiacHint ??
        'Your zodiac hint will appear after profile setup.';
    final luckyColor = card?.luckyColor ?? 'Soft Pearl';
    final dateText = card == null
        ? 'TODAY'
        : '${card.date.year}-${card.date.month.toString().padLeft(2, '0')}-${card.date.day.toString().padLeft(2, '0')}';

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
                          message: messageText,
                          zodiacHint: hintText,
                          luckyColor: luckyColor,
                          dateText: dateText,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              FilledButton.icon(
                                onPressed: () {
                                  final saved = state.saveCurrentMessage();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(saved
                                          ? 'Saved to favorites.'
                                          : 'Already saved for today.'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                icon: Icon(state.isCurrentMessageSaved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_add_rounded),
                                label: Text(
                                  state.isCurrentMessageSaved ? 'Saved' : 'Save',
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: state.refreshDailyMessage,
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
