import 'package:flutter/material.dart';

import '../services/starkind_state.dart';
import '../widgets/daily_message_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = StarKindScope.of(context);
    final saved = state.savedMessages;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6F5E5E),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'A quiet place for your gentle moments.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF8A7A7A),
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: saved.isEmpty
                  ? Card(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Your saved stars will appear here.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  height: 1.4,
                                  color: const Color(0xFF6F5E5E),
                                ),
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: saved.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = saved[index];
                        final dateText =
                            '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}';

                        return Dismissible(
                          key: ValueKey(item.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: const Color(0x33DDAA9B),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.delete_outline_rounded),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            state.removeSavedMessage(item.id);
                          },
                          child: DailyMessageCard(
                            message: item.message,
                            zodiacHint: item.zodiacHint,
                            luckyColor: item.luckyColor,
                            dateText: dateText,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
