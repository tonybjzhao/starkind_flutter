import 'package:flutter/material.dart';

import '../services/starkind_state.dart';
import '../widgets/premium_paywall_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const List<String> _tones = [
    'Gentle',
    'Healing',
    'Confident',
    'Motivational',
  ];

  Future<void> _pickBirthday() async {
    final state = StarKindScope.of(context);
    final currentBirthday = state.profile.birthday;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: now,
      initialDate: currentBirthday ?? DateTime(now.year - 20, 1, 1),
    );

    if (picked != null) {
      state.setBirthday(picked);
    }
  }

  Future<void> _pickTime() async {
    final state = StarKindScope.of(context);
    final currentTime = TimeOfDay(
      hour: state.profile.notificationHour,
      minute: state.profile.notificationMinute,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (picked != null) {
      state.setNotificationTime(picked);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not set';
    }
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '$mm/$dd/${date.year}';
  }

  Future<void> _openPremiumPaywall() async {
    final state = StarKindScope.of(context);
    final message = await showPremiumPaywallSheet(context, state: state);
    if (!mounted || message == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _restorePurchase() async {
    final state = StarKindScope.of(context);
    final result = await state.restorePremiumPurchase();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? 'Premium restored.'
              : (result.message ?? 'No purchase found to restore.'),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = StarKindScope.of(context);
    final profile = state.profile;
    final zodiacSign = profile.zodiacSign;
    final notificationTime = TimeOfDay(
      hour: profile.notificationHour,
      minute: profile.notificationMinute,
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text(
            'Profile',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6F5E5E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your gentle profile',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF7A6970),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Set your birthday and preferences for your daily StarKind message.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF8A7A7A)),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Birthday',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(profile.birthday),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickBirthday,
                    icon: const Icon(Icons.cake_outlined),
                    label: const Text('Select birthday'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF6F5E5E),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your zodiac sign',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          zodiacSign,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF6F5E5E),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily notification time',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notificationTime.format(context),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: const Text('Set reminder time'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Style preference',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tones
                        .map(
                          (tone) => ChoiceChip(
                            label: Text(tone),
                            selected: profile.preferredTone == tone,
                            onSelected: (_) {
                              state.setPreferredTone(tone);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Plan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.isPremiumEnabled
                        ? 'Premium active'
                        : 'Free plan active',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock overwhelmed, lonely, drained, grateful, and brave.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF87757D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: state.purchaseInProgress
                          ? null
                          : _openPremiumPaywall,
                      icon: const Icon(Icons.stars_rounded),
                      label: const Text('Unlock Premium'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: state.purchaseInProgress
                          ? null
                          : _restorePurchase,
                      icon: const Icon(Icons.restore_rounded),
                      label: const Text('Restore Purchase'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
