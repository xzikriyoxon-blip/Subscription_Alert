import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_preferences.dart';
import '../services/notification_preferences_store.dart';

final notificationPreferencesStoreProvider =
    Provider<NotificationPreferencesStore>((ref) {
  return NotificationPreferencesStore();
});

final notificationPreferencesProvider =
    StateNotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  final store = ref.watch(notificationPreferencesStoreProvider);
  return NotificationPreferencesNotifier(store);
});

class NotificationPreferencesNotifier
    extends StateNotifier<NotificationPreferences> {
  final NotificationPreferencesStore _store;

  NotificationPreferencesNotifier(this._store)
      : super(NotificationPreferences.defaults) {
    _load();
  }

  Future<void> _load() async {
    state = await _store.load();
  }

  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(enabled: enabled);
    await _store.save(state);
  }

  Future<void> setTime({required int hour, required int minute}) async {
    state = state.copyWith(hour: hour, minute: minute);
    await _store.save(state);
  }

  Future<void> setDaysBefore(List<int> daysBefore) async {
    state = state.copyWith(daysBefore: daysBefore);
    await _store.save(state);
  }
}
