import 'dart:collection';

import 'package:flutter/material.dart';

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

  void setBirthday(DateTime birthday) {
    final zodiac = _zodiacService.getZodiacSign(birthday);
    _profile = _profile.copyWith(
      birthday: birthday,
      zodiacSign: zodiac,
    );
    refreshDailyMessage();
  }

  void setPreferredTone(String tone) {
    _profile = _profile.copyWith(preferredTone: tone);
    refreshDailyMessage();
  }

  void setNotificationTime(TimeOfDay time) {
    _profile = _profile.copyWith(
      notificationHour: time.hour,
      notificationMinute: time.minute,
    );
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
    notifyListeners();
    return true;
  }

  void removeSavedMessage(String messageId) {
    _savedMessages.removeWhere((item) => item.id == messageId);
    notifyListeners();
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
