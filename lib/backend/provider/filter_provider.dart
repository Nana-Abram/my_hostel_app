import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/model/filter_model.dart';

final filterProvider =
    NotifierProvider<FilterNotifier, HostelFilter>(FilterNotifier.new);

class FilterNotifier extends Notifier<HostelFilter> {
  @override
  HostelFilter build() {
    return HostelFilter(); // ✅ initial filter state
  }

  void setCampus(String? value) {
    state = state.copyWith(campus: value);
  }

  void setRoomType(String? value) {
    state = state.copyWith(roomType: value);
  }
  void setGender(String? value) {
    state = state.copyWith(roomType: value);
  }

  void setMaxPrice(double value) {
    state = state.copyWith(maxPrice: value);
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
}
