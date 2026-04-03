import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_message.dart';
import '../models/user_profile.dart';
import 'message_service.dart';
import 'zodiac_service.dart';

class StarKindState extends ChangeNotifier {
  StarKindState({
    MessageService? messageService,
    ZodiacService? zodiacService,
  })  : _messageService = messageService ?? MessageService(),
        _zodiacService = zodiacService ?? ZodiacService() {
    refreshDailyMessage();
  }

  final MessageService _messageService;
  final ZodiacService _zodiacService;

  static const String _profileKey = 'profile';
  static const String _savedMessagesKey = 'saved_messages';

  UserProfile _profile = UserProfile.initial();
  DailyMessage? _currentMessage;
  final List<DailyMessage> _savedMessages = [];

  UserProfile get profile => _profile;
  DailyMessage? get currentMessage => _currentMessage;
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
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);
    final savedJson = prefs.getStringList(_savedMessagesKey) ?? [];

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

    refreshDailyMessage();
  }

  void setBirthday(DateTime birthday) {
    final zodiac = _zodiacService.getZodiacSign(birthday);
    _profile = _profile.copyWith(
      birthday: birthday,
      zodiacSign: zodiac,
    );
    _saveProfile();
    refreshDailyMessage();
  }

  void setPreferredTone(String tone) {
    _profile = _profile.copyWith(preferredTone: tone);
    _saveProfile();
    refreshDailyMessage();
  }

  void setNotificationTime(TimeOfDay time) {
    _profile = _profile.copyWith(
      notificationHour: time.hour,
      notificationMinute: time.minute,
    );
    _saveProfile();
    notifyListeners();
  }

  void refreshDailyMessage() {
    final now = DateTime.now();
    _currentMessage = _messageService.generateDailyMessage(
      date: DateTime(now.year, now.month, now.day),
      zodiacSign: _profile.zodiacSign,
      preferredTone: _profile.preferredTone,
    );
    notifyListeners();
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
