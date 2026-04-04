import 'package:flutter/material.dart';

import '../services/starkind_state.dart';

Future<String?> showPremiumPaywallSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PremiumPaywallSheet(),
  );
}

class _PremiumPaywallSheet extends StatefulWidget {
  const _PremiumPaywallSheet();

  @override
  State<_PremiumPaywallSheet> createState() => _PremiumPaywallSheetState();
}

class _PremiumPaywallSheetState extends State<_PremiumPaywallSheet> {
  bool _busy = false;

  Future<void> _handleUnlock(StarKindState state) async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    final result = await state.purchasePremium();
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    if (result.isSuccess) {
      Navigator.of(context).pop('Premium unlocked.');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message ?? 'Purchase failed.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleRestore(StarKindState state) async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    final result = await state.restorePremiumPurchase();
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    if (result.isSuccess) {
      Navigator.of(context).pop('Premium restored.');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message ?? 'No purchase found to restore.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = StarKindScope.of(context);
    final media = MediaQuery.of(context);
    final planLine = state.isPremiumEnabled
        ? 'Premium active'
        : 'Free plan active';

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + media.viewInsets.bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCFB),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F7C636C),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCC7C7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Unlock Premium feelings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6A585E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Unlock Overwhelmed, Lonely, Drained, Grateful, and Brave for deeper daily guidance.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF86767D),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                planLine,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF7A6970),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _busy ? null : () => _handleUnlock(state),
                  icon: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.stars_rounded),
                  label: const Text('Unlock Premium'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _handleRestore(state),
                  icon: const Icon(Icons.restore_rounded),
                  label: const Text('Restore Purchase'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
