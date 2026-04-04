import '../models/daily_state.dart';

class EntitlementService {
  const EntitlementService();

  static const Set<DailyState> _freeStates = {
    DailyState.calm,
    DailyState.tired,
    DailyState.anxious,
    DailyState.hopeful,
  };

  bool isStateUnlocked({
    required DailyState state,
    required bool isPremium,
  }) {
    if (isPremium) {
      return true;
    }
    return _freeStates.contains(state);
  }

  List<DailyState> availableStates({required bool isPremium}) {
    if (isPremium) {
      return DailyState.values;
    }
    return DailyState.values
        .where((state) => _freeStates.contains(state))
        .toList(growable: false);
  }
}
