import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseNotifier<T> extends StateNotifier<List<T>> {
  String storageKey;
  List<T> pendingSync = []; // items to sync with backend -- pendingSync for offline-first

  BaseNotifier(this.storageKey) : super([]) {
    _loadFromStorage();
  }

  /// Update storage key when user changes (e.g, new user login)
  void updateStorageKey(String newKey) {
    storageKey = newKey;
    state = [];
    pendingSync.clear();
    _loadFromStorage();
  }

  /// Load data from SharedPreferences
  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getStringList(storageKey) ?? [];

    state = rawData.map((item) => fromStorage(item)).toList();
  }

  /// Public method to reload from storage
  Future<void> loadFromStorage() async {
    await _loadFromStorage();
  }

  /// Save data to SharedPreferences
  Future<void> saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = state.map((item) => toStorage(item)).toList();
    await prefs.setStringList(storageKey, rawData);
  }

  /// Toggle item and track for sync
  Future<void> toggle(T item) async {
    if (state.contains(item)) {
      state = [...state]..remove(item);
      pendingSync.add(item);// mark for removal

    } else {
      state = [...state, item];
      pendingSync.add(item);// mark for addition
    }
    await saveToStorage();
  }

  /// Add item only if not already present (for visited)
  Future<void> addIfNotExist(T item) async {
    if (!state.contains(item)) {
      state = [...state, item];
      pendingSync.add(item);
      await saveToStorage();
    }
  }

  /// Mark item as synced (after successful backend update)
  void markSynced(T item) {
    pendingSync.remove(item);
  }

  /// Clear state completely
  Future<void> clear() async {
    state = [];
    pendingSync.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey); //Remove key
  }

  /// Convert item from string (override in subclasses)
  T fromStorage(String raw);

  /// Convert item to string (override in subclasses)
  String toStorage(T item);
}
