import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/model/filter_model.dart';

final filterProvider =
    NotifierProvider<FilterNotifier, HostelFilter>(FilterNotifier.new);

class FilterNotifier extends Notifier<HostelFilter> {
  @override
  HostelFilter build() {
    return HostelFilter(); // 
  }

  void setCampus(String? value) {
    state = state.copyWith(campus: value, clearCampus: value == null);
  }

  void setRoomType(String? value) {
    state = state.copyWith(roomType: value, clearRoomType: value == null);
  }

  void setGender(String? value) {
    state = state.copyWith(gender: value, clearGender: value == null);
  }

  void setMinPrice(double? value) {
    state = state.copyWith(minPrice: value, clearMinPrice: value == null);
  }

  void setMaxPrice(double value) {
    state = state.copyWith(maxPrice: value);
  }

  void setPriceRange(double min, double max) {
    state = state.copyWith(
      minPrice: min,
      maxPrice: max,
      clearMinPrice: false,
      clearMaxPrice: false,
    );
  }

  void setSortBy(SortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query, clearSearchQuery: query == null);
  }

  void toggleAmenity(String amenity) {
    final updated = List<String>.from(state.amenities);

    if (updated.contains(amenity)) {
      updated.remove(amenity);
    } else {
      updated.add(amenity);
    }

    state = state.copyWith(amenities: updated);
  }

  void clearFilters() {
    state = HostelFilter();
  }

  void applyFilters() {
    state = state; // Forces recompute
  }
}
