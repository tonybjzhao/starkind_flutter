enum DailyState {
  calm,
  tired,
  anxious,
  hopeful,
  overwhelmed,
  lonely,
  drained,
  grateful,
  brave,
}

extension DailyStateX on DailyState {
  String get label {
    switch (this) {
      case DailyState.calm:
        return 'Calm';
      case DailyState.tired:
        return 'Tired';
      case DailyState.anxious:
        return 'Anxious';
      case DailyState.hopeful:
        return 'Hopeful';
      case DailyState.overwhelmed:
        return 'Overwhelmed';
      case DailyState.lonely:
        return 'Lonely';
      case DailyState.drained:
        return 'Drained';
      case DailyState.grateful:
        return 'Grateful';
      case DailyState.brave:
        return 'Brave';
    }
  }

  String get key => name;

  static DailyState? fromKey(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    for (final state in DailyState.values) {
      if (state.name == value) {
        return state;
      }
    }
    return null;
  }
}
