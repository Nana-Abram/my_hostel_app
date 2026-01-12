import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for search history management
final searchHistoryProvider = NotifierProvider<SearchHistoryNotifier, List<String>>(SearchHistoryNotifier.new);

class SearchHistoryNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    _loadSearchHistory();
    return [];
  }

  static const String _historyKey = 'search_history';
  static const int _maxHistoryItems = 10;

  /// Load search history from shared preferences
  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      state = history;
    } catch (e) {
      // Handle error silently
      state = [];
    }
  }

  /// Add a search query to history
  Future<void> addSearch(String query) async {
    if (query.isEmpty) return;

    final updatedHistory = List<String>.from(state);

    // Remove duplicate if exists
    updatedHistory.remove(query);

    // Add to beginning
    updatedHistory.insert(0, query);

    // Limit to max items
    if (updatedHistory.length > _maxHistoryItems) {
      updatedHistory.removeRange(_maxHistoryItems, updatedHistory.length);
    }

    state = updatedHistory;

    // Save to shared preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyKey, updatedHistory);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Remove a specific search query from history
  Future<void> removeSearch(String query) async {
    final updatedHistory = List<String>.from(state);
    updatedHistory.remove(query);
    state = updatedHistory;

    // Save to shared preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyKey, updatedHistory);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Clear all search history
  Future<void> clearHistory() async {
    state = [];

    // Clear from shared preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get search suggestions based on current query
  List<String> getSuggestions(String query) {
    if (query.isEmpty) return state;

    return state
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
