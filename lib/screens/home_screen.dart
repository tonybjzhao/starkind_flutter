import 'package:flutter/material.dart';

import '../models/daily_state.dart';
import '../services/starkind_state.dart';
import '../widgets/daily_message_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = StarKindScope.of(context);
    final card = state.currentMessage;
    final isRevealed = state.hasRevealedToday;
    final selectedState = state.selectedDailyState;

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
                        _StreakPanel(
                          streak: state.currentStreak,
                          message: state.streakMessage,
                        ),
                        const SizedBox(height: 14),
                        _DailyStateSelector(
                          selected: selectedState,
                          enabled: !isRevealed,
                          isPremium: state.isPremiumEnabled,
                          isUnlocked: state.isDailyStateUnlocked,
                          onSelected: (dailyState) {
                            final ok = state.selectDailyState(dailyState);
                            if (!ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'This feeling is part of Premium. Enable Premium in Profile to unlock it.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 14),
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
                                  hasSelectedState: state.canRevealToday,
                                  selectedStateLabel: selectedState?.label,
                                  onTap: () {
                                    final revealed = state.revealTodayMessage();
                                    if (!revealed) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Select how you feel first.'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
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
    required this.hasSelectedState,
    required this.selectedStateLabel,
    required this.onTap,
  });

  final String dateText;
  final bool hasSelectedState;
  final String? selectedStateLabel;
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
                hasSelectedState
                    ? 'Tap to reveal your message'
                    : 'Choose your feeling first',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF5F4F59),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                hasSelectedState
                    ? 'Take a breath, then open today\'s gentle card.'
                    : 'Pick your current state to tune today\'s message.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF7B6A73),
                    ),
              ),
              if (selectedStateLabel != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Today\'s state: $selectedStateLabel',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF6F5E5E),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyStateSelector extends StatelessWidget {
  const _DailyStateSelector({
    required this.selected,
    required this.enabled,
    required this.isPremium,
    required this.isUnlocked,
    required this.onSelected,
  });

  final DailyState? selected;
  final bool enabled;
  final bool isPremium;
  final bool Function(DailyState state) isUnlocked;
  final ValueChanged<DailyState> onSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose how you\'re feeling today',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5F4F59),
                  ),
            ),
            const SizedBox(height: 10),
            if (!isPremium)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Some deeper states are part of Premium.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF85757F),
                      ),
                ),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DailyState.values
                  .map((mood) {
                    final unlocked = isUnlocked(mood);
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(mood.label),
                          if (!unlocked) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.lock_outline_rounded, size: 14),
                          ],
                        ],
                      ),
                      selected: selected == mood,
                      onSelected: enabled ? (_) => onSelected(mood) : null,
                    );
                  })
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakPanel extends StatelessWidget {
  const _StreakPanel({
    required this.streak,
    required this.message,
  });

  final int streak;
  final String message;

  @override
  Widget build(BuildContext context) {
    final unit = streak == 1 ? 'day' : 'days';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              color: Color(0xFFCE9A89),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kindness streak: $streak $unit',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF5F4F59),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF7B6A73),
                        ),
                  ),
                ],
              ),
            ),
          ],
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
