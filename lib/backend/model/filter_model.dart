enum SortBy {
  priceAsc,
  priceDesc,
  rating,
  popularity,
  newest,
}

class HostelFilter {
  final String? campus;
  final String? roomType;
  final String? gender;
  final double? minPrice;
  final double? maxPrice;
  final List<String> amenities;
  final SortBy sortBy;
  final String? searchQuery;

  HostelFilter({
    this.campus,
    this.roomType,
    this.gender,
    this.minPrice,
    this.maxPrice,
    this.amenities = const [],
    this.sortBy = SortBy.popularity,
    this.searchQuery,
  });

  HostelFilter copyWith({
    String? campus,
    String? roomType,
    String? gender,
    double? minPrice,
    double? maxPrice,
    List<String>? amenities,
    SortBy? sortBy,
    String? searchQuery,
    bool clearCampus = false,
    bool clearRoomType = false,
    bool clearGender = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearSearchQuery = false,
  }) {
    return HostelFilter(
      campus: clearCampus ? null : (campus ?? this.campus),
      roomType: clearRoomType ? null : (roomType ?? this.roomType),
      gender: clearGender ? null : (gender ?? this.gender),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      amenities: amenities ?? this.amenities,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
    );
  }

  bool get hasActiveFilters {
    return campus != null ||
        roomType != null ||
        gender != null ||
        minPrice != null ||
        maxPrice != null ||
        amenities.isNotEmpty ||
        searchQuery != null;
  }

  int get activeFilterCount {
    int count = 0;
    if (campus != null) count++;
    if (roomType != null) count++;
    if (gender != null) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (amenities.isNotEmpty) count++;
    if (searchQuery != null) count++;
    return count;
  }
}
