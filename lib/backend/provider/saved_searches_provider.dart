import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_hostel_app/backend/model/filter_model.dart';

/// Model for saved search
class SavedSearch {
  final String id;
  final String name;
  final HostelFilter filter;
  final DateTime savedAt;

  SavedSearch({
    required this.id,
    required this.name,
    required this.filter,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'savedAt': savedAt.toIso8601String(),
      'filter': {
        'campus': filter.campus,
        'roomType': filter.roomType,
        'gender': filter.gender,
        'minPrice': filter.minPrice,
        'maxPrice': filter.maxPrice,
        'amenities': filter.amenities,
        'sortBy': filter.sortBy.index,
        'searchQuery': filter.searchQuery,
      },
    };
  }

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    final filterData = json['filter'] as Map<String, dynamic>;
    return SavedSearch(
      id: json['id'] as String,
      name: json['name'] as String,
      savedAt: DateTime.parse(json['savedAt'] as String),
      filter: HostelFilter(
        campus: filterData['campus'] as String?,
        roomType: filterData['roomType'] as String?,
        gender: filterData['gender'] as String?,
        minPrice: filterData['minPrice'] as double?,
        maxPrice: filterData['maxPrice'] as double?,
        amenities: List<String>.from(filterData['amenities'] ?? []),
        sortBy: SortBy.values[filterData['sortBy'] as int? ?? 0],
        searchQuery: filterData['searchQuery'] as String?,
      ),
    );
  }
}

/// Provider for saved searches
final savedSearchesProvider = NotifierProvider<SavedSearchesNotifier, List<SavedSearch>>(SavedSearchesNotifier.new);

class SavedSearchesNotifier extends Notifier<List<SavedSearch>> {
  @override
  List<SavedSearch> build() {
    _loadSavedSearches();
    return [];
  }

  static const String _savedSearchesKey = 'saved_searches';
  static const int _maxSavedSearches = 20;

  /// Load saved searches from shared preferences
  Future<void> _loadSavedSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSearchesJson = prefs.getStringList(_savedSearchesKey) ?? [];

      final searches = savedSearchesJson
          .map((json) {
            try {
              return SavedSearch.fromJson(jsonDecode(json));
            } catch (e) {
              return null;
            }
          })
          .where((search) => search != null)
          .cast<SavedSearch>()
          .toList();

      state = searches;
    } catch (e) {
      state = [];
    }
  }

  /// Save a new search
  Future<bool> saveSearch(String name, HostelFilter filter) async {
    // Check if name already exists
    if (state.any((search) => search.name == name)) {
      return false; // Name already exists
    }

    final newSearch = SavedSearch(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      filter: filter,
      savedAt: DateTime.now(),
    );

    final updatedSearches = List<SavedSearch>.from(state);
    updatedSearches.insert(0, newSearch);

    // Limit to max items
    if (updatedSearches.length > _maxSavedSearches) {
      updatedSearches.removeRange(_maxSavedSearches, updatedSearches.length);
    }

    state = updatedSearches;

    // Save to shared preferences
    await _persistSearches();
    return true;
  }

  /// Update an existing saved search
  Future<void> updateSearch(String id, String newName, HostelFilter filter) async {
    final updatedSearches = state.map((search) {
      if (search.id == id) {
        return SavedSearch(
          id: search.id,
          name: newName,
          filter: filter,
          savedAt: DateTime.now(),
        );
      }
      return search;
    }).toList();

    state = updatedSearches;
    await _persistSearches();
  }

  /// Delete a saved search
  Future<void> deleteSearch(String id) async {
    final updatedSearches = state.where((search) => search.id != id).toList();
    state = updatedSearches;
    await _persistSearches();
  }

  /// Clear all saved searches
  Future<void> clearAllSearches() async {
    state = [];

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedSearchesKey);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Persist searches to shared preferences
  Future<void> _persistSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searchesJson = state.map((search) => jsonEncode(search.toJson())).toList();
      await prefs.setStringList(_savedSearchesKey, searchesJson);
    } catch (e) {
      // Handle error silently
    }
  }
}
