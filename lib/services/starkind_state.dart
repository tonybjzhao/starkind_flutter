import 'dart:collection';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_message.dart';
import '../models/daily_reveal_record.dart';
import '../models/daily_state.dart';
import '../models/user_profile.dart';
import 'message_service.dart';
import 'notification_service.dart';
import 'zodiac_service.dart';

class StarKindState extends ChangeNotifier {
  StarKindState({
    MessageService? messageService,
    ZodiacService? zodiacService,
    NotificationService? notificationService,
  })  : _messageService = messageService ?? MessageService(),
        _zodiacService = zodiacService ?? ZodiacService(),
        _notificationService = notificationService ?? NotificationService() {
    refreshDailyMessage();
  }

  final MessageService _messageService;
  final ZodiacService _zodiacService;
  final NotificationService _notificationService;

  static const String _profileKey = 'profile';
  static const String _savedMessagesKey = 'saved_messages';
  static const String _dailyRevealKey = 'daily_reveal_record';

  UserProfile _profile = UserProfile.initial();
  DailyMessage? _currentMessage;
  final List<DailyMessage> _savedMessages = [];
  DailyRevealRecord _dailyRevealRecord =
      DailyRevealRecord.emptyFor(_todayKey());
  bool _notificationsReady = false;

  UserProfile get profile => _profile;
  DailyMessage? get currentMessage => _currentMessage;
  bool get hasRevealedToday => _dailyRevealRecord.hasRevealedToday;
    DailyState? get selectedDailyState =>
      DailyStateX.fromKey(_dailyRevealRecord.selectedStateKey);
    bool get canRevealToday => selectedDailyState != null;
  String get todayDateText => _dailyRevealRecord.dateKey;
  UnmodifiableListView<DailyMessage> get savedMessages =>
      UnmodifiableListView(_savedMessages);
  bool get isCurrentMessageSaved {
    final current = _currentMessage;
    if (current == null) {
      return false;
    }
    return _savedMessages.any((item) => item.id == current.id);
  }

  Future<void> initialize() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
    _notificationsReady = true;

    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);
    final savedJson = prefs.getStringList(_savedMessagesKey) ?? [];
    final revealJson = prefs.getString(_dailyRevealKey);

    if (profileJson != null && profileJson.isNotEmpty) {
      final decoded = jsonDecode(profileJson) as Map<String, dynamic>;
      _profile = UserProfile.fromJson(decoded);
    }

    _savedMessages
      ..clear()
      ..addAll(
        savedJson.map((item) {
          final decoded = jsonDecode(item) as Map<String, dynamic>;
          return DailyMessage.fromJson(decoded);
        }),
      );

    if (revealJson != null && revealJson.isNotEmpty) {
      final decoded = jsonDecode(revealJson) as Map<String, dynamic>;
      _dailyRevealRecord = DailyRevealRecord.fromJson(decoded);
    }

    _syncTodayRecordAndMessage(notify: true);
  }

  void setBirthday(DateTime birthday) {
    final zodiac = _zodiacService.getZodiacSign(birthday);
    _profile = _profile.copyWith(
      birthday: birthday,
      zodiacSign: zodiac,
    );
    _saveProfile();
    _syncTodayRecordAndMessage(notify: true);
    unawaited(_rescheduleNotification());
  }

  void setPreferredTone(String tone) {
    _profile = _profile.copyWith(preferredTone: tone);
    _saveProfile();
    _syncTodayRecordAndMessage(notify: true);
    unawaited(_rescheduleNotification());
  }

  void setNotificationTime(TimeOfDay time) {
    _profile = _profile.copyWith(
      notificationHour: time.hour,
      notificationMinute: time.minute,
    );
    _saveProfile();
    notifyListeners();
    unawaited(_rescheduleNotification());
  }

  void refreshDailyMessage() {
    final selected = selectedDailyState;
    if (selected == null) {
      _currentMessage = null;
      _dailyRevealRecord = DailyRevealRecord.emptyFor(_todayKey());
    } else {
      final generated = _generateTodayMessage(selectedState: selected);
      _currentMessage = generated;
      _dailyRevealRecord = DailyRevealRecord(
        dateKey: _todayKey(),
        hasRevealedToday: false,
        selectedStateKey: selected.key,
        messageId: generated.id,
        message: generated.message,
        zodiacHint: generated.zodiacHint,
        luckyColor: generated.luckyColor,
      );
    }

    unawaited(_saveDailyRevealRecord());
    notifyListeners();
    unawaited(_rescheduleNotification());
  }

  void selectDailyState(DailyState selectedState) {
    final todayKey = _todayKey();
    if (_dailyRevealRecord.dateKey != todayKey) {
      _dailyRevealRecord = DailyRevealRecord.emptyFor(todayKey);
    }

    if (_dailyRevealRecord.hasRevealedToday) {
      return;
    }

    final generated = _generateTodayMessage(selectedState: selectedState);
    _currentMessage = generated;
    _dailyRevealRecord = DailyRevealRecord(
      dateKey: todayKey,
      hasRevealedToday: false,
      selectedStateKey: selectedState.key,
      messageId: generated.id,
      message: generated.message,
      zodiacHint: generated.zodiacHint,
      luckyColor: generated.luckyColor,
    );

    unawaited(_saveDailyRevealRecord());
    notifyListeners();
    unawaited(_rescheduleNotification());
  }

  bool revealTodayMessage() {
    if (_dailyRevealRecord.hasRevealedToday || !canRevealToday) {
      return false;
    }

    _dailyRevealRecord = _dailyRevealRecord.copyWith(hasRevealedToday: true);
    unawaited(_saveDailyRevealRecord());
    notifyListeners();
    return true;
  }

  bool saveCurrentMessage() {
    final current = _currentMessage;
    if (current == null) {
      return false;
    }

    final alreadySaved = _savedMessages.any((item) => item.id == current.id);
    if (alreadySaved) {
      return false;
    }

    _savedMessages.insert(0, current);
    _saveSavedMessages();
    notifyListeners();
    return true;
  }

  void removeSavedMessage(String messageId) {
    _savedMessages.removeWhere((item) => item.id == messageId);
    _saveSavedMessages();
    notifyListeners();
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(_profile.toJson()));
  }

  Future<void> _saveSavedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _savedMessages
        .map((message) => jsonEncode(message.toJson()))
        .toList();
    await prefs.setStringList(_savedMessagesKey, encoded);
  }

  Future<void> _saveDailyRevealRecord() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _dailyRevealKey,
      jsonEncode(_dailyRevealRecord.toJson()),
    );
  }

  Future<void> _rescheduleNotification() async {
    if (!_notificationsReady) {
      return;
    }

    final body = _currentMessage?.message ??
        'Your gentle StarKind message is ready for today.';

    await _notificationService.scheduleDailyMessageNotification(
      hour: _profile.notificationHour,
      minute: _profile.notificationMinute,
      message: body,
    );
  }

  void _syncTodayRecordAndMessage({required bool notify}) {
    final todayKey = _todayKey();
    if (_dailyRevealRecord.dateKey != todayKey) {
      _dailyRevealRecord = DailyRevealRecord.emptyFor(todayKey);
    }

    final selected = selectedDailyState;
    if (selected == null) {
      _currentMessage = null;
      _dailyRevealRecord = _dailyRevealRecord.copyWith(
        hasRevealedToday: false,
        messageId: '',
        message: '',
        zodiacHint: '',
        luckyColor: '',
      );
      unawaited(_saveDailyRevealRecord());
      if (notify) {
        notifyListeners();
      }
      return;
    }

    if (_dailyRevealRecord.messageId.isEmpty ||
        !_dailyRevealRecord.hasRevealedToday) {
      final generated = _generateTodayMessage(selectedState: selected);
      _dailyRevealRecord = _dailyRevealRecord.copyWith(
        selectedStateKey: selected.key,
        messageId: generated.id,
        message: generated.message,
        zodiacHint: generated.zodiacHint,
        luckyColor: generated.luckyColor,
      );
    }

    _currentMessage = DailyMessage(
      id: _dailyRevealRecord.messageId,
      date: _dateFromKey(_dailyRevealRecord.dateKey),
      message: _dailyRevealRecord.message,
      zodiacHint: _dailyRevealRecord.zodiacHint,
      luckyColor: _dailyRevealRecord.luckyColor,
      zodiacSign: _profile.zodiacSign,
    );

    unawaited(_saveDailyRevealRecord());
    if (notify) {
      notifyListeners();
    }
  }

  DailyMessage _generateTodayMessage({required DailyState selectedState}) {
    final now = DateTime.now();
    return _messageService.generateDailyMessage(
      date: DateTime(now.year, now.month, now.day),
      zodiacSign: _profile.zodiacSign,
      preferredTone: _profile.preferredTone,
      selectedState: selectedState,
    );
  }

  static String _todayKey() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  DateTime _dateFromKey(String key) {
    try {
      return DateTime.parse(key);
    } catch (_) {
      return DateTime.now();
    }
  }
}

class StarKindScope extends InheritedNotifier<StarKindState> {
  const StarKindScope({
    super.key,
    required StarKindState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static StarKindState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<StarKindScope>();
    if (scope == null || scope.notifier == null) {
      throw FlutterError('StarKindScope not found in widget tree.');
    }
    return scope.notifier!;
  }
}
