import 'package:flutter/material.dart';

import '../services/starkind_state.dart';
import '../widgets/daily_message_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = StarKindScope.of(context);
    final card = state.currentMessage;
    final isRevealed = state.hasRevealedToday;

    final messageText = card?.message ??
        'Set your birthday in Profile to receive your daily kindness card.';
    final hintText = card?.zodiacHint ??
        'Your zodiac hint will appear after profile setup.';
    final luckyColor = card?.luckyColor ?? 'Soft Pearl';
    final dateText = state.todayDateText;

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
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.98, end: 1.0)
                                    .animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: isRevealed
                              ? DailyMessageCard(
                                  key: const ValueKey('revealed-card'),
                                  message: messageText,
                                  zodiacHint: hintText,
                                  luckyColor: luckyColor,
                                  dateText: dateText,
                                )
                              : _RevealPlaceholderCard(
                                  key: const ValueKey('hidden-card'),
                                  dateText: dateText,
                                  onTap: state.revealTodayMessage,
                                ),
                        ),
                        const SizedBox(height: 20),
                        if (isRevealed)
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
                                    state.isCurrentMessageSaved
                                        ? 'Saved'
                                        : 'Save',
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

class _RevealPlaceholderCard extends StatelessWidget {
  const _RevealPlaceholderCard({
    super.key,
    required this.dateText,
    required this.onTap,
  });

  final String dateText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateText,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 0.3,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8D7A83),
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tap to reveal your message',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF5F4F59),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Take a breath, then open today\'s gentle card.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF7B6A73),
                    ),
              ),
            ],
          ),
        ),
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
